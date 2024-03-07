//
//  ShaderDefinitions.h
//  MetalProject
//
//  Created by Sina Dashtebozorgy on 09/07/2023.
//


#if __METAL_VERSION__
#define DEVICE_PTR(x) device x*
#define TEXTURE metal::texture2d<float>
#define METAL_TYPE(x) x
#else
#include <Metal/MTLTypes.h>
#define DEVICE_PTR(x) uint64_t
#define METAL_TYPE(x) uint64_t
#define TEXTURE uint64_t
#endif

#ifndef ShaderDefinitions_h
#define ShaderDefinitions_h
#define positionAttribute 0
#define normalAttribute 1
#define textureAttribute 2

#include <simd/simd.h>


struct TextureBuffer {
    TEXTURE texture;
};









#endif /* ShaderDefinitions_h */

