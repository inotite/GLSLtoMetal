//
//  transition_fadecolor.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_fadecolor(texture2d<float, access::read> inTexture [[ texture(0) ]],
                            texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                            texture2d<float, access::write> outTexture [[ texture(2) ]],
                            device const float *progress [[ buffer(0) ]],
                            uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    
    float3 color = float3(0.0);
    float colorPhase = 0.4;
    
    outTexture.write( mix(
                          mix(float4(color, 1.0), inTexture.read(gid), smoothstep(1.0 - colorPhase, 0.0, prog)),
                          mix(float4(color, 1.0), inTexture2.read(gid), smoothstep(colorPhase, 1.0, prog)),
                          prog
                          ), gid);
}
