//
//  transition_colorphase.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_colorphase(texture2d<float, access::read> inTexture [[ texture(0) ]],
                            texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                            texture2d<float, access::write> outTexture [[ texture(2) ]],
                            device const float *progress [[ buffer(0) ]],
                            uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float4 fromStep = float4(0.0, 0.2, 0.4, 0.0);
    float4 toStep = float4(0.6, 0.8, 1.0, 1.0);
    
    outTexture.write( mix(inTexture.read(gid), inTexture2.read(gid), smoothstep(fromStep, toStep, float4(prog))), gid);
}

