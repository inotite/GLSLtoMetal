//
//  transition_pixelize.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_pixelize(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                      texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                      texture2d<float, access::write> outTexture [[ texture(2) ]],
                                      device const float *progress [[ buffer(0) ]],
                                      uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    int2 squaresMin = int2(20);
    int steps = 50;
    
    float d = min(prog, 1.0 - prog);
    float dist = steps > 0 ? ceil(d * float(steps)) / float(steps) : d;
    float2 squareSize = 2.0 * dist / float2(squaresMin);
    
    float2 size = float2(inTexture.get_width(), inTexture.get_height());
    float2 uv = float2(gid) / size;
    
    float2 p = dist > 0.0 ? (floor(uv / squareSize) + 0.5) * squareSize : uv;
    
    outTexture.write( mix(inTexture.read(uint2(p * size)), inTexture2.read(uint2(p * size)), prog), gid );
}
