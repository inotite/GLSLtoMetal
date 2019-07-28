//
//  transition_angular.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_angular(texture2d<float, access::read> inTexture [[ texture(0) ]],
                              texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                              texture2d<float, access::write> outTexture [[ texture(2) ]],
                              device const float *progress [[ buffer(0) ]],
                              uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float startingAngle = -90;
    
    const float PI = 3.141592653589;
    float2 size = float2(inTexture.get_width(), inTexture.get_height());
    float2 uv = float2(gid).xy / size.xy;
    
    float offset = startingAngle * PI / 180.0;
    float angle = atan2(uv.y - 0.5, uv.x - 0.5) + offset;
    float normalizeAngle = (angle + PI) / (2.0 * PI);
    
    normalizeAngle = normalizeAngle - floor(normalizeAngle);
    
    outTexture.write( mix(inTexture.read(uint2(size.x-gid.x, gid.y)), inTexture2.read(uint2(size.x-gid.x, gid.y)), step(normalizeAngle, prog)), uint2(size.x-gid.x, gid.y));
}
