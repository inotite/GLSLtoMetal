//
//  transition_radial.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_radial(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                   texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                   texture2d<float, access::write> outTexture [[ texture(2) ]],
                                   device const float *progress [[ buffer(0) ]],
                                   uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float smoothness = 1.0;
    
    const float PI = 3.141592653589;
    
    float2 p = float2(gid).xy / float2(inTexture.get_width(), inTexture.get_height()).xy;
    
    float2 rp = p * 2. - 1.;
    
    outTexture.write( mix( inTexture2.read(uint2(gid.x, inTexture2.get_height() - gid.y)), inTexture.read(uint2(gid.x, inTexture.get_height() - gid.y)), smoothstep(0., smoothness, atan2(rp.y, rp.x) - (prog - .5) * PI * 2.5) ), uint2(gid.x, outTexture.get_height()-gid.y));
}
