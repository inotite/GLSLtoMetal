//
//  transition_butterflywavescrawler.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/16/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#define PI 3.14159265358979323846264

kernel void transition_butterflywavescrawler(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                          texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                          texture2d<float, access::write> outTexture [[ texture(2) ]],
                                          device const float *progress [[ buffer(0) ]],
                                          uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 uv = float2(gid) / sizeTx;
    
    float amplitude = 1.0;
    float waves = 30.0;
    float colorSeparation = 0.3;
    
    float2 p = uv.xy / float2(1.0).xy;
    float inv = 1. - prog;
    float2 dir = p - float2(.5);
    float dist = length(dir);
    float2 o = p * sin (prog * amplitude) - float2(0.5, 0.5);
    float2 h = float2(1., 0.);
    float theta = acos(dot(o, h)) * waves;
    float disp = (exp(cos(theta)) - 2. * cos(4. * theta) + pow(sin((2. * theta - PI) / 24.), 5.)) / 10.;
    
    float4 texTo = inTexture2.read(uint2((p + inv * disp) * sizeTx));
    float4 texFrom = float4(
                            inTexture.read(uint2((p + prog * disp * (1.0 - colorSeparation)) * sizeTx)).r,
                            inTexture.read(uint2((p + prog * disp) * sizeTx)).g,
                            inTexture.read(uint2((p + prog * disp * (1.0 + colorSeparation)) * sizeTx)).b,
                            1.0 );
    
    outTexture.write( mix(texFrom, texTo, prog), gid );
}
