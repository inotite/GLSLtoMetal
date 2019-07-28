//
//  transition_crosszoom.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/16/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#define PI 3.141592653589793

float Linear_ease(float begin, float change, float duration, float time) {
    return change * time / duration + begin;
}

float Exponential_easeInOut(float begin, float change, float duration, float time) {
    if (time == 0.0)
        return begin;
    else if (time == duration)
        return begin + change;
    time = time / (duration / 2.0);
    if (time < 1.0)
        return change / 2.0 * pow(2.0, 10.0 * (time - 1.0)) + begin;
    return change / 2.0 * (-pow(2.0, -10.0 * (time - 1.0)) + 2.0) + begin;
}

float Sinusoidal_easeInOut(float begin, float change, float duration, float time) {
    return -change / 2.0 * (cos(PI * time / duration) - 1.0) + begin;
}

float rand_ (float2 co) {
    return fract(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
}

kernel void transition_crosszoom(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                 texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                 texture2d<float, access::write> outTexture [[ texture(2) ]],
                                 device const float *progress [[ buffer(0) ]],
                                 uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 uv = float2(gid) / sizeTx;
    
    float strength = 0.4;
    
    float2 texCoord = uv.xy / float2(1.0).xy;
    
    float2 center = float2(Linear_ease(0.25, 0.5, 1.0, prog), 0.5);
    float dissolve = Exponential_easeInOut(0.0, 1.0, 1.0, prog);
    
    strength = Sinusoidal_easeInOut(0.0, strength, 0.5, prog);
    
    float3 color = float3(0.0);
    float total = 0.0;
    float2 toCenter = center - texCoord;
    
    float offset = rand_(uv);
    
    for (float t = 0.0 ; t <= 40.0 ; t++ ) {
        float percent = (t + offset) / 40.0;
        float weight = 4.0 * (percent - percent * percent);
        float2 cf2 = texCoord + toCenter * percent * strength;
        color += mix(inTexture.read(uint2(cf2 * sizeTx)).rgb, inTexture2.read(uint2(cf2 * sizeTx)).rgb, dissolve) * weight;
        total += weight;
    }
    
    outTexture.write( float4(color / total, 1.0), gid );
}
