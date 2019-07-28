//
//  transition_wind.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float rand(float2 co) {
    return fract(sin(dot(co.xy, float2(12.9898, 78.233))) * 4378.5453);
}

kernel void transition_wind(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                   texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                   texture2d<float, access::write> outTexture [[ texture(2) ]],
                                   device const float *progress [[ buffer(0) ]],
                                   uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float size = 0.2;
    
    float2 sizeTx = float2(inTexture.get_width(), inTexture.get_height());
    float2 uv = float2(gid) / sizeTx;
    
    float r = rand(float2(0, uv.y));
    float m = smoothstep(0.0, -size, uv.x * (1.0 - size) + size * r - (prog * (1.0 + size)));
    
    outTexture.write( mix(inTexture.read(gid), inTexture2.read(gid), m), gid);
}
