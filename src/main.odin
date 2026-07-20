package main
import "core:fmt"
import "core:os"
import "core:math"
import "core:math/linalg"
import stbi "vendor:stb/image"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"


// settings
SCR_WIDTH   :: 800;
SCR_HEIGHT  :: 600;

Vec4 :: linalg.Vector4f32


main :: proc() {
    glfw.Init()
    defer glfw.Terminate()

    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    window := glfw.CreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL", nil, nil)
    assert(window != nil)
    defer glfw.DestroyWindow(window)

    glfw.MakeContextCurrent(window)
    glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)

    gl.load_up_to(3,3, glfw.gl_set_proc_address)

    // SHADERS
    vert_shader_path: string = "resources/shaders/shader.vert"
    frag_shader_path: string = "resources/shaders/shader.frag"

    vertex_source_bytes, fragment_source_bytes: []byte
    err: os.Error

    success: i32
    info_log: [512]u8

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

    // VERTEX SHADER
    vertex_source_bytes, err = os.read_entire_file_from_path(vert_shader_path, context.temp_allocator)
    if err != nil {
        fmt.println("ERROR::SHADER::VERTEX::FILE_READ:", vert_shader_path)
    }
    vertex_source := cstring(raw_data(vertex_source_bytes))

    vertex_shader := gl.CreateShader(gl.VERTEX_SHADER)
    gl.ShaderSource(vertex_shader, 1, &vertex_source , nil)
    gl.CompileShader(vertex_shader)


    gl.GetShaderiv(vertex_shader, gl.COMPILE_STATUS, &success)
    if success == 0 {
        gl.GetShaderInfoLog(vertex_shader, 512, nil, &info_log[0])
        fmt.println("ERROR::SHADER::VERTEX::COMPILATION_FAILED: %s, error: ", vert_shader_path, cstring(&info_log[0]))
    }

    // FRAGMENT_SHADER
    fragment_source_bytes, err = os.read_entire_file_from_path(frag_shader_path, context.temp_allocator)
    if err != nil {
        fmt.println("ERROR::SHADER::FRAGMENT::FILE_READ:", frag_shader_path)
    }
    fragment_source := cstring(raw_data(fragment_source_bytes))

    fragment_shader := gl.CreateShader(gl.FRAGMENT_SHADER)
    gl.ShaderSource(fragment_shader, 1, &fragment_source , nil)
    gl.CompileShader(fragment_shader)

    gl.GetShaderiv(fragment_shader, gl.COMPILE_STATUS, &success)
    if success == 0 {
        fmt.println("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED: %s, error: ", frag_shader_path, cstring(&info_log[0]))
    }
    // SHADER PROGRAM
    program := gl.CreateProgram()
    gl.AttachShader(program, vertex_shader)
    gl.AttachShader(program, fragment_shader)
    gl.LinkProgram(program)

    gl.GetProgramiv(program, gl.LINK_STATUS, &success)

    if success == 0 {
        gl.GetProgramInfoLog(program, 512, nil, &info_log[0])
        fmt.eprintfln("ERROR::SHADER::PROGRAM::LINKING_FAILED %s", cstring(&info_log[0]))
    }

    gl.DeleteShader(vertex_shader)
    gl.DeleteShader(fragment_shader)

    gl.GenVertexArrays(1, &VAO);
    defer gl.DeleteVertexArrays(1, &VAO)
    gl.GenBuffers(1, &VBO);
    defer gl.DeleteBuffers(1, &VBO)
    gl.GenBuffers(1, &EBO);
    defer gl.DeleteBuffers(1, &EBO)

    gl.BindVertexArray(VAO);

    gl.BindBuffer(gl.ARRAY_BUFFER, VBO);
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), raw_data(vertices[:]), gl.STATIC_DRAW);

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, EBO);
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(indices), raw_data(indices[:]), gl.STATIC_DRAW);

    // position attribute
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 0);
    gl.EnableVertexAttribArray(0);
    // color attribute
    gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 8 * size_of(f32), (3 * size_of(f32)));
    gl.EnableVertexAttribArray(1);
    // texture coord attribute
    gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, 8 * size_of(f32), (6 * size_of(f32)));
    gl.EnableVertexAttribArray(2);


    // TEXTURE
    width, height, nrChannels: i32
    wall_texture_file_path: cstring = "resources/textures/wall.jpg"
    wall_texture: u32
    gl.GenTextures(1, &wall_texture)
    gl.BindTexture(gl.TEXTURE_2D, wall_texture)
    // set the texture wrapping parameters
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);	// set texture wrapping to GL_REPEAT (default wrapping method)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
    // set texture filtering parameters
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

    stbi.set_flip_vertically_on_load(1)
    data : = stbi.load(wall_texture_file_path, &width, &height, &nrChannels, 0);
    if data != nil {
        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, width, height, 0, gl.RGB, gl.UNSIGNED_BYTE, data)
        gl.GenerateMipmap(gl.TEXTURE_2D)
    } else {
        fmt.eprintfln("ERROR::TEXTURE::LOAD: %v", wall_texture_file_path)
    }
    stbi.image_free(data)


    awesomeface_texture_file_path: cstring = "resources/textures/awesomeface.png"
    awesomeface_texture: u32
    gl.GenTextures(1, &awesomeface_texture)
    gl.BindTexture(gl.TEXTURE_2D, awesomeface_texture)
    // set the texture wrapping parameters
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);	// set texture wrapping to GL_REPEAT (default wrapping method)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
    // set texture filtering parameters
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

    data = stbi.load(awesomeface_texture_file_path, &width, &height, &nrChannels, 0);
    if data != nil {
        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, data)
        gl.GenerateMipmap(gl.TEXTURE_2D)
    } else {
        fmt.eprintfln("ERROR::TEXTURE::LOAD: %v", awesomeface_texture_file_path)
    }
    stbi.image_free(data)

    gl.UseProgram(program); // don't forget to activate/use the shader before setting uniforms!
    gl.Uniform1i(gl.GetUniformLocation(program, "texture1"), 0);
    gl.Uniform1i(gl.GetUniformLocation(program, "texture2"), 1);

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

        gl.UseProgram(program);

        transform_loc := gl.GetUniformLocation(program, "transform");
        gl.UniformMatrix4fv(transform_loc, 1, gl.FALSE, &transform[0][0]);

        gl.BindVertexArray(VAO);
        gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, rawptr(uintptr(0)));

        glfw.SwapBuffers(window);
        glfw.PollEvents();
    }
}


framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, w,h: i32) {
    gl.Viewport(0,0,w,h)
}

process_input :: proc(window: glfw.WindowHandle) {
    if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
        glfw.SetWindowShouldClose(window, true)
    }
}