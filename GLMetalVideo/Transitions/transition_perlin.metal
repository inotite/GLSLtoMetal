//
//  transition_perlin.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/16/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float random(float2 co, float seed)
{
    float a = seed;
    float b = 78.233;
    float c = 43758.5453;
    float dt= dot(co.xy ,float2(a,b));
    float sn= fmod(dt, 3.14);
    return fract(sin(sn) * c);
}

float noise (float2 st, float seed) {
    float2 i = floor(st);
    float2 f = fract(st);
    
    // Four corners in 2D of a tile
    float a = random(i, seed);
    float b = random(i + float2(1.0, 0.0), seed);
    float c = random(i + float2(0.0, 1.0), seed);
    float d = random(i + float2(1.0, 1.0), seed);
    
    // Smooth Interpolation
    
    // Cubic Hermine Curve.  Same as SmoothStep()
    float2 u = f*f*(3.0-2.0*f);
    // u = smoothstep(0.,1.,f);
    
    // Mix 4 coorners porcentages
    return mix(a, b, u.x) +
    (c - a)* u.y * (1.0 - u.x) +
    (d - b) * u.x * u.y;
}

kernel void transition_perlin(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                            texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                            texture2d<float, access::write> outTexture [[ texture(2) ]],
                                            device const float *progress [[ buffer(0) ]],
                                            uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 uv= float2(gid) / sizeTx;
    
    float scale = 4.0;
    float smoothness = 0.01;
    float seed = 12.9898;
    
    float4 from = inTexture.read(gid);
    float4 to = inTexture2.read(gid);
    
    float n = noise(uv * scale, seed);
    float p = mix(-smoothness, 1.0 + smoothness, prog);
    float lower = p - smoothness;
    float higher = p + smoothness;
    
    float q = smoothstep(lower, higher, n);
    
    outTexture.write( mix(from, to, 1.0 - q), gid );
}
