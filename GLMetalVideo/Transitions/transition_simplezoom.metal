//
//  transition_simplezoom.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float2 zoom(float2 uv, float amount) {
    float2 center = float2(0.5, 0.5);
    
    return (uv - center) * (1 - amount) + center;
}

kernel void transition_simplezoom(texture2d<float, access::read> inTexture [[ texture(0) ]],
                              texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                              texture2d<float, access::write> outTexture [[ texture(2) ]],
                              device const float *progress [[ buffer(0) ]],
                              uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float zoom_quickness = 0.8;
    
    float nQuick = clamp(zoom_quickness, 0.2, 1.0);
    
    float2 size = float2(inTexture.get_width(), inTexture.get_height());
    
    float2 uv = float2(gid.x * 1. / size.x, gid.y * 1. / size.y);
    
    float2 ngid = zoom(uv, smoothstep(0, nQuick, prog));
    
    float alpha = smoothstep(nQuick - 0.2, 1.0, prog);
    
    outTexture.write( mix(inTexture.read(uint2(ngid * size)), inTexture2.read(gid), alpha), gid );
}
