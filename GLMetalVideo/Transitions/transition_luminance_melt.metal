//
//  transition_luminance_melt.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/16/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float rand_luminance(float2 co) {
    return fract(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
}

float3 mod289(float3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float2 mod289(float2 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float3 permute(float3 x) {
    return mod289(((x*34.0)+1.0)*x);
}

float snoise(float2 v)
{
    const float4 C = float4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626,  // -1.0 + 2.0 * C.x
                        0.024390243902439); // 1.0 / 41.0
    // First corner
    float2 i  = floor(v + dot(v, C.yy) );
    float2 x0 = v -   i + dot(i, C.xx);
    
    // Other corners
    float2 i1;
    //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
    //i1.y = 1.0 - i1.x;
    i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
    // x0 = x0 - 0.0 + 0.0 * C.xx ;
    // x1 = x0 - i1 + 1.0 * C.xx ;
    // x2 = x0 - 1.0 + 2.0 * C.xx ;
    float4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    
    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    float3 p = permute( permute( i.y + float3(0.0, i1.y, 1.0 ))
                     + i.x + float3(0.0, i1.x, 1.0 ));
    
    float3 m = max(0.5 - float3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;
    
    // Gradients: 41 points uniformly over a line, mapped onto a diamond.
    // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)
    
    float3 x = 2.0 * fract(p * C.www) - 1.0;
    float3 h = abs(x) - 0.5;
    float3 ox = floor(x + 0.5);
    float3 a0 = x - ox;
    
    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt( a0*a0 + h*h );
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
    
    // Compute final noise value at P
    float3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

// Simplex noise -- end

float luminance(float4 color){
    //(0.299*R + 0.587*G + 0.114*B)
    return color.r*0.299+color.g*0.587+color.b*0.114;
}

kernel void transition_luminance_melt(texture2d<float, access::read> inTexture [[ texture(0) ]],
                             texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                             texture2d<float, access::write> outTexture [[ texture(2) ]],
                             device const float *progress [[ buffer(0) ]],
                             uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 uv = float2(gid) / sizeTx;
    
    bool direction = 1;
    float l_threshold = 0.8;
    bool above = false;
    
    float2 p = uv.xy / float2(1.0).xy;
    
    if (prog == 0.0) {
        outTexture.write(inTexture.read(uint2(gid.x, sizeTx.y - gid.y)), uint2(gid.x, sizeTx.y - gid.y));
    }
    else if(prog == 1.0) {
        outTexture.write(inTexture2.read(uint2(gid.x, sizeTx.y - gid.y)), uint2(gid.x, sizeTx.y - gid.y));
    }
    else {
        float x = prog;
        float dist = distance(float2(1.0, direction), p) - prog * exp(snoise(float2(p.x, 0.0)));
        float r = x - rand_luminance(float2(p.x, 0.1));
        float m;
        if (above) {
            m = dist <= r && luminance(inTexture.read(uint2(gid.x, sizeTx.y - gid.y))) > l_threshold ? 1.0 : (prog * prog * prog);
        }
        else {
            m = dist <= r && luminance(inTexture.read(uint2(gid.x, sizeTx.y - gid.y))) < l_threshold ? 1.0 : (prog * prog * prog);
        }
        outTexture.write( mix(inTexture.read(uint2(gid.x, sizeTx.y - gid.y)), inTexture2.read(uint2(gid.x, sizeTx.y - gid.y)), m), uint2(gid.x, sizeTx.y - gid.y) );
    }
}
