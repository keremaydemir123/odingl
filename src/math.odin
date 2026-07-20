package main
import "core:math/linalg"

Vec3            :: linalg.Vector3f32
Vec4            :: linalg.Vector4f32
Mat4            :: linalg.Matrix4f32
Mat4_Identity   :: linalg.MATRIX4F32_IDENTITY

mat4_translate :: proc(v: Vec3) -> Mat4 {
    return linalg.matrix4_translate_f32(v)
}

mat4_rotate_euler :: proc(euler: f32, v: Vec3) -> Mat4 {
    return linalg.matrix4_rotate_f32(linalg.to_radians(euler), v)
}

mat4_rotate_radians :: proc(radians: f32, v: Vec3) -> Mat4 {
    return linalg.matrix4_rotate_f32(radians, v)
}

mat4_scale :: proc(v: Vec3) -> Mat4 {
    return linalg.matrix4_scale_f32(v)
}

mat4_perspective :: proc(fovy, aspect, near, far: f32) -> Mat4 {
    return linalg.matrix4_perspective_f32(linalg.to_radians(fovy), aspect, near, far)
}

euler_to_radians :: proc(euler: f32) -> f32 {
    return linalg.to_radians(euler)
}