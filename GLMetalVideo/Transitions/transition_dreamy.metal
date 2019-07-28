//
//  transition_dreamy.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float2 offset(float prog, float x, float theta) {
    float phase = prog * prog + prog + theta;
    float shifty = 0.03 * prog * cos(10.0 * (prog + x));
    return float2(0.0, shifty);
}

kernel void transition_dreamy(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                        texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                        texture2d<float, access::write> outTexture [[ texture(2) ]],
                                        device const float *progress [[ buffer(0) ]],
                                        uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(inTexture.get_width(), inTexture.get_height());
    float2 p = float2(gid) / sizeTx;
    
    outTexture.write( mix(
                          inTexture.read(
                                         uint2((p + offset(prog, p.x, 0.0)) * sizeTx)
                                         ),
                          inTexture2.read(
                                          uint2((p + offset(1.0 - prog, p.x, 3.14)) * sizeTx)
                                          ),
                          prog
                         ),
                      gid);
}
