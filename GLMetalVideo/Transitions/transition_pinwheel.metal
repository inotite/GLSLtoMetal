//
//  transition_pinwheel.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float mod_p(float x, float y) {
    return x - y * floor(x / y);
}

kernel void transition_pinwheel(texture2d<float, access::read> inTexture [[ texture(0) ]],
                              texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                              texture2d<float, access::write> outTexture [[ texture(2) ]],
                              device const float *progress [[ buffer(0) ]],
                              uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float speed = 2.0;
    
    float2 sizeTx = float2(inTexture.get_width(), inTexture.get_height());
    float2 uv = float2(gid) / sizeTx;
    float2 p = uv / float(1.0);
    
    float circPos = atan2(p.y - 0.5, p.x - 0.5) + prog * speed;
    float modPos = mod_p(circPos, 3.1415 / 4.);
    float fsigned = sign(prog - modPos);
    
    outTexture.write(mix(inTexture2.read(uint2(sizeTx.x - gid.x, gid.y)), inTexture.read(uint2(sizeTx.x - gid.x, gid.y)), step(fsigned, 0.5)), uint2(sizeTx.x - gid.x, gid.y));
}
