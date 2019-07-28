//
//  transition_burn.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_burn(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                  texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                  texture2d<float, access::write> outTexture [[ texture(2) ]],
                                  device const float *progress [[ buffer(0) ]],
                                  uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float3 color = float3(0.9, 0.4, 0.2);
    
    outTexture.write( mix(inTexture.read(gid) + float4(prog * color, 1.0), inTexture2.read(gid) + float4((1.0 - prog) * color, 1.0), prog), gid);
}
