//
//  transition_crosswarp.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_crosswarp(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                       texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                       texture2d<float, access::write> outTexture [[ texture(2) ]],
                                       device const float *progress [[ buffer(0) ]],
                                       uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    
    float2 size = float2(inTexture.get_width(), inTexture.get_height());
    float2 p = float2(gid) / size;
    
    float x = prog;
    x = smoothstep(.0, 1.0, (x * 2.0 + p.x - 1.0));
    
    outTexture.write( mix(
                          inTexture.read(uint2(
                                               ((p - 0.5) * (1.0 - x) + 0.5) * size
                                               )
                                         ),
                          inTexture2.read(uint2(
                                                ((p - 0.5) * x + 0.5) * size
                                                )
                                        ),
                          x),
                     gid);
}
