//
//  transition_circlecrop.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/16/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_circlecrop(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                  texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                  texture2d<float, access::write> outTexture [[ texture(2) ]],
                                  device const float *progress [[ buffer(0) ]],
                                  uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 p = float2(gid) / sizeTx;
    float ratio = sizeTx.x / sizeTx.y;
    
    float4 bgcolor = float4(0.0, 0.0, 0.0, 1.0);
    float2 ratio2 = float2(1.0, 1.0 / ratio);
    float s = pow(2.0 * abs(prog - 0.5), 3.0);
    
    float dist = length((float2(p) - 0.5) * ratio2);
    
    outTexture.write( mix(
                          prog < 0.5 ? inTexture.read(gid) : inTexture2.read(gid),
                          bgcolor,
                          step(s, dist)
                     ), gid);
}
