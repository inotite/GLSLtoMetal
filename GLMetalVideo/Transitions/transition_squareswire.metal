//
//  transition_squareswire.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_squareswire(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                     texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                     texture2d<float, access::write> outTexture [[ texture(2) ]],
                                     device const float *progress [[ buffer(0) ]],
                                     uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    int2 squares = int2(10, 10);
    float2 direction = float2(1.0, -0.5);
    float smoothness = 1.6;
    
    float2 sizeTx = float2(inTexture.get_width(), inTexture.get_height());
    float2 p = float2(gid) / sizeTx;
    
    const float2 center = float2(0.5, 0.5);
    
    float2 v = normalize(direction);
    
    v /= abs(v.x) + abs(v.y);
    
    float d = v.x * center.x + v.y * center.y;
    float offset = smoothness;
    float pr = smoothstep(-offset, 0.0, v.x * p.x + v.y * p.y - (d - 0.5 + prog * (1. + offset)));
    float2 squarep = fract(p * float2(squares));
    float2 squaremin = float2(pr / 2.0);
    float2 squaremax = float2(1.0 - pr / 2.0);
    float a = (1.0 - step(prog, 0.0)) * step(squaremin.x, squarep.x) * step(squaremin.y, squarep.y) * step(squarep.x, squaremax.x) * step(squarep.y, squaremax.y);
    
    outTexture.write(mix(inTexture.read(gid), inTexture2.read(gid), a), gid);
}
