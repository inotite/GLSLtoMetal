//
//  transition_undulatingburnout.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#define M_PI 3.14159265358979323846

float quadraticInOut(float t) {
    float p = 2.0 * t * t;
    return t < 0.5 ? p : -p + (4.0 * t) - 1.0;
}

float getGradient(float r, float dist, float smoothness) {
    float d = r - dist;
    return mix(
               smoothstep(-smoothness, 0.0, r - dist * (1.0 + smoothness)),
               -1.0 - step(0.005, d),
               step(-0.005, d) * step(d, 0.01)
               );
}

float degrees(float radians) {
    return 180 * radians / M_PI;
}

float getWave(float2 p, float2 center, float prog){
    float2 _p = p - center; // offset from center
    float rads = atan2(_p.y, _p.x);
    float degs = degrees(rads) + 180.0;
    float2 range = float2(0.0, M_PI * 30.0);
    float2 domain = float2(0.0, 360.0);
    float ratio = (M_PI * 30.0) / 360.0;
    degs = degs * ratio;
    float x = prog;
    float magnitude = mix(0.02, 0.09, smoothstep(0.0, 1.0, x));
    float offset = mix(40.0, 30.0, smoothstep(0.0, 1.0, x));
    float ease_degs = quadraticInOut(sin(degs));
    float deg_wave_pos = (ease_degs * magnitude) * sin(x * offset);
    return x + deg_wave_pos;
}

kernel void transition_undulatingburnout(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                  texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                  texture2d<float, access::write> outTexture [[ texture(2) ]],
                                  device const float *progress [[ buffer(0) ]],
                                  uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(inTexture.get_width(), inTexture.get_height());
    float2 p = float2(gid) / sizeTx;
    
    float smoothness = 0.03;
    float2 center = float2(0.5);
    float3 color = float3(0.0);
    
    float dist = distance(center, p);
    float m = getGradient(getWave(p, center, prog), dist, smoothness);
    float4 cfrom = inTexture.read(gid);
    float4 cto = inTexture2.read(gid);
    
    outTexture.write(mix(mix(cfrom, cto, m), mix(cfrom, float4(color, 1.0), 0.75), step(m, -2.0)), gid);
}
