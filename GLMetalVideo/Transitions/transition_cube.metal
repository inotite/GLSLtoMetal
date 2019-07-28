//
//  transition_cube.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

bool2 lessThan(float2 a, float2 b) {
    return bool2(a.x < b.x, a.y < b.y);
}

float2 project(float2 p, float floating) {
    return p * float2(1.0, -1.2) + float2(0.0, -floating / 100.);
}

bool inBounds(float2 p) {
    return all(lessThan(float2(0.0), p)) && all(lessThan(p, float2(1.0)));
}

float2 xskew(float2 p, float persp, float center) {
    float x = mix(p.x, 1.0 - p.x, center);
    
    return (
            float2(x, (p.y - 0.5 * (1.0 - persp) * x) / (1.0 + (persp - 1.0) * x) ) - float2(0.5 - fabs(center - 0.5), 0.0)
           )
           * float2(0.5 / fabs(center - 0.5) * (center < 0.5 ? 1.0 : -1.0), 1.0)
           + float2(center < 0.5 ? 0.0 : 1.0, 0.0);
}

kernel void transition_cube(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                  texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                  texture2d<float, access::write> outTexture [[ texture(2) ]],
                                  device const float *progress [[ buffer(0) ]],
                                  uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float persp = 0.7;
    float unzoom = 0.3;
    float reflection = 0.4;
    float floating = 3.0;
    
    float2 sizeTx = float2(inTexture.get_width(), inTexture.get_height());
    float2 op = float2(gid) / sizeTx;
    
    float uz = unzoom * 2.0 * (0.5 - fabs(0.5-prog));
    float2 p = -uz * 0.5 + (1.0 + uz) * op;
    
    float2 fromP = xskew( (p - float2(prog, 0)) / float2(1.0 - prog, 1.0), 1.0 - mix(prog, 0.0, persp), 0.0 );
    float2 toP = xskew( p / float2(prog, 1.0), mix(pow(prog, 2.0), 1.0, persp), 1.0 );
    
    if (inBounds(fromP))
        outTexture.write(inTexture.read(uint2(fromP * sizeTx)), gid);
    else if(inBounds(toP))
        outTexture.write(inTexture2.read(uint2(toP * sizeTx)), gid);
    else {
        float4 c = float4(0.0, 0.0, 0.0, 1.0);
        
        fromP = project(fromP, floating);
        if (inBounds(fromP)) {
            c += mix(float4(0.0), inTexture.read(uint2(fromP * sizeTx)), reflection * mix(1.0, 0.0, fromP.y));
        }
        toP = project(toP, floating);
        if (inBounds(toP)) {
            c += mix(float4(0.0), inTexture2.read(uint2(toP * sizeTx)), reflection * mix(1.0, 0.0, toP.y));
        }
        outTexture.write(c, gid);
    }
}

