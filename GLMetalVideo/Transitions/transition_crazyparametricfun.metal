//
//  transition_crazyparametricfun.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/16/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_crazyparametricfun(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                 texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                 texture2d<float, access::write> outTexture [[ texture(2) ]],
                                 device const float *progress [[ buffer(0) ]],
                                 uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 uv = float2(gid) / sizeTx;
    
    float a = 4;
    float b = 1;
    float amplitude = 120;
    float smoothness = 0.1;
    
    float2 p = uv.xy / float2(1.0).xy;
    float2 dir = p - float2(.5);
    float dist = length(dir);
    float x = (a - b) * cos(prog) + b * cos(prog * ((a / b) - 1.));
    float y = (a - b) * sin(prog) - b * sin(prog * ((a / b) - 1.));
    float2 offset = dir * float2(sin(prog * dist * amplitude * x), sin(prog * dist * amplitude * y)) / smoothness;
    
    outTexture.write(mix(
                         inTexture.read(uint2((p + offset) * sizeTx)),
                         inTexture2.read(gid),
                         smoothstep(0.2, 1.0, prog)
                     ), gid);
}
