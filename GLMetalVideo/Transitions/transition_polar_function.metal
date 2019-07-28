//
//  transition_polar_function.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#define PI 3.14159265359

kernel void transition_polar_function(texture2d<float, access::read> inTexture [[ texture(0) ]],
                            texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                            texture2d<float, access::write> outTexture [[ texture(2) ]],
                            device const float *progress [[ buffer(0) ]],
                            uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    int segments = 5;
    
    float2 sizeTx = float2(inTexture.get_width(), inTexture.get_height());
    float2 uv = float2(gid) / sizeTx;
    
    float angle = atan2(uv.y - 0.5, uv.x - 0.5) - 0.5 * PI;
    float normalized = (angle + 1.5 * PI) * (2.0 * PI);
    
    float radius = (cos(float(segments) * angle) + 4.0) / 4.0;
    float difference = length(uv - float2(0.5, 0.5));
    
    if (difference > radius * prog)
        outTexture.write(inTexture.read(uint2(gid.x, sizeTx.y - gid.y)), uint2(gid.x, sizeTx.y - gid.y));
    else
        outTexture.write(inTexture2.read(uint2(gid.x, sizeTx.y - gid.y)), uint2(gid.x, sizeTx.y - gid.y));
}
