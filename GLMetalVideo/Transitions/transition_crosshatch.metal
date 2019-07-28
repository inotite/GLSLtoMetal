//
//  transition_crosshatch.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float rand_crosshatch(float2 co) {
    return fract(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
}

kernel void transition_crosshatch(texture2d<float, access::read> inTexture [[ texture(0) ]],
                              texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                              texture2d<float, access::write> outTexture [[ texture(2) ]],
                              device const float *progress [[ buffer(0) ]],
                              uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(inTexture.get_width(), inTexture.get_height());
    float2 p = float2(gid) / sizeTx;
    
    float2 center = float2(0.5);
    float threshold = 3.0;
    float fadeEdge = 0.1;
    
    float dist = distance(center, p) / threshold;
    float r = prog - min(rand_crosshatch(float2(p.y, 0.0)), rand_crosshatch(float2(0.0, p.x)));
    
    outTexture.write( mix(inTexture.read(gid), inTexture2.read(gid),
                          mix(0.0, mix(step(dist, r), 1.0, smoothstep(1.0 - fadeEdge, 1.0, prog)), smoothstep(0.0, fadeEdge, prog))
                          ), gid);
}
