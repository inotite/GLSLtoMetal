//
//  transition_swirl.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/16/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


kernel void transition_swirl(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                             texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                             texture2d<float, access::write> outTexture [[ texture(2) ]],
                                             device const float *progress [[ buffer(0) ]],
                                             uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 UV = float2(gid) / sizeTx;
    
    float Radius = 1.0;
    float T = prog;
    
    UV -= float2(0.5, 0.5);
    
    float Dist = length(UV);
    
    if (Dist < Radius) {
        float Percent = (Radius - Dist) / Radius;
        float A = (T <= 0.5) ? mix(0.0, 1.0, T / .5) : mix(1.0, 0.0, (T - 0.5) / 0.5);
        float Theta = Percent * Percent * A * 8.0 * 3.14159;
        float S = sin(Theta);
        float C = cos(Theta);
        
        UV = float2( dot(UV, float2(C, -S)), dot(UV, float2(S, C)) );
    }
    
    UV += float2(0.5, 0.5);
    
    float2 ngid = (UV * sizeTx);
    
    float4 C0 = inTexture.read(uint2(ngid.x, sizeTx.y - ngid.y));
    float4 C1 = inTexture2.read(uint2(ngid.x, sizeTx.y - ngid.y));
    
    outTexture.write( mix(C0, C1, T), uint2(gid.x, sizeTx.y - gid.y) );
}
