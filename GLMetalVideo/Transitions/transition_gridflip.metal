//
//  transition_gridflip.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/16/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float rand_grid (float2 co) {
    return fract(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
}

float getDelta(float2 p, int2 size) {
    float2 rectanglePos = floor(float2(size) * p);
    float2 rectangleSize = float2(1.0 / float2(size).x, 1.0 / float2(size).y);
    float top = rectangleSize.y * (rectanglePos.y + 1.0);
    float bottom = rectangleSize.y * rectanglePos.y;
    float left = rectangleSize.x * rectanglePos.x;
    float right = rectangleSize.x * (rectanglePos.x + 1.0);
    float minX = min(abs(p.x - left), abs(p.x - right));
    float minY = min(abs(p.y - top), abs(p.y - bottom));
    return min(minX, minY);
}

float getDividerSize(int2 size, float dividerWidth) {
    float2 rectangleSize = float2(1.0 / float2(size).x, 1.0 / float2(size).y);
    return min(rectangleSize.x, rectangleSize.y) * dividerWidth;
}

kernel void transition_gridflip(texture2d<float, access::read> inTexture [[ texture(0) ]],
                             texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                             texture2d<float, access::write> outTexture [[ texture(2) ]],
                             device const float *progress [[ buffer(0) ]],
                             uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 p = float2(gid) / sizeTx;
    
    int2 size = int2(4);
    float pause = 0.1;
    float dividerWidth = 0.05;
    float4 bgColor = float4(0.0, 0.0, 0.0, 1.0);
    float randomness = 0.1;
    
    if (prog < pause) {
        float currentProg = prog / pause;
        float a = 1.0;
        if (getDelta(p, size) < getDividerSize(size, dividerWidth)) {
            a = 1.0 - currentProg;
        }
        outTexture.write( mix(
                            bgColor, inTexture.read(gid), a
                         ), gid);
    }
    else if( prog < 1.0 - pause ) {
        if (getDelta(p, size) < getDividerSize(size, dividerWidth)) {
            outTexture.write(bgColor, gid);
        }
        else {
            float currentProg = (prog - pause) / (1.0 - pause * 2.0);
            float2 q = p;
            float2 rectanglePos = floor(float2(size) * q);
            
            float r = rand_grid(rectanglePos) - randomness;
            float cp = smoothstep(0.0, 1.0 - r, currentProg);
            
            float rectangleSize = 1.0 / float2(size).x;
            float delta = rectanglePos.x * rectangleSize;
            float offset = rectangleSize / 2.0 + delta;
            
            p.x = (p.x - offset) / abs(cp - 0.5) * 0.5 + offset;
            float4 a = inTexture.read(uint2(p * sizeTx));
            float4 b = inTexture2.read(uint2(p * sizeTx));
            
            float s = step(abs(float2(size).x * (q.x - delta) - 0.5), abs(cp - 0.5));
            outTexture.write( mix( bgColor, mix(b, a, step(cp, 0.5)), s), gid);
        }
    }
    else {
        float currentProg = (prog - 1.0 + pause) / pause;
        float a = 1.0;
        if (getDelta(p, size) < getDividerSize(size, dividerWidth)) {
            a = currentProg;
        }
        outTexture.write( mix(bgColor, inTexture2.read(gid), a), gid );
    }
}
