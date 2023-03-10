// Uniform variables
struct Uniforms {
    x_off: f32,
    y_off: f32,
    scale: f32,
    width: u32,
    height: u32,
    y_velocity: f32,
    x_velocity: f32,
};

@group(0) @binding(0)
var<uniform> u: Uniforms;


// Vertex shader
struct VertexInput {
    @location(0) position: vec3<f32>,
    @location(1) color: vec3<f32>,
};

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) color: vec3<f32>,
};

@vertex
fn vs_main(model: VertexInput) -> VertexOutput {
    var out: VertexOutput;
    out.color = model.color;
    out.clip_position = vec4<f32>(model.position, 1.0);
    return out;
}

fn map_range(from_range_min: f32, from_range_max: f32, to_range_min: f32, to_range_max: f32, s: f32) -> f32 {
    return to_range_min + (s - from_range_min) * (to_range_max - to_range_min) / (from_range_max - from_range_min);
}

// Fragment shader
@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
 
    let c = vec2<f32>(
        map_range(0.0,f32(u.width),-u.scale,u.scale, in.clip_position.x) - u.x_off,
        map_range(0.0,f32(u.width),-u.scale,u.scale, in.clip_position.y) - u.y_off
    );
    
    var z = vec2<f32>(0.0, 0.0);
    var n = 0;

    for (var i: i32 = 0; i < 1000; i++) {
        if (length(z) >= 2.0) {
            break;
        }

        z = vec2<f32>(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + c;
        n = i;
    }

    let f = 20.0;
    let smooth_iter = f32(n) + 1.0 - log2(log2(length(z)));

    return vec4<f32>(
        sin(smooth_iter/f),
        cos(smooth_iter/f),
        tan(smooth_iter/f),
        1.0
    );
}
