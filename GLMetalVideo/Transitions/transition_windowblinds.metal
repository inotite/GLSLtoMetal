//
//  transition_windowblinds.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float mod(float x, float y) {
    return x - y * floor(x / y);
}

kernel void transition_windowblinds(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                      texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                      texture2d<float, access::write> outTexture [[ texture(2) ]],
                                      device const float *progress [[ buffer(0) ]],
                                      uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float t = prog;
    
    float2 size = float2(inTexture.get_width(), inTexture.get_height());
    float2 uv = float2(gid) / size;
    
    if (mod(floor(uv.y * 100. * prog), 2.) == 0.)
        t *= 2. - .5;
    
    outTexture.write( mix(inTexture.read(gid), inTexture2.read(gid), mix(t, prog, smoothstep(0.8, 1.0, prog))), gid);
}
