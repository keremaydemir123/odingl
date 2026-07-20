package main
import stbi "vendor:stb/image"
import gl "vendor:OpenGL"
import "core:fmt"

TextureInitProps :: struct {
    file_path               : cstring,
    wrap_s, wrap_t          : TextureWrap_Type,
    filter_min, filter_max  : TextureFilter_Type,
    image_format            : ImageFormat_Type
}

ImageFormat_Type :: enum u32 {
    RGBA    = gl.RGBA,
    RGB     = gl.RGB
}

TextureWrap_Type :: enum i32 {
    REPEAT              = gl.REPEAT,
    MIRRORED_REPEAT     = gl.MIRRORED_REPEAT,
    CLAMP_TO_EDGE       = gl.CLAMP_TO_EDGE,
    CLAMP_TO_BORDER     = gl.CLAMP_TO_BORDER
}

TextureFilter_Type :: enum i32 {
    NEAREST = gl.NEAREST,
    LINEAR  = gl.LINEAR
}

texture_init :: proc(props: TextureInitProps) -> u32 {
    tex: u32
    width, height, nr_channels: i32
    gl.GenTextures(1, &tex)
    gl.BindTexture(gl.TEXTURE_2D, tex)
    // set the texture wrapping parameters
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, i32(props.wrap_s));	// set texture wrapping to GL_REPEAT (default wrapping method)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, i32(props.wrap_t));
    // set texture filtering parameters
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, i32(props.filter_min));
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, i32(props.filter_max));

    data := stbi.load(props.file_path, &width, &height, &nr_channels, 0);
    if data != nil {
        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, width, height, 0, u32(props.image_format), gl.UNSIGNED_BYTE, data)
        gl.GenerateMipmap(gl.TEXTURE_2D)
    } else {
        fmt.eprintfln("ERROR::TEXTURE::LOAD: %v", props.file_path)
    }
    stbi.image_free(data)
    return tex
}