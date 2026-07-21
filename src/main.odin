package main
import "core:fmt"
import "core:os"
import "core:math"
import "core:math/linalg"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"
import "base:runtime"

// settings
SCR_WIDTH   :: 1920;
SCR_HEIGHT  :: 1080;

delta_time      : f64 = 0.0
last_frame      : f64 = 0.0
mouse_last_x    : f64 = f64(SCR_WIDTH)/2
mouse_last_y    : f64 = f64(SCR_HEIGHT)/2
first_mouse     := true


main :: proc() {
    glfw.Init()

    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    window := glfw.CreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL", nil, nil); assert(window != nil)

    glfw.MakeContextCurrent(window)
    glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)
    glfw.SetCursorPosCallback(window, mouse_callback)
    glfw.SetScrollCallback(window, scroll_callback)

    gl.load_up_to(3,3, glfw.gl_set_proc_address)

    // configure global opengl state
    gl.Enable(gl.DEPTH_TEST);

    vertices:= [?]Vertex {
        {position={-0.5, -0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 0.0}, normal={0,0,-1}},
        {position={ 0.5, -0.5, -0.5}, color={1,1,1}, tex_coord={1.0, 0.0}, normal={0,0,-1}},
        {position={ 0.5,  0.5, -0.5}, color={1,1,1}, tex_coord={1.0, 1.0}, normal={0,0,-1}},
        {position={ 0.5,  0.5, -0.5}, color={1,1,1}, tex_coord={1.0, 1.0}, normal={0,0,-1}},
        {position={-0.5,  0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 1.0}, normal={0,0,-1}},
        {position={-0.5, -0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 0.0}, normal={0,0,-1}},

        {position={-0.5, -0.5,  0.5}, color={1,1,1}, tex_coord={0.0, 0.0}, normal={0,0,1}},
        {position={ 0.5, -0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 0.0}, normal={0,0,1}},
        {position={ 0.5,  0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 1.0}, normal={0,0,1}},
        {position={ 0.5,  0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 1.0}, normal={0,0,1}},
        {position={-0.5,  0.5,  0.5}, color={1,1,1}, tex_coord={0.0, 1.0}, normal={0,0,1}},
        {position={-0.5, -0.5,  0.5}, color={1,1,1}, tex_coord={0.0, 0.0}, normal={0,0,1}},

        {position={-0.5,  0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 0.0}, normal={-1,0,0}},
        {position={-0.5,  0.5, -0.5}, color={1,1,1}, tex_coord={1.0, 1.0}, normal={-1,0,0}},
        {position={-0.5, -0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 1.0}, normal={-1,0,0}},
        {position={-0.5, -0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 1.0}, normal={-1,0,0}},
        {position={-0.5, -0.5,  0.5}, color={1,1,1}, tex_coord={0.0, 0.0}, normal={-1,0,0}},
        {position={-0.5,  0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 0.0}, normal={-1,0,0}},

        {position={ 0.5,  0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 0.0}, normal={1,0,0}},
        {position={ 0.5,  0.5, -0.5}, color={1,1,1}, tex_coord={1.0, 1.0}, normal={1,0,0}},
        {position={ 0.5, -0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 1.0}, normal={1,0,0}},
        {position={ 0.5, -0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 1.0}, normal={1,0,0}},
        {position={ 0.5, -0.5,  0.5}, color={1,1,1}, tex_coord={0.0, 0.0}, normal={1,0,0}},
        {position={ 0.5,  0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 0.0}, normal={1,0,0}},

        {position={-0.5, -0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 1.0}, normal={0,-1,0}},
        {position={ 0.5, -0.5, -0.5}, color={1,1,1}, tex_coord={1.0, 1.0}, normal={0,-1,0}},
        {position={ 0.5, -0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 0.0}, normal={0,-1,0}},
        {position={ 0.5, -0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 0.0}, normal={0,-1,0}},
        {position={-0.5, -0.5,  0.5}, color={1,1,1}, tex_coord={0.0, 0.0}, normal={0,-1,0}},
        {position={-0.5, -0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 1.0}, normal={0,-1,0}},

        {position={-0.5,  0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 1.0}, normal={0,-1,0}},
        {position={ 0.5,  0.5, -0.5}, color={1,1,1}, tex_coord={1.0, 1.0}, normal={0,-1,0}},
        {position={ 0.5,  0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 0.0}, normal={0,-1,0}},
        {position={ 0.5,  0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 0.0}, normal={0,-1,0}},
        {position={-0.5,  0.5,  0.5}, color={1,1,1}, tex_coord={0.0, 0.0}, normal={0,-1,0}},
        {position={-0.5,  0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 1.0}, normal={0,-1,0}},
    };

    cube_positions := [?]Vec3 {
        {0.0,  0.0,   0.0},
        {2.0,  5.0, -15.0},
        {1.5, -2.2,  -2.5},
        {3.8, -2.0, -12.3},
        {2.4, -0.4,  -3.5},
        {1.7,  3.0,  -7.5},
        {1.3, -2.0,  -2.5},
        {1.5,  2.0,  -2.5},
        {1.5,  0.2,  -1.5},
        {1.3,  1.0,  -1.5},
    }

    // indices:= [?]u32 {
    //     0, 1, 3, // first triangle
    //     1, 2, 3  // second triangle
    // };

    VBO, cube_VAO: u32
    // VAO, EBO : u32


    basic_shader := shader_program_init({
        vert_shader_path = "resources/shaders/shader.vert",
        frag_shader_path = "resources/shaders/shader.frag"
    })

    lighting_shader := shader_program_init({
        vert_shader_path = "resources/shaders/basic_lighting.vert",
        frag_shader_path = "resources/shaders/basic_lighting.frag"
    })

    light_cube_shader := shader_program_init({
        vert_shader_path = "resources/shaders/shader.vert",
        frag_shader_path = "resources/shaders/light_cube.frag"
    })

    // setup_VAO(&VAO)
    // gl.BindVertexArray(VAO)
    // setup_VBO(&VBO, vertices[:])
    // setup_EBO(&EBO, indices[:])
    // setup_attributes()
    // gl.BindVertexArray(0)

    setup_VAO(&cube_VAO)
    gl.BindVertexArray(cube_VAO)
    setup_VBO(&VBO, vertices[:])
    // setup_EBO(&EBO, indices[:])
    setup_attributes()
    gl.BindVertexArray(0)

    wall_texture := texture_init({
        file_path       = "resources/textures/wall.jpg",
        wrap_s          = .REPEAT,
        wrap_t          = .REPEAT,
        filter_min      = .LINEAR,
        filter_max      = .LINEAR,
        image_format    = .RGB
    })

    ground_texture := texture_init({
        file_path       = "resources/textures/prototype/texture_03.png",
        wrap_s          = .REPEAT,
        wrap_t          = .REPEAT,
        filter_min      = .LINEAR,
        filter_max      = .LINEAR,
        image_format    = .RGB
    })

    awesomeface_texture := texture_init({
        file_path       = "resources/textures/awesomeface.png",
        wrap_s          = .REPEAT,
        wrap_t          = .REPEAT,
        filter_min      = .LINEAR,
        filter_max      = .LINEAR,
        image_format    = .RGBA
    })


    glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_DISABLED);

    for !glfw.WindowShouldClose(window) {
        current_frame := glfw.GetTime();
        delta_time = current_frame - last_frame
        last_frame = current_frame

        process_input(window);

        gl.ClearColor(0.2, 0.3, 0.3, 1.0);
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

        gl.UseProgram(basic_shader);

        view := linalg.matrix4_look_at_f32(camera_pos, camera_pos + camera_front, camera_up);
        projection  := mat4_perspective(camera_fov, f32(SCR_WIDTH)/f32(SCR_HEIGHT), 0.1, 100)

        ground_pos  := Vec3{0,-1,0}
        model       := Mat4_Identity
        trans       := mat4_translate(ground_pos)
        // rot      := mat4_rotate_euler(f32(glfw.GetTime()) * 20, {1, 0.3, 0.5})
        scale       := mat4_scale({20, 1, 20})
        model        = trans * scale

        gl.BindVertexArray(cube_VAO);

        gl.UniformMatrix4fv(gl.GetUniformLocation(basic_shader, "view"), 1, gl.FALSE, &view[0][0]);
        gl.UniformMatrix4fv(gl.GetUniformLocation(basic_shader, "projection"), 1, gl.FALSE, &projection[0][0]);
        gl.UniformMatrix4fv(gl.GetUniformLocation(basic_shader, "model"), 1, gl.FALSE, &model[0][0]);

        gl.Uniform1i(gl.GetUniformLocation(basic_shader, "texture1"), 0);
        gl.ActiveTexture(gl.TEXTURE0);
        gl.BindTexture(gl.TEXTURE_2D, ground_texture);

        gl.DrawArrays(gl.TRIANGLES, 0, 36)

        // bind Textures
        gl.Uniform1i(gl.GetUniformLocation(basic_shader, "texture1"), 0);
        gl.ActiveTexture(gl.TEXTURE0);
        gl.BindTexture(gl.TEXTURE_2D, wall_texture);

        model_loc := gl.GetUniformLocation(basic_shader, "model");
        for pos in cube_positions {
            model  := Mat4_Identity
            trans  := mat4_translate(pos)
            rot    := mat4_rotate_euler(f32(glfw.GetTime()) * 20, {1, 0.3, 0.5})
            scale  := mat4_scale({1, 1, 1})
            model   = trans * rot * scale

            gl.UniformMatrix4fv(model_loc, 1, gl.FALSE, &model[0][0]);
            gl.DrawArrays(gl.TRIANGLES, 0, 36)
        }


        // light cube
        gl.UseProgram(light_cube_shader)
        light_pos := Vec3{4,2,1}

        model       = Mat4_Identity
        trans       = mat4_translate(light_pos)
        scale       = mat4_scale({0.5, 0.5, 0.5})
        model       = trans * scale

        gl.UniformMatrix4fv(gl.GetUniformLocation(light_cube_shader, "view"), 1, gl.FALSE, &view[0][0]);
        gl.UniformMatrix4fv(gl.GetUniformLocation(light_cube_shader, "projection"), 1, gl.FALSE, &projection[0][0]);
        gl.UniformMatrix4fv(gl.GetUniformLocation(light_cube_shader, "model"), 1, gl.FALSE, &model[0][0]);

        gl.DrawArrays(gl.TRIANGLES, 0, 36)


        // lighting
        gl.UseProgram(lighting_shader)

        model       = Mat4_Identity
        trans       = mat4_translate({2,2,2})
        scale       = mat4_scale({2, 2, 2})
        model       = trans * scale
        object_color := Vec3{1,0.5,0.31}; light_color := Vec3{1,1,1}


        gl.UniformMatrix4fv(gl.GetUniformLocation(lighting_shader, "view"), 1, gl.FALSE, &view[0][0]);
        gl.UniformMatrix4fv(gl.GetUniformLocation(lighting_shader, "projection"), 1, gl.FALSE, &projection[0][0]);
        gl.UniformMatrix4fv(gl.GetUniformLocation(lighting_shader, "model"), 1, gl.FALSE, &model[0][0]);
        gl.Uniform3fv(gl.GetUniformLocation(lighting_shader, "objectColor"), 1, &object_color[0]);
        gl.Uniform3fv(gl.GetUniformLocation(lighting_shader, "lightColor"), 1, &light_color[0]);
        gl.Uniform3fv(gl.GetUniformLocation(lighting_shader, "lightPos"), 1, &light_pos[0]);

        gl.DrawArrays(gl.TRIANGLES, 0, 36)


        gl.BindVertexArray(0)
        glfw.SwapBuffers(window);
        glfw.PollEvents();
    }

    gl.DeleteVertexArrays(1, &cube_VAO)
    gl.DeleteBuffers(1, &VBO)
    // gl.DeleteBuffers(1, &EBO)
    glfw.DestroyWindow(window)
    glfw.Terminate()
}


framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, w,h: i32) {
    gl.Viewport(0,0,w,h)
}

process_input :: proc(window: glfw.WindowHandle) {
    if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
        glfw.SetWindowShouldClose(window, true)
    }

    if (glfw.GetKey(window, glfw.KEY_LEFT_SHIFT) == glfw.PRESS) {
        camera_speed = 5 * delta_time
    } else {
        camera_speed = 2.5 * delta_time
    }
    if glfw.GetKey(window, glfw.KEY_W) == glfw.PRESS {
        camera_pos += f32(camera_speed) * camera_front;
    }
    if glfw.GetKey(window, glfw.KEY_S) == glfw.PRESS{
        camera_pos -= f32(camera_speed) * camera_front;
    }
    if glfw.GetKey(window, glfw.KEY_A) == glfw.PRESS {
        camera_pos -= linalg.normalize(linalg.cross(camera_front, camera_up)) * f32(camera_speed);
    }
    if (glfw.GetKey(window, glfw.KEY_D) == glfw.PRESS) {
        camera_pos += linalg.normalize(linalg.cross(camera_front, camera_up)) * f32(camera_speed);
    }

    camera_pos.y = 2
}


mouse_callback :: proc "c"(window: glfw.WindowHandle, xpos, ypos: f64) {
    context = runtime.default_context()

    xoffset := xpos - mouse_last_x
    yoffset := mouse_last_y - ypos
    mouse_last_x = xpos
    mouse_last_y = ypos

    if (first_mouse) {
        mouse_last_x = xpos;
        mouse_last_y = ypos;
        first_mouse = false;
    }


    xoffset = xoffset * f64(camera_sensivity)
    yoffset = yoffset * f64(camera_sensivity)

    camera_yaw += f32(xoffset)
    camera_pitch += f32(yoffset)

    if camera_pitch > 89.0 {
        camera_pitch = 89.0
    }
    if camera_pitch < -89.0 {
        camera_pitch = -89.0
    }

    update_camera_direction()
}

scroll_callback :: proc "c" (window: glfw.WindowHandle, xoffset, yoffset: f64) {
    camera_fov -= f32(yoffset)
    if camera_fov < 1.0 do camera_fov = 1.0
    if camera_fov > 45.0 do camera_fov = 45.0
}