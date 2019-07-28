//
//  transition_glitchmemories.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/14/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_glitchmemories(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                  texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                  texture2d<float, access::write> outTexture [[ texture(2) ]],
                                  device const float *progress [[ buffer(0) ]],
                                  uint2 gid [[ thread_position_in_grid ]])
{
    float prog = *progress;
    float2 sizeTx = float2(inTexture.get_width(), inTexture.get_height());
    float2 p = float2(gid) / sizeTx;
    
    float2 block = floor(float2(p) / float2(16));
    float2 uv_noise = block / float2(64);
    
    uv_noise += floor(float2(prog) * float2(1200.0, 3500.0)) / float2(64);
    float2 dist  = prog > 0.0 ? (fract(uv_noise) - 0.5) * 0.3 * (1.0 - prog) : float2(0.0);
    float2 red = float2(p) + dist * 0.2;
    float2 green = float2(p) + dist * 0.3;
    float2 blue = float2(p) + dist * 0.5;
    
    outTexture.write( float4(mix(inTexture.read(uint2(red * sizeTx)), inTexture2.read(uint2(red * sizeTx)), 1-prog).r,
                             mix(inTexture.read(uint2(green * sizeTx)), inTexture2.read(uint2(green * sizeTx)), 1-prog).g,
                             mix(inTexture.read(uint2(blue * sizeTx)), inTexture2.read(uint2(blue * sizeTx)), 1-prog).b,
                             1.0),
                     gid);
}
