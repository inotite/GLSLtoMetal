//
//  transition_ripple.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_ripple(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                   texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                   texture2d<float, access::write> outTexture [[ texture(2) ]],
                                   device const float *progress [[ buffer(0) ]],
                                   uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float amplitude = 100.0;
    float speed = 50.0;
    
    float2 sizeTx = float2(inTexture.get_width(), inTexture.get_height());
    float2 uv = float2(gid) / sizeTx;
    float2 dir = uv - float2(.5);
    float dist = length(dir);
    float2 offset = dir * (sin(prog * dist * amplitude - prog * speed) + .5) / 30.;
    
    outTexture.write(mix(inTexture.read(uint2((uv + offset) * sizeTx)), inTexture2.read(gid), smoothstep(0.2, 1.0, prog)), gid);
}
