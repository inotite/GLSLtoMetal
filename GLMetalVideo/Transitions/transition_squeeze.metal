//
//  transition_squeeze.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_squeeze(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                texture2d<float, access::write> outTexture [[ texture(2) ]],
                                device const float *progress [[ buffer(0) ]],
                                uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float colorSeparation = 0.04;
    
    float2 size = float2(outTexture.get_width(), outTexture.get_height());
    float2 uv = float2(gid) / size;
    
//    float y = 0.5 + (uv.y - 0.5) / (1 - prog);
    if (uv.y < prog / 2 || uv.y > (2 - prog) / 2) {
        outTexture.write(inTexture2.read(gid), gid);
    }
    else {
        float2 fp = float2(uv.x, uv.y);
        float2 off = prog * float2(0.0, colorSeparation);
        float4 c = inTexture.read(uint2(fp * size));
        float4 cn = inTexture.read(uint2((fp - off) * size));
//        float4 cp = inTexture.read(uint2((fp + off) * size));
        outTexture.write( float4(c.r, c.g, c.b, cn.a), gid );
    }
}
