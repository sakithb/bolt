package renderer

import "core:dynlib"
import "core:strings"
import "core:slice"
import "core:os"
import "core:mem"
import "core:log"

import "bolt:platform"

import vk "vendored:vulkan"

Renderer_Init_Info :: struct {
    name: cstring,
    maj_ver: u32,
    min_ver: u32,
    pat_ver: u32,
}

Renderer :: struct {
    instance: vk.Instance,
    physical_device: Physical_Device,
    device: Device,
    surface: Surface,
    queues: [Queue_Family]Queue,
	swapchain: Swapchain,
    render_pass: Render_Pass,
    pipeline: Pipeline,

    cmd_pool: vk.CommandPool,
    cmd_buf: vk.CommandBuffer,

    image_avail_sem: vk.Semaphore,
    render_fin_sem: vk.Semaphore,
    in_flight_fence: vk.Fence,
}

Physical_Device :: struct {
    hnd: vk.PhysicalDevice,
	props:  vk.PhysicalDeviceProperties,
	feats:  vk.PhysicalDeviceFeatures,
    mem_props: vk.PhysicalDeviceMemoryProperties
}

Device :: struct {
    hnd: vk.Device,
}

Surface :: struct {
    hnd: vk.SurfaceKHR,
    width: i32,
    height: i32
}

Queue_Family :: enum {
    Graphics,
    Present,
    Transfer
}

Queue :: struct {
	hnd: vk.Queue,
	index:  u32,
}

Swapchain :: struct {
	hnd: vk.SwapchainKHR,
    format: vk.SurfaceFormatKHR,
    present_mode: vk.PresentModeKHR,
    capabilities: vk.SurfaceCapabilitiesKHR,
    extent: vk.Extent2D,
    images: []vk.Image,
    image_views: []vk.ImageView,
}

Render_Pass :: struct {
    hnd: vk.RenderPass,
    framebuffers: []vk.Framebuffer
}

Pipeline :: struct {
    hnd: vk.Pipeline,
    layout: vk.PipelineLayout
}

Buffer :: struct {
    hnd: vk.Buffer,
    mem: vk.DeviceMemory
}

Renderer_Errs :: enum {
    None,
    Could_Not_Load_Lib,
    Ins_Ext_Not_Found,
    Layer_Not_Found,
    Dev_Ext_Not_Found,
    Could_Not_Create_Surface,
    Phys_Dev_Not_Found,
    Could_Not_Find_Mem_Type
}

Renderer_Err :: union #shared_nil {
    Renderer_Errs,
    vk.Result,
    os.Error
}

REQUIRED_INSTANCE_EXTENSIONS := []cstring{
    "VK_KHR_surface",
    "VK_KHR_wayland_surface" when ODIN_OS == .Linux else "VK_KHR_win32_surface"
}

REQUIRED_INSTANCE_LAYERS := []cstring{
    "VK_LAYER_KHRONOS_validation"
}

REQUIRED_DEVICE_EXTENSIONS := []cstring{
    vk.KHR_SWAPCHAIN_EXTENSION_NAME
}

VK_NULL_HANDLE :: 0
VK_LIB_NAME :: "libvulkan.so.1" when ODIN_OS == .Linux else "vulkan-1.dll"

rndr := Renderer{}

init :: proc(init_info: Renderer_Init_Info) -> Renderer_Err {
    lib, lib_ok := dynlib.load_library(VK_LIB_NAME)
    if !lib_ok {
        return .Could_Not_Load_Lib
    }

    gipa, gipa_ok := dynlib.symbol_address(lib, "vkGetInstanceProcAddr")
    if !gipa_ok {
        return .Could_Not_Load_Lib
    }

	vk.load_proc_addresses_global(gipa)

	ins_exts_n: u32
	vk.EnumerateInstanceExtensionProperties(nil, &ins_exts_n, nil) or_return
	ins_exts := make([]vk.ExtensionProperties, ins_exts_n, context.temp_allocator)
	vk.EnumerateInstanceExtensionProperties(nil, &ins_exts_n, raw_data(ins_exts)) or_return

	exts_loop: for required_ext in REQUIRED_INSTANCE_EXTENSIONS {
		req_name := string(required_ext)
		for &ext in ins_exts {
			name := strings.truncate_to_byte(string(ext.extensionName[:]), 0)
			if strings.compare(req_name, name) == 0 {
				continue exts_loop
			}
		}

		return .Ins_Ext_Not_Found
	}

	when ODIN_DEBUG {
		layers_n: u32
		vk.EnumerateInstanceLayerProperties(&layers_n, nil) or_return
		layers := make([]vk.LayerProperties, layers_n, context.temp_allocator)
		vk.EnumerateInstanceLayerProperties(&layers_n, raw_data(layers)) or_return

		layers_loop: for required_layer in REQUIRED_INSTANCE_LAYERS {
			req_name := string(required_layer)
			for &layer in layers {
				name := strings.truncate_to_byte(string(layer.layerName[:]), 0)
				if strings.compare(req_name, name) == 0 {
					continue layers_loop
				}
			}

			return .Layer_Not_Found
		}
	}

	instance_info := vk.InstanceCreateInfo {
		sType                   = .INSTANCE_CREATE_INFO,
		pApplicationInfo        = &vk.ApplicationInfo{
			sType = .APPLICATION_INFO,
			pApplicationName = init_info.name,
			applicationVersion = vk.MAKE_VERSION(
				init_info.maj_ver,
				init_info.min_ver,
				init_info.pat_ver,
			),
			pEngineName = init_info.name,
			engineVersion = vk.MAKE_VERSION(
				init_info.maj_ver,
				init_info.min_ver,
				init_info.pat_ver,
			),
			apiVersion = vk.API_VERSION_1_2,
		},
		enabledLayerCount       = u32(len(REQUIRED_INSTANCE_LAYERS)) when ODIN_DEBUG else 0,
		ppEnabledLayerNames     = raw_data(REQUIRED_INSTANCE_LAYERS) when ODIN_DEBUG else nil,
		enabledExtensionCount   = u32(len(REQUIRED_INSTANCE_EXTENSIONS)),
		ppEnabledExtensionNames = raw_data(REQUIRED_INSTANCE_EXTENSIONS),
	}

	vk.CreateInstance(&instance_info, nil, &rndr.instance) or_return

	vk.load_proc_addresses_instance(rndr.instance)

    rndr.surface.hnd = platform.wsi_create_surface(rndr.instance) or_return
    rndr.surface.width, rndr.surface.height = platform.wsi_get_dimensions()

	create_device() or_return
	create_swapchain() or_return
    create_pipelines() or_return
    create_command_buffers() or_return

    free_all(context.temp_allocator)

	return nil
}

Scored_Physical_Device :: struct {
	phys_device: vk.PhysicalDevice,
	score:       uint,
}

create_device :: proc() -> Renderer_Err {
	phys_devices_n: u32
	vk.EnumeratePhysicalDevices(rndr.instance, &phys_devices_n, nil) or_return
	phys_devices := make([]vk.PhysicalDevice, phys_devices_n, context.temp_allocator)
	vk.EnumeratePhysicalDevices(rndr.instance, &phys_devices_n, raw_data(phys_devices)) or_return

	scored_phys_devices := make([]Scored_Physical_Device, phys_devices_n, context.temp_allocator)

	for phys_device, i in phys_devices {
		props: vk.PhysicalDeviceProperties
		vk.GetPhysicalDeviceProperties(phys_device, &props)

		score: uint

		#partial switch props.deviceType {
		case .DISCRETE_GPU:
			score = 3
		case .INTEGRATED_GPU:
			score = 2
		case:
			score = 1
		}

		mem_props: vk.PhysicalDeviceMemoryProperties
		vk.GetPhysicalDeviceMemoryProperties(phys_device, &mem_props)

		for heap in mem_props.memoryHeaps {
			if .DEVICE_LOCAL in heap.flags {
				score += uint(heap.size)
			}
		}

		scored_phys_devices[i] = Scored_Physical_Device {
			phys_device = phys_device,
			score       = score,
		}
	}

	slice.reverse_sort_by_cmp(
		scored_phys_devices,
		proc(curr, next: Scored_Physical_Device) -> slice.Ordering {
			if curr.score > next.score {
				return .Greater
			} else if curr.score < next.score {
				return .Less
			} else {
				return .Equal
			}
		},
	)

	exts_n: u32
	exts := make([dynamic]vk.ExtensionProperties, context.temp_allocator)

	fams_n: u32
	fams := make([dynamic]vk.QueueFamilyProperties, context.temp_allocator)

	phys_device_outer: for scored_phys_device in scored_phys_devices {
		phys_device := scored_phys_device.phys_device

		vk.EnumerateDeviceExtensionProperties(phys_device, nil, &exts_n, nil) or_continue
		if int(exts_n) < len(REQUIRED_DEVICE_EXTENSIONS) do continue
		resize(&exts, int(exts_n))
		vk.EnumerateDeviceExtensionProperties(
			phys_device,
			nil,
			&exts_n,
			raw_data(exts),
		) or_continue

		exts_outer: for required_ext in REQUIRED_DEVICE_EXTENSIONS {
			req_name := string(required_ext)
			for &ext in exts {
				name := strings.truncate_to_byte(string(ext.extensionName[:]), 0)
				if strings.compare(req_name, name) == 0 {
					continue exts_outer
				}
			}

			continue phys_device_outer
		}

		vk.GetPhysicalDeviceQueueFamilyProperties(phys_device, &fams_n, nil)
		resize(&fams, int(fams_n))
		vk.GetPhysicalDeviceQueueFamilyProperties(phys_device, &fams_n, raw_data(fams))

		queue_set := bit_set[Queue_Family]{}
		for fam, i in fams {
			if .GRAPHICS in fam.queueFlags {
				queue_set |= {.Graphics, .Transfer}
			}

			supported: b32
			vk.GetPhysicalDeviceSurfaceSupportKHR(phys_device, u32(i), rndr.surface.hnd, &supported)

			if supported {
				queue_set |= {.Present}
			}

			if card(queue_set) == len(Queue_Family) do break
		}

		if card(queue_set) != len(Queue_Family) do continue

        fmts_n: u32
        vk.GetPhysicalDeviceSurfaceFormatsKHR(phys_device, rndr.surface.hnd, &fmts_n, nil)
        if fmts_n == 0 do continue

        present_modes_n: u32
        vk.GetPhysicalDeviceSurfacePresentModesKHR(phys_device, rndr.surface.hnd, &present_modes_n, nil)
        if present_modes_n == 0 do continue

		// TODO: Check for limits if needed

		props: vk.PhysicalDeviceProperties
		vk.GetPhysicalDeviceProperties(phys_device, &props)

		feats: vk.PhysicalDeviceFeatures
		vk.GetPhysicalDeviceFeatures(phys_device, &feats)

        mem_props: vk.PhysicalDeviceMemoryProperties
        vk.GetPhysicalDeviceMemoryProperties(phys_device, &mem_props)

		rndr.physical_device = Physical_Device{
			hnd = phys_device,
			props  = props,
			feats  = feats,
            mem_props = mem_props
		}

		break
	}

	if rndr.physical_device.hnd == nil do return .Phys_Dev_Not_Found

	unique_indices := make(map[int]bool, context.temp_allocator)

	// TODO: Could this be done in a better way?
	fam_outer: for q_fam in Queue_Family {
		for fam, i in fams {
			switch q_fam {
			case .Graphics:
				if .GRAPHICS in fam.queueFlags {
					unique_indices[i] = true
					rndr.queues[.Graphics].index = u32(i)
					continue fam_outer
				}
			case .Present:
				present_supported: b32
				vk.GetPhysicalDeviceSurfaceSupportKHR(
					rndr.physical_device.hnd,
					u32(i),
					rndr.surface.hnd,
					&present_supported,
				)
				if present_supported {
					unique_indices[i] = true
					rndr.queues[.Present].index = u32(i)
					continue fam_outer
				}
			case .Transfer:
				if .TRANSFER in fam.queueFlags {
					unique_indices[i] = true
					rndr.queues[.Transfer].index = u32(i)
					continue fam_outer
				}
			}
		}

		if q_fam == .Transfer {
			rndr.queues[.Transfer].index = rndr.queues[.Graphics].index
		}
	}

	queue_create_infos := make(
		[]vk.DeviceQueueCreateInfo,
		len(unique_indices),
		context.temp_allocator,
	)
	queue_priority: f32 = 1.0

	for k in unique_indices {
		queue_create_infos[k] = vk.DeviceQueueCreateInfo {
			sType            = .DEVICE_QUEUE_CREATE_INFO,
			queueFamilyIndex = u32(k),
			queueCount       = 1,
			pQueuePriorities = &queue_priority,
		}
	}

	device_create_info := vk.DeviceCreateInfo {
		sType                   = .DEVICE_CREATE_INFO,
		enabledLayerCount       = 0,
		ppEnabledLayerNames     = nil,
		enabledExtensionCount   = u32(len(REQUIRED_DEVICE_EXTENSIONS)),
		ppEnabledExtensionNames = raw_data(REQUIRED_DEVICE_EXTENSIONS),
		queueCreateInfoCount    = u32(len(queue_create_infos)),
		pQueueCreateInfos       = raw_data(queue_create_infos),
		pEnabledFeatures        = nil,
	}

    vk.CreateDevice(rndr.physical_device.hnd, &device_create_info, nil, &rndr.device.hnd) or_return

    for &queue in rndr.queues {
        vk.GetDeviceQueue(rndr.device.hnd, queue.index, 0, &queue.hnd)
    }

    return nil
}

create_swapchain :: proc() -> Renderer_Err {
    fmts_n: u32
    vk.GetPhysicalDeviceSurfaceFormatsKHR(rndr.physical_device.hnd, rndr.surface.hnd, &fmts_n, nil) or_return
    fmts := make([]vk.SurfaceFormatKHR, fmts_n, context.temp_allocator)
    vk.GetPhysicalDeviceSurfaceFormatsKHR(rndr.physical_device.hnd, rndr.surface.hnd, &fmts_n, raw_data(fmts)) or_return

    rndr.swapchain.format = fmts[0]
    for fmt in fmts {
		if fmt.format == .B8G8R8A8_SRGB && fmt.colorSpace == .SRGB_NONLINEAR {
            rndr.swapchain.format = fmt
        }
    }

    present_modes_n: u32
    vk.GetPhysicalDeviceSurfacePresentModesKHR(rndr.physical_device.hnd, rndr.surface.hnd, &present_modes_n, nil) or_return
    present_modes := make([]vk.PresentModeKHR, present_modes_n, context.temp_allocator)
    vk.GetPhysicalDeviceSurfacePresentModesKHR(
        rndr.physical_device.hnd,
        rndr.surface.hnd,
        &present_modes_n,
        raw_data(present_modes)
    ) or_return

    rndr.swapchain.present_mode = .FIFO
    for present_mode in present_modes {
		if present_mode == .MAILBOX {
            rndr.swapchain.present_mode = present_mode
        }
    }

    vk.GetPhysicalDeviceSurfaceCapabilitiesKHR(rndr.physical_device.hnd, rndr.surface.hnd, &rndr.swapchain.capabilities)

	if (rndr.swapchain.capabilities.currentExtent.width == max(u32)) {
		rndr.swapchain.extent.width = clamp(
			u32(rndr.surface.width),
			rndr.swapchain.capabilities.minImageExtent.width,
			rndr.swapchain.capabilities.maxImageExtent.height,
		)
		rndr.swapchain.extent.height = clamp(
			u32(rndr.surface.height),
			rndr.swapchain.capabilities.minImageExtent.height,
			rndr.swapchain.capabilities.maxImageExtent.height,
		)
	} else {
		rndr.swapchain.extent = rndr.swapchain.capabilities.currentExtent
	}

	images_n := rndr.swapchain.capabilities.minImageCount + 1
	if (rndr.swapchain.capabilities.maxImageCount > 0 && images_n > rndr.swapchain.capabilities.maxImageCount) {
		images_n = rndr.swapchain.capabilities.maxImageCount
	}

    image_sharing_mode := vk.SharingMode.EXCLUSIVE
    queue_fam_index_n: u32 = 0
    queue_fam_indices: [^]u32 = nil
	if (rndr.queues[.Graphics].index != rndr.queues[.Present].index) {
		image_sharing_mode = .CONCURRENT
		queue_fam_index_n = 2
		queue_fam_indices = raw_data([]u32{
            u32(rndr.queues[.Graphics].index),
            u32(rndr.queues[.Present].index)
        })
	}

	swapchain_create_info := vk.SwapchainCreateInfoKHR {
		sType            = .SWAPCHAIN_CREATE_INFO_KHR,
		surface          = rndr.surface.hnd,
		minImageCount    = images_n,
		imageFormat      = rndr.swapchain.format.format,
		imageColorSpace  = rndr.swapchain.format.colorSpace,
		imageExtent      = rndr.swapchain.extent,
		imageArrayLayers = 1,
		imageUsage       = {.COLOR_ATTACHMENT},
        imageSharingMode = image_sharing_mode,
        queueFamilyIndexCount = queue_fam_index_n,
        pQueueFamilyIndices = queue_fam_indices,
		preTransform     = rndr.swapchain.capabilities.currentTransform,
		compositeAlpha   = {.OPAQUE},
		presentMode      = rndr.swapchain.present_mode,
		clipped          = true,
        oldSwapchain = rndr.swapchain.hnd,
	}

	vk.CreateSwapchainKHR(rndr.device.hnd, &swapchain_create_info, nil, &rndr.swapchain.hnd) or_return

    vk.GetSwapchainImagesKHR(rndr.device.hnd, rndr.swapchain.hnd, &images_n, nil) or_return
    rndr.swapchain.images = make([]vk.Image, images_n)
    vk.GetSwapchainImagesKHR(rndr.device.hnd, rndr.swapchain.hnd, &images_n, raw_data(rndr.swapchain.images)) or_return

    rndr.swapchain.image_views = make([]vk.ImageView, images_n)
	for image, i in rndr.swapchain.images {
		rndr.swapchain.image_views[i] = create_image_view(image, rndr.swapchain.format.format, {.COLOR}) or_return
	}

    color_attachment := vk.AttachmentDescription {
        format = rndr.swapchain.format.format,
        samples = {._1},
        loadOp = .CLEAR,
        storeOp = .STORE,
        stencilLoadOp = .DONT_CARE,
        stencilStoreOp = .DONT_CARE,
        initialLayout = .UNDEFINED,
        finalLayout = .PRESENT_SRC_KHR
    }

    color_attachment_ref := vk.AttachmentReference{
        attachment = 0,
        layout = .COLOR_ATTACHMENT_OPTIMAL
    }

    subpass := vk.SubpassDescription{
        pipelineBindPoint = .GRAPHICS,
        inputAttachmentCount = 0,
        pInputAttachments = nil,
        colorAttachmentCount = 1,
        pColorAttachments = &color_attachment_ref,
        pResolveAttachments = nil,
        pDepthStencilAttachment = nil,
        preserveAttachmentCount = 0,
        pPreserveAttachments = nil,
    }

    attachments := []vk.AttachmentDescription{
        color_attachment
    }

    render_pass_create_info := vk.RenderPassCreateInfo{
        sType = .RENDER_PASS_CREATE_INFO,
        attachmentCount = u32(len(attachments)),
        pAttachments = raw_data(attachments),
        subpassCount = 1,
        pSubpasses = &subpass,
        dependencyCount = 0,
        pDependencies = nil,
    }

    vk.CreateRenderPass(rndr.device.hnd, &render_pass_create_info, nil, &rndr.render_pass.hnd) or_return

    rndr.render_pass.framebuffers = make([]vk.Framebuffer, len(rndr.swapchain.image_views))
    for &image_view, i in rndr.swapchain.image_views {
        framebuffer_create_info := vk.FramebufferCreateInfo{
            sType = .FRAMEBUFFER_CREATE_INFO,
            renderPass = rndr.render_pass.hnd,
            attachmentCount = 1,
            pAttachments = &image_view,
            width = rndr.swapchain.extent.width,
            height = rndr.swapchain.extent.height,
            layers = 1,
        }

        vk.CreateFramebuffer(rndr.device.hnd, &framebuffer_create_info, nil, &rndr.render_pass.framebuffers[i]) or_return
    }

    sem_create_info := vk.SemaphoreCreateInfo{
        sType = .SEMAPHORE_CREATE_INFO,
    }
    
    fence_create_info := vk.FenceCreateInfo{
        sType = .FENCE_CREATE_INFO,
        flags = {.SIGNALED}
    }

    vk.CreateSemaphore(rndr.device.hnd, &sem_create_info, nil, &rndr.image_avail_sem) or_return
    vk.CreateSemaphore(rndr.device.hnd, &sem_create_info, nil, &rndr.render_fin_sem) or_return
    vk.CreateFence(rndr.device.hnd, &fence_create_info, nil, &rndr.in_flight_fence) or_return

    return nil
}

destroy_swapchain :: proc() {
    vk.DestroyFence(rndr.device.hnd, rndr.in_flight_fence, nil)
    vk.DestroySemaphore(rndr.device.hnd, rndr.render_fin_sem, nil)
    vk.DestroySemaphore(rndr.device.hnd, rndr.image_avail_sem, nil)

    delete(rndr.swapchain.images)
    delete(rndr.swapchain.image_views)
    delete(rndr.render_pass.framebuffers)

    for _, i in rndr.swapchain.images {
        vk.DestroyFramebuffer(rndr.device.hnd, rndr.render_pass.framebuffers[i], nil)
        vk.DestroyImageView(rndr.device.hnd, rndr.swapchain.image_views[i], nil)
    }

    vk.DestroyRenderPass(rndr.device.hnd, rndr.render_pass.hnd, nil)
    vk.DestroySwapchainKHR(rndr.device.hnd, rndr.swapchain.hnd, nil)
}

create_pipelines :: proc() -> Renderer_Err {
    vert_shader := create_shader_module("shaders/shader.vert.spv") or_return
    defer vk.DestroyShaderModule(rndr.device.hnd, vert_shader, nil)

    vertex_stage := vk.PipelineShaderStageCreateInfo{
        sType = .PIPELINE_SHADER_STAGE_CREATE_INFO,
        stage = {.VERTEX},
        module = vert_shader,
        pName = "main",
        pSpecializationInfo = nil
    }

    frag_shader := create_shader_module("shaders/shader.frag.spv") or_return
    defer vk.DestroyShaderModule(rndr.device.hnd, frag_shader, nil)

    fragment_stage := vk.PipelineShaderStageCreateInfo{
        sType = .PIPELINE_SHADER_STAGE_CREATE_INFO,
        stage = {.FRAGMENT},
        module = frag_shader,
        pName = "main",
        pSpecializationInfo = nil
    }

    stages := []vk.PipelineShaderStageCreateInfo{vertex_stage, fragment_stage}

    // TODO: vertex layout
    vertex_binding_desc := vk.VertexInputBindingDescription{
        binding = 0,
        stride = 5 * size_of(f32),
        inputRate = .VERTEX
    }

    vertex_attr_pos_desc := vk.VertexInputAttributeDescription{
        location = 0,
        binding = 0,
        format = .R32G32_SFLOAT,
        offset = 0
    }

    vertex_attr_col_desc := vk.VertexInputAttributeDescription{
        location = 1,
        binding = 0,
        format = .R32G32B32_SFLOAT,
        offset = 2 * size_of(f32)
    }

    vertex_attrs := []vk.VertexInputAttributeDescription{vertex_attr_pos_desc, vertex_attr_col_desc}

    vertex_input_state := vk.PipelineVertexInputStateCreateInfo{
        sType = .PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
        vertexBindingDescriptionCount = 1,
        pVertexBindingDescriptions = &vertex_binding_desc,
        vertexAttributeDescriptionCount = 2,
        pVertexAttributeDescriptions = raw_data(vertex_attrs)
    }

    input_assembly_state := vk.PipelineInputAssemblyStateCreateInfo{
        sType = .PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO,
        topology = .TRIANGLE_LIST,
        primitiveRestartEnable = false
    }

    viewport_state := vk.PipelineViewportStateCreateInfo{
        sType = .PIPELINE_VIEWPORT_STATE_CREATE_INFO,
        scissorCount = 1,
        // pScissors = &vk.Rect2D{
        //     offset = {0, 0},
        //     extent = swapchain.extent,
        // },
        pScissors = nil,
        viewportCount = 1,
        pViewports = nil
        // pViewports = &vk.Viewport{
        //     x        = 0.0,
        //     y        = 0.0,
        //     width    = f32(swapchain.extent.width),
        //     height   = f32(swapchain.extent.height),
        //     minDepth = 0.0,
        //     maxDepth = 1.0,
        // }
    }

    rasterization_state := vk.PipelineRasterizationStateCreateInfo{
        sType = .PIPELINE_RASTERIZATION_STATE_CREATE_INFO,
        depthClampEnable = false,
        rasterizerDiscardEnable = false,
        polygonMode = .FILL,
        cullMode = {.BACK},
        frontFace = .CLOCKWISE,
        depthBiasEnable = false,
        depthBiasConstantFactor = 0.0,
        depthBiasClamp = 0.0,
        depthBiasSlopeFactor = 0.0,
        lineWidth = 1.0
    }

    multisample_state := vk.PipelineMultisampleStateCreateInfo{
        sType = .PIPELINE_MULTISAMPLE_STATE_CREATE_INFO,
        rasterizationSamples = {._1},
        sampleShadingEnable = false,
        minSampleShading = 0,
        pSampleMask = nil,
        alphaToCoverageEnable = false,
        alphaToOneEnable = false
    }

    ds_state := vk.PipelineDepthStencilStateCreateInfo{
        sType = .PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO,
        depthTestEnable = false,
        depthWriteEnable = false,
        depthCompareOp = .NEVER,
        depthBoundsTestEnable = false,
        stencilTestEnable = false,
        front = {},
        back = {},
        minDepthBounds = 0.0,
        maxDepthBounds = 0.0,
    }

    color_blend_state := vk.PipelineColorBlendStateCreateInfo{
        sType = .PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
        logicOpEnable = false,
        logicOp = .CLEAR,
        attachmentCount = 1,
        pAttachments = &vk.PipelineColorBlendAttachmentState{
            blendEnable         = true,
            srcColorBlendFactor = .SRC_ALPHA,
            dstColorBlendFactor = .ONE_MINUS_SRC_ALPHA,
            colorBlendOp        = .ADD,
            srcAlphaBlendFactor = .ONE,
            dstAlphaBlendFactor = .ZERO,
            alphaBlendOp        = .ADD,
            colorWriteMask      = {.R, .G, .B, .A},
        },
        blendConstants = {}
    }

    dynamic_states := []vk.DynamicState{.VIEWPORT, .SCISSOR}

    dynamic_state := vk.PipelineDynamicStateCreateInfo{
        sType = .PIPELINE_DYNAMIC_STATE_CREATE_INFO,
        dynamicStateCount = u32(len(dynamic_states)),
        pDynamicStates = raw_data(dynamic_states)
    }

    layout_create_info := vk.PipelineLayoutCreateInfo{
        sType = .PIPELINE_LAYOUT_CREATE_INFO,
        setLayoutCount = 0,
        pSetLayouts = nil,
        pushConstantRangeCount = 0,
        pPushConstantRanges = nil
    }

    vk.CreatePipelineLayout(
        rndr.device.hnd,
        &layout_create_info,
        nil,
        &rndr.pipeline.layout
    ) or_return

    pipeline_create_info := vk.GraphicsPipelineCreateInfo{
        sType = .GRAPHICS_PIPELINE_CREATE_INFO,
        stageCount = u32(len(stages)),
        pStages = raw_data(stages),
        pVertexInputState = &vertex_input_state,
        pInputAssemblyState = &input_assembly_state,
        pTessellationState = nil,
        pViewportState = &viewport_state,
        pRasterizationState = &rasterization_state,
        pMultisampleState = &multisample_state,
        pDepthStencilState = &ds_state,
        pColorBlendState = &color_blend_state,
        pDynamicState = &dynamic_state,
        layout = rndr.pipeline.layout,
        renderPass = rndr.render_pass.hnd,
        subpass = 0,
        basePipelineHandle = {},
        basePipelineIndex = 0
    }

    vk.CreateGraphicsPipelines(
        rndr.device.hnd,
        VK_NULL_HANDLE,
        1,
        &pipeline_create_info,
        nil,
        &rndr.pipeline.hnd
    ) or_return

    return nil
}

create_command_buffers :: proc() -> Renderer_Err {
    // TODO: cmd pool reset?
    pool_create_info := vk.CommandPoolCreateInfo{
        sType = .COMMAND_POOL_CREATE_INFO,
        flags = {.RESET_COMMAND_BUFFER},
        queueFamilyIndex = u32(rndr.queues[.Graphics].index)
    }

    vk.CreateCommandPool(rndr.device.hnd, &pool_create_info, nil, &rndr.cmd_pool) or_return

    buffer_alloc_info := vk.CommandBufferAllocateInfo{
        sType = .COMMAND_BUFFER_ALLOCATE_INFO,
        level = .PRIMARY,
        commandBufferCount = 1,
        commandPool = rndr.cmd_pool,
    }

    // TODO: cmd buf
    vk.AllocateCommandBuffers(rndr.device.hnd, &buffer_alloc_info, &rndr.cmd_buf) or_return

    return nil
}

deinit :: proc() {
    if r := vk.DeviceWaitIdle(rndr.device.hnd); r != vk.Result.SUCCESS {
        log.panicf("could not wait for devie: %v", r)
    }

    vk.DestroyCommandPool(rndr.device.hnd, rndr.cmd_pool, nil)

    destroy_swapchain()

    vk.DestroyPipelineLayout(rndr.device.hnd, rndr.pipeline.layout, nil)
    vk.DestroyPipeline(rndr.device.hnd, rndr.pipeline.hnd, nil)
    vk.DestroyDevice(rndr.device.hnd, nil)

    vk.DestroySurfaceKHR(rndr.instance, rndr.surface.hnd, nil)
    vk.DestroyInstance(rndr.instance, nil)
}

create_image_view :: proc(
    image: vk.Image,
    format: vk.Format,
    aspect_mask: vk.ImageAspectFlags
) -> (image_view: vk.ImageView, err: Renderer_Err) {
	create_info := vk.ImageViewCreateInfo{
		sType = .IMAGE_VIEW_CREATE_INFO,
		image = image,
		viewType = .D2,
		format = format,
        components = {},
		subresourceRange = {
			aspectMask = aspect_mask,
			baseMipLevel = 0,
			levelCount = 1,
			baseArrayLayer = 0,
			layerCount = 1,
		},
	}

    vk.CreateImageView(rndr.device.hnd, &create_info, nil, &image_view) or_return

    return
}

create_shader_module :: proc(path: string) -> (module: vk.ShaderModule, err: Renderer_Err) {
    data := os.read_entire_file_or_err(path) or_return

    create_info := vk.ShaderModuleCreateInfo{
        sType = .SHADER_MODULE_CREATE_INFO,
        codeSize = len(data),
        pCode = raw_data(transmute([]u32)data)
    }

    vk.CreateShaderModule(rndr.device.hnd, &create_info, nil, &module) or_return

    delete(data)

    return
}

// TODO: use a memory pool/allocator
create_buffer :: proc(
    size: uint,
    usage: vk.BufferUsageFlags,
    mem_props: vk.MemoryPropertyFlags
) -> (buffer: Buffer, err: Renderer_Err) {
    buffer_create_info := vk.BufferCreateInfo{
        sType = .BUFFER_CREATE_INFO,
        size = cast(vk.DeviceSize)size,
        usage = usage,
        sharingMode = .EXCLUSIVE,
        queueFamilyIndexCount = 1,
        pQueueFamilyIndices = raw_data([]u32{u32(rndr.queues[.Graphics].index)})
    }
 
    vk.CreateBuffer(rndr.device.hnd, &buffer_create_info, nil, &buffer.hnd) or_return

    mem_reqs: vk.MemoryRequirements
    vk.GetBufferMemoryRequirements(rndr.device.hnd, buffer.hnd, &mem_reqs)

    mem_type_index := -1

    for _, i in rndr.physical_device.mem_props.memoryTypes {
        if mem_reqs.memoryTypeBits & (1 << u32(i)) != 0 && 
           mem_props <= rndr.physical_device.mem_props.memoryTypes[i].propertyFlags {
            mem_type_index = i
            break
        }
    }

    if mem_type_index == -1 {
        err = .Could_Not_Find_Mem_Type
        return
    }

    alloc_info := vk.MemoryAllocateInfo{
        sType = .MEMORY_ALLOCATE_INFO,
        allocationSize = mem_reqs.size,
        memoryTypeIndex = u32(mem_type_index)
    }

    vk.AllocateMemory(rndr.device.hnd, &alloc_info, nil, &buffer.mem) or_return
    vk.BindBufferMemory(rndr.device.hnd, buffer.hnd, buffer.mem, 0) or_return

    return
}

upload_buffer :: proc(
    data: rawptr,
    size: uint
) -> (dst_buf: Buffer, err: Renderer_Err) {
    dst_buf = create_buffer(
        size,
        {.TRANSFER_DST, .VERTEX_BUFFER},
        {.DEVICE_LOCAL}
    ) or_return

    staging_buf := create_buffer(
        size,
        {.TRANSFER_SRC},
        {.HOST_VISIBLE, .HOST_COHERENT}
    ) or_return

    mapped_data: rawptr
    vk.MapMemory(
        rndr.device.hnd,
        staging_buf.mem,
        0,
        cast(vk.DeviceSize)size,
        {},
        &mapped_data
    ) or_return
    mem.copy(mapped_data, data, int(size))
    vk.UnmapMemory(rndr.device.hnd, staging_buf.mem)

    alloc_info := vk.CommandBufferAllocateInfo{
        sType = .COMMAND_BUFFER_ALLOCATE_INFO,
        commandBufferCount = 1,
        level = .PRIMARY,
        commandPool = rndr.cmd_pool,
    }

    tmp_cmd_buf: vk.CommandBuffer
    vk.AllocateCommandBuffers(rndr.device.hnd, &alloc_info, &tmp_cmd_buf) or_return

    begin_info := vk.CommandBufferBeginInfo{
        sType = .COMMAND_BUFFER_BEGIN_INFO, 
        flags = {.ONE_TIME_SUBMIT},
    }

    vk.BeginCommandBuffer(tmp_cmd_buf, &begin_info) or_return

    region := vk.BufferCopy{
        size = cast(vk.DeviceSize)size,
    }

    vk.CmdCopyBuffer(tmp_cmd_buf, staging_buf.hnd, dst_buf.hnd, 1, &region)

    vk.EndCommandBuffer(tmp_cmd_buf) or_return

    submit_info := vk.SubmitInfo{
        sType = .SUBMIT_INFO,
        commandBufferCount = 1,
        pCommandBuffers = &tmp_cmd_buf
    }

    vk.QueueSubmit(rndr.queues[.Transfer].hnd, 1, &submit_info, VK_NULL_HANDLE) or_return
    vk.QueueWaitIdle(rndr.queues[.Transfer].hnd) or_return

    vk.FreeCommandBuffers(rndr.device.hnd, rndr.cmd_pool, 1, &tmp_cmd_buf)

    vk.DestroyBuffer(rndr.device.hnd, staging_buf.hnd, nil)
    vk.FreeMemory(rndr.device.hnd, staging_buf.mem, nil)

    return
}

free_buffer :: proc(buf: Buffer) {
    if r := vk.DeviceWaitIdle(rndr.device.hnd); r != vk.Result.SUCCESS {
        log.panicf("could not wait for devie: %v", r)
    }

    vk.DestroyBuffer(rndr.device.hnd, buf.hnd, nil)
    vk.FreeMemory(rndr.device.hnd, buf.mem, nil)
}

