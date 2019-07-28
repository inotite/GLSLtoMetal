//
//  transition_fadegrayscale.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float3 grayscale(float3 color) {
    return float3(0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b);
}

kernel void transition_fadegrayscale(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                 texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                 texture2d<float, access::write> outTexture [[ texture(2) ]],
                                 device const float *progress [[ buffer(0) ]],
                                 uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float intensity = 0.3;
    
    float4 fc = inTexture.read(gid);
    float4 tc = inTexture2.read(gid);
    
    outTexture.write( mix(
                          mix(float4(grayscale(fc.rgb), 1.0), fc, smoothstep(1.0 - intensity, 0.0, prog)),
                          mix(float4(grayscale(fc.rgb), 1.0), tc, smoothstep(intensity, 1.0, prog)),
                          prog
                          ), gid);
}
