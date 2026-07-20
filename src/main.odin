package main
import "core:fmt"
import "core:os"
import "core:math"
import "core:math/linalg"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

// settings
SCR_WIDTH   :: 800;
SCR_HEIGHT  :: 600;

main :: proc() {
    glfw.Init()

    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    window := glfw.CreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL", nil, nil); assert(window != nil)

    glfw.MakeContextCurrent(window)
    glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)

    gl.load_up_to(3,3, glfw.gl_set_proc_address)

    // configure global opengl state
    gl.Enable(gl.DEPTH_TEST);

    vertices:= [?]Vertex {
        {position={-0.5, -0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 0.0}},
        {position={ 0.5, -0.5, -0.5}, color={1,1,1}, tex_coord={1.0, 0.0}},
        {position={ 0.5,  0.5, -0.5}, color={1,1,1}, tex_coord={1.0, 1.0}},
        {position={ 0.5,  0.5, -0.5}, color={1,1,1}, tex_coord={1.0, 1.0}},
        {position={-0.5,  0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 1.0}},
        {position={-0.5, -0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 0.0}},
        {position={-0.5, -0.5,  0.5}, color={1,1,1}, tex_coord={0.0, 0.0}},
        {position={ 0.5, -0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 0.0}},
        {position={ 0.5,  0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 1.0}},
        {position={ 0.5,  0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 1.0}},
        {position={-0.5,  0.5,  0.5}, color={1,1,1}, tex_coord={0.0, 1.0}},
        {position={-0.5, -0.5,  0.5}, color={1,1,1}, tex_coord={0.0, 0.0}},
        {position={-0.5,  0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 0.0}},
        {position={-0.5,  0.5, -0.5}, color={1,1,1}, tex_coord={1.0, 1.0}},
        {position={-0.5, -0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 1.0}},
        {position={-0.5, -0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 1.0}},
        {position={-0.5, -0.5,  0.5}, color={1,1,1}, tex_coord={0.0, 0.0}},
        {position={-0.5,  0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 0.0}},
        {position={ 0.5,  0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 0.0}},
        {position={ 0.5,  0.5, -0.5}, color={1,1,1}, tex_coord={1.0, 1.0}},
        {position={ 0.5, -0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 1.0}},
        {position={ 0.5, -0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 1.0}},
        {position={ 0.5, -0.5,  0.5}, color={1,1,1}, tex_coord={0.0, 0.0}},
        {position={ 0.5,  0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 0.0}},
        {position={-0.5, -0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 1.0}},
        {position={ 0.5, -0.5, -0.5}, color={1,1,1}, tex_coord={1.0, 1.0}},
        {position={ 0.5, -0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 0.0}},
        {position={ 0.5, -0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 0.0}},
        {position={-0.5, -0.5,  0.5}, color={1,1,1}, tex_coord={0.0, 0.0}},
        {position={-0.5, -0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 1.0}},
        {position={-0.5,  0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 1.0}},
        {position={ 0.5,  0.5, -0.5}, color={1,1,1}, tex_coord={1.0, 1.0}},
        {position={ 0.5,  0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 0.0}},
        {position={ 0.5,  0.5,  0.5}, color={1,1,1}, tex_coord={1.0, 0.0}},
        {position={-0.5,  0.5,  0.5}, color={1,1,1}, tex_coord={0.0, 0.0}},
        {position={-0.5,  0.5, -0.5}, color={1,1,1}, tex_coord={0.0, 1.0}},
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

    indices:= [?]u32 {
        0, 1, 3, // first triangle
        1, 2, 3  // second triangle
    };

    VBO, VAO, EBO: u32

    shader_program := shader_program_init({
        vert_shader_path = "resources/shaders/shader.vert",
        frag_shader_path = "resources/shaders/shader.frag"
    })

    shader_arrays_init(&VAO, &VBO, &EBO, vertices[:], indices[:])


    wall_texture := texture_init({
        file_path       = "resources/textures/wall.jpg",
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


    gl.UseProgram(shader_program); // don't forget to activate/use the shader before setting uniforms!
    gl.Uniform1i(gl.GetUniformLocation(shader_program, "texture1"), 0);
    gl.Uniform1i(gl.GetUniformLocation(shader_program, "texture2"), 1);

    for !glfw.WindowShouldClose(window) {
        process_input(window);

        gl.ClearColor(0.2, 0.3, 0.3, 1.0);
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

        // bind Textures
        gl.ActiveTexture(gl.TEXTURE0);
        gl.BindTexture(gl.TEXTURE_2D, wall_texture);
        gl.ActiveTexture(gl.TEXTURE1);
        gl.BindTexture(gl.TEXTURE_2D, awesomeface_texture);


        gl.UseProgram(shader_program);


        view        := mat4_translate({0,0,-3})
        projection  := mat4_perspective(45, SCR_WIDTH/SCR_HEIGHT, 0.1, 100)





        // model_loc := gl.GetUniformLocation(shader_program, "model");
        // gl.UniformMatrix4fv(model_loc, 1, gl.FALSE, &model[0][0]);
        view_loc := gl.GetUniformLocation(shader_program, "view");
        gl.UniformMatrix4fv(view_loc, 1, gl.FALSE, &view[0][0]);
        projection_loc := gl.GetUniformLocation(shader_program, "projection");
        gl.UniformMatrix4fv(projection_loc, 1, gl.FALSE, &projection[0][0]);

        gl.BindVertexArray(VAO);
        for pos in cube_positions {
            model  := Mat4_Identity
            trans  := mat4_translate(pos)
            rot    := mat4_rotate_euler(f32(glfw.GetTime()) * 20, {1, 0.3, 0.5})
            model   = trans * rot
            model_loc := gl.GetUniformLocation(shader_program, "model");
            gl.UniformMatrix4fv(model_loc, 1, gl.FALSE, &model[0][0]);
            gl.DrawArrays(gl.TRIANGLES, 0, 36)
        }

        glfw.SwapBuffers(window);
        glfw.PollEvents();
    }

    gl.DeleteVertexArrays(1, &VAO)
    gl.DeleteBuffers(1, &VBO)
    gl.DeleteBuffers(1, &EBO)
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
}