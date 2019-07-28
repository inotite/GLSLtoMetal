//
//  transition_circleopen.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_circleopen(texture2d<float, access::read> inTexture [[ texture(0) ]],
                               texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                               texture2d<float, access::write> outTexture [[ texture(2) ]],
                               device const float *progress [[ buffer(0) ]],
                               uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float smoothness = 0.3;
    bool opening = true;
    
    const float2 center = float2(0.5, 0.5);
    const float SQRT_2 = 1.414213562373;
    
    float2 size = float2(inTexture.get_width(), inTexture.get_height());
    float2 uv = float2(gid).xy / size.xy;
    
    float x = opening ? prog : 1 - prog;
    float m = smoothstep(-smoothness, 0.0, SQRT_2 * distance(center, uv) - x * (1. + smoothness));
    
    outTexture.write( mix(inTexture.read(gid), inTexture2.read(gid), opening ? 1. - m : m), gid);
}
