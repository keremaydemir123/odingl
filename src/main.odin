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

    vertices:= [?]f32 {
        // positions       // colors        // texture coords
         0.5,  0.5, 0.0,   1.0, 0.0, 0.0,   1.0, 1.0, // top right
         0.5, -0.5, 0.0,   0.0, 1.0, 0.0,   1.0, 0.0, // bottom right
        -0.5, -0.5, 0.0,   0.0, 0.0, 1.0,   0.0, 0.0, // bottom left
        -0.5,  0.5, 0.0,   1.0, 1.0, 0.0,   0.0, 1.0  // top left
    };

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
        gl.Clear(gl.COLOR_BUFFER_BIT);

        // bind Textures
        gl.ActiveTexture(gl.TEXTURE0);
        gl.BindTexture(gl.TEXTURE_2D, wall_texture);
        gl.ActiveTexture(gl.TEXTURE1);
        gl.BindTexture(gl.TEXTURE_2D, awesomeface_texture);

        transform   := linalg.Matrix4f32(1)
        translation := linalg.matrix4_translate_f32({0.5,-0.5,0})
        rotation    := linalg.matrix4_rotate_f32(f32(glfw.GetTime()), {0,0,1})
        scale       := linalg.matrix4_scale_f32({2,2,2})
        transform    = translation * rotation * scale // order !!

        gl.UseProgram(shader_program);

        transform_loc := gl.GetUniformLocation(shader_program, "transform");
        gl.UniformMatrix4fv(transform_loc, 1, gl.FALSE, &transform[0][0]);

        gl.BindVertexArray(VAO);
        gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, rawptr(uintptr(0)));

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