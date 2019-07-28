//
//  transition_doomscreentransition.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_doomscreentransition(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                    texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                    texture2d<float, access::write> outTexture [[ texture(2) ]],
                                    device const float *progress [[ buffer(0) ]],
                                    uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 uv= float2(gid) / sizeTx;
    
    int bars = 30;
    float amplitude = 2;
    float noise = 0.1;
    float frequency = 0.5;
    float dripScale = 0.5;
    
    int bar = int(uv.x * (float(bars)));
    float rand_bar = fract(fmod(float(bar) * 67123.313, 12.0) * sin(float(bar) * 10.3) * cos(float(bar)));
    float fn = float(bar) * frequency * 0.1 * float(bars);
    float wave_bar = cos(fn * 0.5) * cos(fn * 0.13) * sin((fn+10.0) * 0.3) / 2.0 + 0.5;
    float drip_bar = sin(float(bar) / float(bars - 1) * 3.141592) * dripScale;
    float pos_bar = (noise == 0.0 ? wave_bar : mix(wave_bar, rand_bar, noise)) + (dripScale == 0.0 ? 0.0 : drip_bar);
    float scale = 1.0 + pos_bar * amplitude;
    
    float phase = prog * scale;
    float posY = uv.y / float2(1.0).y;
    float2 p;
    float4 c;
    float2 ngid;
    
    if (phase + posY < 1.0) {
        p = float2(uv.x, uv.y + mix(0.0, float2(1.0).y, phase)) / float2(1.0).xy;
        ngid = p * sizeTx;
        c = inTexture.read(uint2(ngid.x, sizeTx.y - ngid.y));
    }
    else {
        p = uv.xy / float2(1.0).xy;
        ngid = p * sizeTx;
        c = inTexture2.read(uint2(ngid.x, sizeTx.y - ngid.y));
    }
    
    outTexture.write(c, uint2(gid.x, sizeTx.y - gid.y));
}
