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
    let max_iterations = 3000;
    let aa_samples = 1;

    var col = vec3(0.0);

    for (var x_a: i32 = 0; x_a < aa_samples; x_a++){
    for (var y_a: i32 = 0; y_a < aa_samples; y_a++){

        let x_m = map_range(0.0,f32(u.width),-u.scale,u.scale, in.clip_position.x) - u.x_off; //+ (f32(x_a)*(u.x_velocity*(u.scale/10000.0)));
        let y_m = map_range(0.0,f32(u.width),-u.scale,u.scale, in.clip_position.y) - u.y_off; //+ (f32(y_a)*(u.y_velocity*(u.scale/10000.0))); 
            
        var x_norm = 0.0;
        var y_norm = 0.0;
            

        var iteration = 0;

        while (abs(pow(x_norm,2.0)) + (pow(y_norm, 2.0)) < 4.0 && iteration < max_iterations) {
            let x_tmp = pow(x_norm, 2.0) - pow(y_norm, 2.0) + x_m;

            y_norm = 2.0 * x_norm * y_norm + y_m;
            x_norm = x_tmp;

            iteration += 1;
        }
            
        if(iteration == max_iterations) {
            return vec4<f32>();
        }
            
        let f = 20.0;
        let smooth_iter = f32(iteration) + 1.0 - log( log(  pow(x_norm,2.0) + pow(y_norm, 2.0) ) ) / log(2.0);

        // let col_new = vec4(
        //     sin(smooth_iter/f),
        //     cos(smooth_iter/f),
        //     tan(smooth_iter/f),
        //     0.0
        // );

        col += vec3(
            tan(smooth_iter/f),
            cos(smooth_iter/f),
            sin(smooth_iter/f)
        );

    }
    }

    col /= f32(aa_samples*aa_samples);

        // col = col+col_new / f32(a);
    // }

    return vec4(col,0.0);
    // return vec4<f32>(0.,0.,0.,0.);

}
