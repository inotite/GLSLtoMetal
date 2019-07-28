//
//  transition_waterdrop.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/16/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_waterdrop(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                     texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                     texture2d<float, access::write> outTexture [[ texture(2) ]],
                                     device const float *progress [[ buffer(0) ]],
                                     uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 p = float2(gid) / sizeTx;
    
    float amplitude = 30;
    float speed = 30;
    
    float2 dir = p - float2(.5);
    float dist = length(dir);
    
    if (dist > prog) {
        outTexture.write(mix(inTexture.read(gid), inTexture2.read(gid), prog), gid);
    }
    else {
        float2 offset = dir * sin(dist * amplitude - prog * speed);
        outTexture.write(mix(inTexture.read(uint2((p + offset) * sizeTx)), inTexture2.read(gid), prog), gid);
    }
}
