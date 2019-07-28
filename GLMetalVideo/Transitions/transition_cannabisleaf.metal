//
//  transition_cannabisleaf.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/16/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_cannabisleaf(texture2d<float, access::read> inTexture [[ texture(0) ]],
                              texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                              texture2d<float, access::write> outTexture [[ texture(2) ]],
                              device const float *progress [[ buffer(0) ]],
                              uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 uv= float2(gid) / sizeTx;
    
    if (prog == 0.0) {
        outTexture.write(inTexture.read(gid), gid);
        return;
    }
    
    float2 leaf_uv = (uv - float2(0.5)) / 10. / pow(prog, 3.5);
    leaf_uv.y += 0.35;
    float r = 0.18;
    float o = atan2(leaf_uv.y, leaf_uv.x);
    outTexture.write(mix(
                         inTexture.read(uint2(gid.x, sizeTx.y - gid.y)),
                         inTexture2.read(uint2(gid.x, sizeTx.y - gid.y)),
                         1. - step(1. - length(leaf_uv) + r * (1. + sin(o)) * (1. + 0.9 * cos(8. * o)) * (1. + 0.1 * cos(24. * o)) * (0.9 + 0.05 * cos(200. * o)), 1.)
                     ), uint2(gid.x, sizeTx.y - gid.y));
}
