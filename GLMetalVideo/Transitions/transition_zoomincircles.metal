//
//  transition_zoomincircles.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/16/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float2 zoom_(float2 uv, float amount) {
    return 0.5 + ((uv - 0.5) * amount);
}

kernel void transition_zoomincircles(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                  texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                  texture2d<float, access::write> outTexture [[ texture(2) ]],
                                  device const float *progress [[ buffer(0) ]],
                                  uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 uv = float2(gid) / sizeTx;
    float ratio = sizeTx.x / sizeTx.y;
    
    float2 ratio2 = float2(1.0, 1.0 / ratio);
    
    float2 r = 2.0 * ((float2(uv.xy) - 0.5) * ratio2);
    float pro = prog / 0.8;
    float z = pro * 0.2;
    float t = 0.0;
    if (pro > 1.0) {
        z = 0.2 + (pro - 1.0) * 5.;
        t = clamp((prog - 0.8) / 0.07, 0.0, 1.0);
    }
    if (length(r) < 0.5 + z) {
//        uv = zoom_(uv, 0.9 - 0.1 * pro);
    }
    else if (length(r) < 0.8 + z * 1.5) {
        uv = zoom_(uv, 1.0 - 0.15 * pro);
        t = t * 0.5;
    }
    else if (length(r) < 1.2 + z * 2.5) {
        uv = zoom_(uv, 1.0 - 0.2 * pro);
        t = t * 0.2;
    }
    else {
        uv = zoom_(uv, 1.0 - 0.25 * pro);
    }
    
    outTexture.write(mix(inTexture.read(uint2(uv * sizeTx)), inTexture2.read(uint2(uv * sizeTx)), t), gid);
}
