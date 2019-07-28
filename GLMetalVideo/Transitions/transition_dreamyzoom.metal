//
//  transition_dreamyzoom.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/16/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#define DEG2RAD 0.03926990816987241548078304229099

kernel void transition_dreamyzoom(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                    texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                    texture2d<float, access::write> outTexture [[ texture(2) ]],
                                    device const float *progress [[ buffer(0) ]],
                                    uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 uv= float2(gid) / sizeTx;
    
    float rotation = 6;
    float scale = 1.2;
    float ratio = 0.7;
    
    float phase = prog < 0.5 ? prog * 2.0 : (prog - 0.5) * 2.0;
    float angleOffset = prog < 0.5 ? mix(0.0, rotation * DEG2RAD, phase) : mix(-rotation * DEG2RAD, 0.0, phase);
    float newScale = prog < 0.5 ? mix(1.0, scale, phase) : mix(scale, 1.0, phase);
    
    float2 center = float2(0, 0);
    
    // Calculate the source point
    float2 assumedCenter = float2(0.5, 0.5);
    float2 p = (uv.xy - float2(0.5, 0.5)) / newScale * float2(ratio, 1.0);
    
    // This can probably be optimized (with distance())
    float angle = atan2(p.y, p.x) + angleOffset;
    float dist = distance(center, p);
    p.x = cos(angle) * dist / ratio + 0.5;
    p.y = sin(angle) * dist + 0.5;
    float2 ngid = p * sizeTx;
    float4 c = prog < 0.5 ? inTexture.read(uint2(ngid.x, sizeTx.y - ngid.y)) : inTexture2.read(uint2(ngid.x, sizeTx.y - ngid.y));
    
    // Finally, apply the color
    outTexture.write(c + (prog < 0.5 ? mix(0.0, 1.0, phase) : mix(1.0, 0.0, phase)), uint2(gid.x, sizeTx.y - gid.y));
}
