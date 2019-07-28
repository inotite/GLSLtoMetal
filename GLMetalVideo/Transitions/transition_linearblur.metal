//
//  transition_linearblur.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/14/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_linearblur(texture2d<float, access::read> inTexture [[ texture(0) ]],
                              texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                              texture2d<float, access::write> outTexture [[ texture(2) ]],
                              device const float *progress [[ buffer(0) ]],
                              uint2 gid [[ thread_position_in_grid ]])
{
    int passes = 6;
    float intensity = 0.1;
    float2 size = float2(inTexture.get_width(), inTexture.get_height());
    float prog = 1. - *progress;
    
    float4 c1 = float4(0.0);
    float4 c2 = float4(0.0);
    
    float disp = intensity * (0.5 - abs(prog - 0.5));
    for (int xi = 0 ; xi < passes ; xi++ ) {
        float x = xi * 1. / passes - 0.5;
        for(int yi = 0 ; yi < passes ; yi++ ) {
            float y = yi * 1. / passes - 0.5;
            float2 v = float2(x, y);
            float d = disp;
            uint2 point = uint2(gid.x + d * v.x * size.x, gid.y + d * v.y * size.x);
            c1 += inTexture.read(point);
            c2 += inTexture2.read(point);
        }
    }
    c1 /= passes * passes;
    c2 /= passes * passes;
    
    outTexture.write(mix(c1, c2, prog), gid);
}
