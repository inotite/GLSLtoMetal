//
//  transition_multiply_blend.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float4 blend(float4 a, float4 b) {
    return a * b;
}

kernel void transition_multiply_blend(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                texture2d<float, access::write> outTexture [[ texture(2) ]],
                                device const float *progress [[ buffer(0) ]],
                                uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float4 blended = blend(inTexture.read(gid), inTexture2.read(gid));
    
    if (prog < 0.5)
        outTexture.write(mix(inTexture.read(gid), blended, 2.0 * prog), gid);
    else
        outTexture.write(mix(blended, inTexture2.read(gid), 2.0 * prog - 1.0), gid);
}
