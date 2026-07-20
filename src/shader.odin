package main
import "core:os"
import "core:fmt"
import gl "vendor:OpenGL"


ShaderInitProps :: struct {
    vert_shader_path, frag_shader_path: string
}

Vertex :: struct {
    position    : [3]f32,
    color       : [3]f32,
    tex_coord   : [2]f32
}

shader_program_init :: proc(props: ShaderInitProps) -> u32 {
    vertex_source_bytes, fragment_source_bytes : []byte
    success: i32
    err: os.Error
    info_log: [512]u8


    // VERTEX SHADER
    vertex_source_bytes, err = os.read_entire_file_from_path(props.vert_shader_path, context.temp_allocator)
    if err != nil {
        fmt.println("ERROR::SHADER::VERTEX::FILE_READ:", props.vert_shader_path)
    }
    vertex_source := cstring(raw_data(vertex_source_bytes))

    vertex_shader := gl.CreateShader(gl.VERTEX_SHADER)
    gl.ShaderSource(vertex_shader, 1, &vertex_source , nil)
    gl.CompileShader(vertex_shader)


    gl.GetShaderiv(vertex_shader, gl.COMPILE_STATUS, &success)
    if success == 0 {
        gl.GetShaderInfoLog(vertex_shader, 512, nil, &info_log[0])
        fmt.println("ERROR::SHADER::VERTEX::COMPILATION_FAILED: %s, error: ", props.vert_shader_path, cstring(&info_log[0]))
    }

    // FRAGMENT_SHADER
    fragment_source_bytes, err = os.read_entire_file_from_path(props.frag_shader_path, context.temp_allocator)
    if err != nil {
        fmt.println("ERROR::SHADER::FRAGMENT::FILE_READ:", props.frag_shader_path)
    }
    fragment_source := cstring(raw_data(fragment_source_bytes))

    fragment_shader := gl.CreateShader(gl.FRAGMENT_SHADER)
    gl.ShaderSource(fragment_shader, 1, &fragment_source , nil)
    gl.CompileShader(fragment_shader)

    gl.GetShaderiv(fragment_shader, gl.COMPILE_STATUS, &success)
    if success == 0 {
        fmt.println("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED: %s, error: ", props.frag_shader_path, cstring(&info_log[0]))
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

    return program
}

shader_arrays_init :: proc(VAO, VBO, EBO: ^u32, vertices: []f32, indices: []u32) {
    gl.GenVertexArrays(1, VAO);
    gl.GenBuffers(1, VBO);

    gl.GenBuffers(1, EBO);

    gl.BindVertexArray(VAO^);

    gl.BindBuffer(gl.ARRAY_BUFFER, VBO^);
    gl.BufferData(gl.ARRAY_BUFFER, len(vertices) * size_of(f32), raw_data(vertices), gl.STATIC_DRAW);

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, EBO^);
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(indices) * size_of(f32), raw_data(indices), gl.STATIC_DRAW);

    // position attribute
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 0);
    gl.EnableVertexAttribArray(0);
    // color attribute
    gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 8 * size_of(f32), (3 * size_of(f32)));
    gl.EnableVertexAttribArray(1);
    // texture coord attribute
    gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, 8 * size_of(f32), (6 * size_of(f32)));
    gl.EnableVertexAttribArray(2);

    gl.BindVertexArray(0)
}