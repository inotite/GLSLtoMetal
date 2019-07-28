//
//  transition_randomsquares.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_randomsquares(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                      texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                      texture2d<float, access::write> outTexture [[ texture(2) ]],
                                      device const float *progress [[ buffer(0) ]],
                                      uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    int2 size = int2(10, 10);
    float smoothness = 0.5;
    
    float2 sizeTx = float2(inTexture.get_width(), inTexture.get_height());
    float2 uv = float2(gid) / sizeTx;
    
    float2 co = floor(float2(size) * uv);
    float r = fract(sin(dot(co.xy, float2(12.9898, 78.233))) * 4378.5453);
    float m = smoothstep(0.0, -smoothness, r - (prog * (1.0 + smoothness)));
    
    outTexture.write(mix(inTexture.read(gid), inTexture2.read(gid), m), gid);
}
