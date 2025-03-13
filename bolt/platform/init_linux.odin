package platform

init :: proc(width, height: i32) -> bool {
    return wsi_init(width, height)
}

deinit :: proc() {
    wsi_deinit()
}
