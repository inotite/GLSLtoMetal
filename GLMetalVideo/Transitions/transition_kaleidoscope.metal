//
//  transition_kaleidoscope.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_kaleidoscope(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                  texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                  texture2d<float, access::write> outTexture [[ texture(2) ]],
                                  device const float *progress [[ buffer(0) ]],
                                  uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 uv= float2(gid) / sizeTx;
    
    float speed = 1.0;
    float angle = 1.0;
    float power = 1.5;
    
    float2 p = uv.xy / float2(1.0).xy;
//    float2 p = uv;
    
    float2 q = p;
    float t = pow(prog, power) * speed;
    p = p - 0.5;
    
    for( int i = 0 ; i < 7 ; i++ ) {
        p = float2(sin(t) * p.x + cos(t) * p.y, sin(t) * p.y - cos(t) * p.x);
        t += angle;
        p = abs(fmod(p, 2.0) - 1.0);
    }
    p = abs(fmod(p, 1.0));
    outTexture.write( mix(
                        mix( inTexture.read(uint2(q * sizeTx)), inTexture2.read(uint2(q * sizeTx)), prog),
                        mix( inTexture.read(uint2(p * sizeTx)), inTexture2.read(uint2(p * sizeTx)), prog), 1.0 - 2.0 * abs(prog - 0.5)
                     ), gid);
}
