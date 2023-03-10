// use winit::event_loop::EventLoop;
use gpu_fractals::run;


fn main() {
    // let event_loop = EventLoop::new();
    // let window = winit::window::Window::new(&event_loop).unwrap();
    // #[cfg(not(target_arch = "wasm32"))]
    // {
        // env_logger::init();
        // Temporarily avoid srgb formats for the swapchain on the web
        pollster::block_on(run());
    // }
}