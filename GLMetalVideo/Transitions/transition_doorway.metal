//
//  transition_doorway.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/16/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

bool2 lessThan__(float2 a, float2 b) {
    return bool2(a.x < b.x, a.y < b.y);
}

bool inBounds__ (float2 p) {
    return all(lessThan__(float2(0.0, 0.0), p)) && all(lessThan__(p, float2(1.0, 1.0)));
}

float2 project__ (float2 p) {
    return p * float2(1.0, -1.2) + float2(0.0, -0.02);
}

kernel void transition_doorway(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                    texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                    texture2d<float, access::write> outTexture [[ texture(2) ]],
                                    device const float *progress [[ buffer(0) ]],
                                    uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 p = float2(gid) / sizeTx;
    
    float reflection = 0.4;
    float perspective = 0.4;
    float depth = 3;
    
    float2 pfr = float2(-1.);
    float2 pto = float2(-1.);
    
    float middleSlit = 2.0 * abs(p.x - 0.5) - prog;
    if (middleSlit > 0.0) {
        pfr = p + (p.x > 0.5 ? -1.0 : 1.0) * float2(0.5 * prog, 0.0);
        float d = 1.0 / (1.0 + perspective * prog * (1.0 - middleSlit));
        pfr.y -= d / 2.;
        pfr.y *= d;
        pfr.y += d / 2.;
    }
    
    float size = mix(1.0, depth, 1. - prog);
    pto = (p + float2(-0.5, -0.5)) * float2(size, size) + float2(0.5, 0.5);
    if (inBounds__(pfr)) {
        outTexture.write(inTexture.read(uint2(pfr * sizeTx)), gid);
    }
    else if (inBounds__(pto)) {
        outTexture.write(inTexture2.read(uint2(pto * sizeTx)), gid);
    }
    else {
        float4 c = float4(0.0, 0.0, 0.0, 1.0);
        pto = project__(pto);
        if (inBounds__(pto)) {
            c += mix( c, inTexture2.read(uint2(pto * sizeTx)), reflection * mix(1.0, 0.0, pto.y));
        }
        outTexture.write( c, gid );
    }
}
