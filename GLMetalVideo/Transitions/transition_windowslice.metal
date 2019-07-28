//
//  transition_windowslice.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_windowslice(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                    texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                    texture2d<float, access::write> outTexture [[ texture(2) ]],
                                    device const float *progress [[ buffer(0) ]],
                                    uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float count = 10.0;
    float smoothness = 0.5;
    
    float2 size = float2(inTexture.get_width(), inTexture.get_height());
    float2 p = float2(gid) / size;
    
    float pr = smoothstep(-smoothness, 0.0, p.x - prog * (1.0 + smoothness));
    float s = step(pr, fract(count * p.x));
    
    outTexture.write( mix(inTexture.read(gid), inTexture2.read(gid), s), gid);
}

