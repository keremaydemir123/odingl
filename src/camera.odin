package main
import "core:math/linalg"

camera_speed        : f64   = 2.5
camera_pos          : Vec3  = {0,0,3}
camera_front        : Vec3  = {0,0,-1}
camera_up           : Vec3  = {0,1,0}
camera_yaw          : f32   = -90
camera_pitch        : f32   = 0
camera_sensivity    : f32   = 0.1
camera_fov          : f32   = 70

update_camera_direction :: proc() {
    direction: Vec3
    direction.x = linalg.cos(euler_to_radians(camera_yaw)) * linalg.cos(euler_to_radians(camera_pitch))
    direction.y = linalg.sin(euler_to_radians(camera_pitch))
    direction.z = linalg.sin(euler_to_radians(camera_yaw)) * linalg.cos(euler_to_radians(camera_pitch))
    camera_front = linalg.normalize(direction)
}