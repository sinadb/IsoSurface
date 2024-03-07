//
//  Camera.swift
//  MetalProject
//
//  Created by Sina Dashtebozorgy on 22/03/2023.
//

import Foundation
import Metal
import MetalKit
import AppKit


class Camera {
    
    var eye : simd_float3
    var centre : simd_float3
    var previous_x : Float?
    var previous_y : Float?
    var mouse_x : Float?
    var mouse_y : Float?
    var view : MTKView
    var width : Float
    var height : Float
    var totalChangeTheta : Float =  0
    var totalChangePhi : Float = 0
    var cameraMatrix : simd_float4x4
    var isOrtho = false
    var right = simd_float3()
    var up = simd_float3()
    var forward = simd_float3()
    var previous_deltaX : Float = 0
    var previous_deltaY : Float = 0
    var lockCamera = false
    var RTAxes = [simd_float3](repeating: simd_float3(0), count: 3)
    
    // this updates up,forward and right
    func updateCameraVectors(){
        right = simd_float3(vec4: cameraMatrix.columns.0)
        forward = simd_float3(vec4: cameraMatrix.columns.2)
        up = simd_float3(vec4: cameraMatrix.columns.1)
    }
    
    init(for view : MTKView, eye: simd_float3, centre: simd_float3) {
        self.view = view
        self.eye = eye
        self.centre = normalize(centre)
        width = Float(view.currentDrawable!.texture.width / 2)
        height = Float(view.currentDrawable!.texture.height / 2)
        up = simd_float3(0,1,0)
        if(abs(dot(centre,up)) > 0.99){
            print("Changing")
            up = simd_float3(0,0,1)
        }
        cameraMatrix = simd_float4x4(eye: eye, center: centre, up: up)
        updateCameraVectors()
        forward = normalize(eye - centre)
        print("initial forward is : \(forward)")
        for i in 0...2{
            RTAxes[0][i] = cameraMatrix[i][0]
            RTAxes[1][i] = cameraMatrix[i][1]
            RTAxes[2][i] = cameraMatrix[i][2]
        }
    }
    
   
    
    func reset_mouse(){
        mouse_x = nil
        mouse_y = nil
    }
    
    func update_mouse(with position : simd_float2){
        if mouse_x == nil && mouse_y == nil {
            mouse_x = position.x
            mouse_y = position.y
            previous_x = position.x
            previous_y = position.y
        }
        else {
            mouse_x = position.x
            mouse_y = position.y
            update()
        }
    }
    
    func update_eye(with offset : simd_float3){
        let eyeOffset = offset.z * forward + offset.x * right + offset.y * up
        eye += eyeOffset
       
        centre += (eyeOffset)
        cameraMatrix = simd_float4x4(eye: eye, center: centre, up: simd_float3(0,1,0))
        forward = normalize(eye - centre)
       
       
    }
    
    func get_camera_matrix() -> simd_float4x4 {
        return cameraMatrix
    }
    
    func update(){
        var delta_x = (mouse_x ?? (previous_x ?? 0 )) - (previous_x ?? 0)
        var delta_y = (mouse_y ?? (previous_y ?? 0 )) - (previous_y ?? 0)
        
        var deltaTheta = (delta_x)
        let deltaPhi = (delta_y)
        let movedCentreToOrigin = normalize(centre - eye)
        let rotatedCentre = (simd_float4x4(rotationXYZ: simd_float3(-deltaPhi,-deltaTheta,0))*simd_float4(movedCentreToOrigin,1))
                centre = simd_float3(rotatedCentre.x, rotatedCentre.y,rotatedCentre.z) + eye
                cameraMatrix = simd_float4x4(eye: eye, center: centre, up: simd_float3(0,1,0))
        forward = normalize(eye - centre)
        right = normalize(cross(up, forward))
        up = normalize(cross(forward, right))
        
            
        
      
           
            previous_x = mouse_x
            previous_y = mouse_y
            
           
        
        
      
        
       
     
            
        }
        
        
      
     
       
    
}


