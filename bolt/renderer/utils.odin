package renderer

import "core:log"
import "core:mem"
import "core:os"

import vk "vendored:vulkan"

Buffer :: struct {
    hnd: vk.Buffer,
    mem: vk.DeviceMemory
}

Image :: struct {
    hnd: vk.Image,
    mem: vk.DeviceMemory,
    view: vk.ImageView
}

create_image :: proc(
    width, height: u32,
    format: vk.Format,
    tiling: vk.ImageTiling,
    usage: vk.ImageUsageFlags,
    mem_props: vk.MemoryPropertyFlags,
    aspect: vk.ImageAspectFlags
) -> (image: Image, err: Renderer_Err) {
    create_info := vk.ImageCreateInfo{
        sType = .IMAGE_CREATE_INFO,
        imageType = .D2,
        extent = vk.Extent3D{
            width = width,
            height = height,
            depth = 1
        },
        mipLevels = 1,
        arrayLayers = 1,
        samples = {._1},
        format = format,
        tiling = tiling,
        usage = usage,
        sharingMode = .EXCLUSIVE,
        initialLayout = .UNDEFINED
    }

    vk.CreateImage(rndr.device.hnd, &create_info, nil, &image.hnd) or_return

    mem_reqs: vk.MemoryRequirements
    vk.GetImageMemoryRequirements(rndr.device.hnd, image.hnd, &mem_reqs)

    alloc_info := vk.MemoryAllocateInfo{
        sType = .MEMORY_ALLOCATE_INFO,
        allocationSize = mem_reqs.size,
        memoryTypeIndex = find_mem_type(mem_reqs.memoryTypeBits, mem_props) or_return
    }

    vk.AllocateMemory(rndr.device.hnd, &alloc_info, nil, &image.mem) or_return
    vk.BindImageMemory(rndr.device.hnd, image.hnd, image.mem, 0) or_return

    image.view = create_image_view(image.hnd, format, aspect) or_return

    return
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

free_image :: proc(image: Image) {
    vk.DestroyImageView(rndr.device.hnd, image.view, nil)
    vk.DestroyImage(rndr.device.hnd, image.hnd, nil)
    vk.FreeMemory(rndr.device.hnd, image.mem, nil)
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
    size: uint,
    usage: vk.BufferUsageFlags
) -> (dst_buf: Buffer, err: Renderer_Err) {
    dst_buf = create_buffer(
        size,
        {.TRANSFER_DST} | usage,
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

find_mem_type :: proc(type_filter: u32, mem_props: vk.MemoryPropertyFlags) -> (u32, Renderer_Err) {
    for _, i in rndr.physical_device.mem_props.memoryTypes {
        if type_filter & (1 << u32(i)) != 0 && 
           mem_props <= rndr.physical_device.mem_props.memoryTypes[i].propertyFlags {
            return u32(i), nil
        }
    }

    return 0, .Could_Not_Find_Mem_Type
}

find_supported_fmt :: proc(fmts: []vk.Format, tiling: vk.ImageTiling, feats: vk.FormatFeatureFlags) -> (vk.Format, Renderer_Err) {
    for fmt in fmts {
        fmt_props: vk.FormatProperties
        vk.GetPhysicalDeviceFormatProperties(rndr.physical_device.hnd, fmt, &fmt_props)

        if (tiling == .LINEAR && fmt_props.linearTilingFeatures >= feats) ||
           (tiling == .OPTIMAL && fmt_props.optimalTilingFeatures >= feats) {
            return fmt, nil
        }
    }

    return {}, .Could_Not_Find_Supported_Fmt
}
