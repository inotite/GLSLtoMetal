//
//  transition_swap.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/16/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

bool2 lessThan_swap(float2 a, float2 b) {
    return bool2(a.x < b.x, a.y < b.y);
}

bool inBounds_swap(float2 p) {
    return all(lessThan_swap(float2(0.0, 0.0), p)) && all(lessThan_swap(p, float2(1.0, 1.0)));
}

float2 project(float2 p) {
    return p * float2(1.0, -1.2) + float2(0.0, -0.02);
}

kernel void transition_swap(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                    texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                    texture2d<float, access::write> outTexture [[ texture(2) ]],
                                    device const float *progress [[ buffer(0) ]],
                                    uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 p= float2(gid) / sizeTx;
    
    float reflection = 0.4;
    float perspective = 0.2;
    float depth = 3.0;
    
    float2 pfr, pto = float2(-1.);
    
    float size = mix(1.0, depth, prog);
    float persp = perspective * prog;
    pfr = (p + float2(-0.0, -0.5)) * float2(size / (1.0 - perspective * prog), size / (1.0 - size * persp * p.x)) + float2(0.0, 0.5);
    
    size = mix(1.0, depth, 1. - prog);
    persp = perspective * (1. - prog);
    pto = (p + float2(-1.0, -0.5)) * float2(size / (1.0 - perspective * (1.0 - prog)), size / (1.0 - size * persp * (0.5 - p.x))) + float2(1.0, 0.5);
    
    if (prog < 0.5) {
        if (inBounds_swap(pfr)) {
            outTexture.write(inTexture.read(uint2(pfr * sizeTx)), gid);
            return;
        }
        if (inBounds_swap(pto)) {
            outTexture.write(inTexture2.read(uint2(pto * sizeTx)), gid);
            return;
        }
    }
    
    if (inBounds_swap(pto)) {
        outTexture.write(inTexture2.read(uint2(pto * sizeTx)), gid);
        return;
    }
    
    if (inBounds_swap(pfr)) {
        outTexture.write(inTexture.read(uint2(pfr * sizeTx)), gid);
        return;
    }
    
    float4 c = float4(0.0, 0.0, 0.0, 1.0);
    pfr = project(pfr);
    if (inBounds_swap(pfr)) {
        c += mix(float4(0.0, 0.0, 0.0, 1.0), inTexture.read(uint2(pfr * sizeTx)), reflection * mix(1.0, 0.0, pfr.y));
    }
    pto = project(pto);
    if (inBounds_swap(pto)) {
        c += mix(float4(0.0, 0.0, 0.0, 1.0), inTexture2.read(uint2(pfr * sizeTx)), reflection * mix(1.0, 0.0, pto.y));
    }
    
    outTexture.write(c, gid);
}
