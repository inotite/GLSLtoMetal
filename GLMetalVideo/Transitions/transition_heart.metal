//
//  transition_heart.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float inHeart(float2 p, float2 center, float size) {
    if (size == 0)
        return 0.0;
    float2 o = (p - center) / (1.6 * size);
    float a = o.x * o.x + o.y * o.y - 0.3;
    return step(a * a * a, o.x * o.x * o.y * o.y * o.y);
}

kernel void transition_heart(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                      texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                      texture2d<float, access::write> outTexture [[ texture(2) ]],
                                      device const float *progress [[ buffer(0) ]],
                                      uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    
    float2 size = float2(inTexture.get_width(), inTexture.get_height());
    float2 uv = float2(gid) / size;
    
    outTexture.write( mix(inTexture.read(uint2(gid.x, size.y - gid.y)), inTexture2.read(uint2(gid.x, size.y - gid.y)), inHeart(uv, float2(0.5, 0.4), prog)), uint2(gid.x, size.y - gid.y));
}
