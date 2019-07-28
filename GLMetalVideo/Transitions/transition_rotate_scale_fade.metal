//
//  transition_rotate_scale_fade.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#define PI 3.14159265359

kernel void transition_rotate_scale_fade(texture2d<float, access::read> inTexture [[ texture(0) ]],
                              texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                              texture2d<float, access::write> outTexture [[ texture(2) ]],
                              device const float *progress [[ buffer(0) ]],
                              uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1 - *progress;
    float2 center = float2(0.5, 0.5);
    float rotations = 1;
    float scale = 8;
    float4 backColor = float4(0.15, 0.15, 0.15, 1.0);
    
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 uv = float2(gid.x * 1. / sizeTx.x, gid.y * 1. / sizeTx.y);
    
    float2 difference = float2(uv.x - 0.5, uv.y - 0.5);
    float2 dir = normalize(difference);
    float dist = length(difference);
    
    float angle = 2.0 * PI * rotations * prog;
    
    float c = cos(angle);
    float s = sin(angle);
    
    float currentScale = mix(scale, 1.0, 2.0 * abs(prog - 0.5));
    
    float2 rotatedDir = float2(dir.x * c - dir.y * s, dir.x * s + dir.y * c);
    float2 rotatedUv = center + rotatedDir * dist / currentScale;
    
    if (rotatedUv.x < 0.0 || rotatedUv.x > 1.0 || rotatedUv.y < 0.0 || rotatedUv.y > 1.0)
        outTexture.write(backColor, gid);
    else
        outTexture.write(mix(inTexture.read(uint2(rotatedUv.x * sizeTx.x, rotatedUv.y * sizeTx.y)), inTexture2.read(uint2(rotatedUv.x * sizeTx.x, rotatedUv.y * sizeTx.y)), prog), gid);
}
