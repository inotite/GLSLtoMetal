//
//  transition_flyeye.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_flyeye(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                     texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                     texture2d<float, access::write> outTexture [[ texture(2) ]],
                                     device const float *progress [[ buffer(0) ]],
                                     uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float size = 0.04;
    float zoom = 50.0;
    float colorSeparation = 0.3;
    
    float2 sizeTx = float2(inTexture.get_width(), inTexture.get_height());
    float2 uv = float2(gid).xy / sizeTx.xy;
    
    float inv = 1. - prog;
    float2 disp = size * float2(cos(zoom * uv.x), sin(zoom * uv.y));
    float4 texTo = inTexture2.read(uint2((uv + inv * disp) * sizeTx));
    float4 texFrom = float4(
        inTexture.read(uint2((uv + prog * disp * (1.0 - colorSeparation)) * sizeTx)).r,
        inTexture.read(uint2((uv + prog * disp) * sizeTx)).g,
        inTexture.read(uint2((uv + prog * disp * (1.0 + colorSeparation)) * sizeTx)).b,
        1.0
    );
    
    outTexture.write( mix( texFrom, texTo, prog ), gid);
}
