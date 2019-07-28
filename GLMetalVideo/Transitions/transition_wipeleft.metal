//
//  transition_wipeleft.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_wipeleft(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                 texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                 texture2d<float, access::write> outTexture [[ texture(2) ]],
                                 device const float *progress [[ buffer(0) ]],
                                 uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    
    float2 p = float2(gid).xy / float2(inTexture.get_width(), inTexture.get_height()).xy;
    float4 a = inTexture.read(gid);
    float4 b = inTexture2.read(gid);
    
    outTexture.write( mix( a, b, step(1.0 - p.x, prog)), gid);
}
