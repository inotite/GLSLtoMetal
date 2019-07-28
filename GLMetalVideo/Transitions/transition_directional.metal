//
//  transition_directional.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_directional(texture2d<float, access::read> inTexture [[ texture(0) ]],
                              texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                              texture2d<float, access::write> outTexture [[ texture(2) ]],
                              device const float *progress [[ buffer(0) ]],
                              uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 direction = float2(0.0, 1.0);
    
    float2 p = float2(gid).xy / float2(inTexture.get_width(), inTexture.get_height()).xy + prog * sign(direction);
    float2 f = fract(p) * float2(inTexture.get_width(), inTexture.get_height());
    
    outTexture.write( mix( inTexture2.read(uint2(f)), inTexture.read(uint2(f)), step(0.0, p.y) * step(p.y, 1.0) * step(0.0, p.x) * step(p.x, 1.0) ), gid);
}
