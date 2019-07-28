//
//  transition_morph.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_morph(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                       texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                       texture2d<float, access::write> outTexture [[ texture(2) ]],
                                       device const float *progress [[ buffer(0) ]],
                                       uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float strength = 0.1;
    
    float4 ca = inTexture.read(gid);
    float4 cb = inTexture2.read(gid);
    
    float2 oa = ((ca.rg + ca.b) * 0.5) * 2.0 - 1.0;
    float2 ob = ((cb.rg + cb.b) * 0.5) * 2.0 - 1.0;
    float2 oc = mix(oa, ob, 0.5) * strength;
    
    float w0 = prog;
    float w1 = 1. - prog;
    
    float2 size = float2(inTexture.get_width(), inTexture.get_height());
    float2 p = float2(gid) / size;
    
    outTexture.write( mix(inTexture.read(uint2((p + oc * w0) * size)), inTexture2.read(uint2((p - oc * w1) * size)), prog), gid);
}
