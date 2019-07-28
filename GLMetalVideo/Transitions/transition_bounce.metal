//
//  transition_bounce.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_bounce(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                  texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                  texture2d<float, access::write> outTexture [[ texture(2) ]],
                                  device const float *progress [[ buffer(0) ]],
                                  uint2 gid [[ thread_position_in_grid ]])
{
    float4 shadow_color = float4(0.0, 0.0, 0.0, 0.6);
    float shadow_height = 0.075;
    float bounces = 3.0;
    const float PI = 3.14159265358;
    float time = 1. - *progress;
    float stime = sin(time * PI / 2.);
    float phase = time * PI * bounces;
    float y = abs(cos(phase)) * (1.0 - stime);
    float d = (gid.y / 1. / inTexture.get_height() - y);
    
    outTexture.write(mix( mix( inTexture2.read(uint2(gid.x, inTexture2.get_height()-gid.y)), shadow_color, step(d, shadow_height) * (1. - mix( ((d / shadow_height) * shadow_color.a) + (1.0 - shadow_color.a), 1.0, smoothstep(0.95, 1., *progress) ) ) ), inTexture.read(uint2(gid.x, inTexture.get_height() - gid.y)), step(d, 0.0) ), uint2(gid.x, outTexture.get_height() - gid.y));
}
