package renderer

import vk "vendored:vulkan"

image_idx: u32

draw_begin :: proc(cmd_buf: vk.CommandBuffer) -> Renderer_Err {
    using renderer

    vk.WaitForFences(device.hnd, 1, &in_flight_fence, true, max(u64)) or_return
    vk.ResetFences(device.hnd, 1, &in_flight_fence) or_return

    res := vk.AcquireNextImageKHR(
        device.hnd,
        swapchain.hnd,
        max(u64), 
        image_avail_sem,
        VK_NULL_HANDLE,
        &image_idx
    )

    if res == vk.Result.ERROR_OUT_OF_DATE_KHR || res == vk.Result.SUBOPTIMAL_KHR {
        vk.DeviceWaitIdle(device.hnd) or_return
        destroy_swapchain()
        create_swapchain()
        return nil
    } else if res != vk.Result.SUCCESS {
        return res
    }

    command_buffer_begin_info := vk.CommandBufferBeginInfo{
        sType = .COMMAND_BUFFER_BEGIN_INFO,
        pInheritanceInfo = nil
    }

    vk.BeginCommandBuffer(cmd_buf, &command_buffer_begin_info) or_return

    render_pass_begin_info := vk.RenderPassBeginInfo{
        sType = .RENDER_PASS_BEGIN_INFO,
        renderPass = render_pass.hnd,
        framebuffer = render_pass.framebuffers[image_idx],
        renderArea = {
            offset = {0,0},
            extent = swapchain.extent
        },
        clearValueCount = 1,
        pClearValues = &vk.ClearValue{
            color = {
                float32 = {1.0, 0.0, 0.0, 1.0}
            }
        }
    }

    vk.CmdBeginRenderPass(cmd_buf, &render_pass_begin_info, .INLINE)

	viewport := vk.Viewport {
		x        = 0.0,
		y        = 0.0,
		width    = f32(swapchain.extent.width),
		height   = f32(swapchain.extent.height),
		minDepth = 0.0,
		maxDepth = 1.0,
	}

	vk.CmdSetViewport(cmd_buf, 0, 1, &viewport)

	scissor := vk.Rect2D {
		offset = {0, 0},
		extent = swapchain.extent,
	}

	vk.CmdSetScissor(cmd_buf, 0, 1, &scissor)


    return nil
}

draw_end :: proc(cmd_buf: vk.CommandBuffer) -> Renderer_Err {
    using renderer

    vk.CmdDraw(cmd_buf, 3, 1, 0, 0)

    vk.CmdEndRenderPass(cmd_buf)

    vk.EndCommandBuffer(cmd_buf) or_return

    cmd_bufs := []vk.CommandBuffer{cmd_buf}

    submit_info := vk.SubmitInfo {
        sType                = .SUBMIT_INFO,
        waitSemaphoreCount   = 1,
        pWaitSemaphores      = &image_avail_sem,
        pWaitDstStageMask    = &vk.PipelineStageFlags{.COLOR_ATTACHMENT_OUTPUT},
        commandBufferCount   = 1,
        pCommandBuffers      = raw_data(cmd_bufs),
        signalSemaphoreCount = 1,
        pSignalSemaphores    = &render_fin_sem,
    }

    vk.QueueSubmit(queues[.Graphics].hnd, 1, &submit_info, in_flight_fence) or_return

    present_info := vk.PresentInfoKHR{
        sType = .PRESENT_INFO_KHR,
        waitSemaphoreCount = 1,
        pWaitSemaphores = &render_fin_sem,
        swapchainCount = 1,
        pSwapchains = &swapchain.hnd,
        pImageIndices = &image_idx,
        pResults = nil
    }

    vk.QueuePresentKHR(queues[.Present].hnd, &present_info) or_return

    return nil
}
