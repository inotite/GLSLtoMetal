//
//  transition_mosaic.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#define PI 3.14159265358979323
#define POW2(X) (X)*(X)

float Rand(float2 v) {
    return fract(sin(dot(v.xy, float2(12.9898, 78.233))) * 43758.5453);
}

float2 Rotate(float2 v, float a) {
    a = a * 180 / PI;
    float2x2 rm = float2x2(cos(a), -sin(a), sin(a), cos(a));
    
    return rm * v;
}

float CosInterpolation(float x) {
    return -cos(x * PI) / 2. + .5;
}

kernel void transition_mosaic(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                    texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                    texture2d<float, access::write> outTexture [[ texture(2) ]],
                                    device const float *progress [[ buffer(0) ]],
                                    uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    
    int endx = 2;
    int endy = 2;
    
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 uv= float2(gid) / sizeTx;
    
    float2 p = uv - float2(.5);
    float2 rp = p;
    
    float rpr = (prog * 2. - 1.);
    float z = -(rpr * rpr * 2.) + 3.;
    float az = abs(z);
    
    rp *= az;
    rp += mix(float2(.5, .5), float2(float(endx) + .5, float(endy) + .5), POW2(CosInterpolation(prog)));
    
    float2 mrp = fmod(rp, float2(1.));
    float2 crp = rp;
    bool onEnd = int(floor(crp.x)) == endx && int(floor(crp.y)) == endy;
    
    if (!onEnd) {
        float ang = float(int(Rand(floor(crp)) * 4.)) * .5 * PI;
        mrp = float2(.5) + Rotate(mrp - float2(.5), ang);
    }
    
    if (onEnd || Rand(floor(crp)) > .5) {
        outTexture.write(inTexture2.read(uint2(mrp * sizeTx)), gid);
    }
    else {
        outTexture.write(inTexture.read(uint2(mrp * sizeTx)), gid);
    }
    
}
