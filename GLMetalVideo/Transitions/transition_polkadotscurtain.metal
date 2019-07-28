//
//  transition_polkadotscurtain.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/15/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void transition_polkadotscurtain(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                texture2d<float, access::write> outTexture [[ texture(2) ]],
                                device const float *progress [[ buffer(0) ]],
                                uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
//    const float SQRT_2 = 1.414213562373;
    float dots = 20.0;
    float2 center = float2(0, 0);
    
    float2 sizeTx = float2(inTexture.get_width(), inTexture.get_height());
    float2 uv = float2(gid) / sizeTx;
    
    bool nextImage = distance(fract(uv * dots), float2(0.5, 0.5)) < (prog / distance(uv, center));
    
    uint2 ngid = uint2(gid.x, sizeTx.y - gid.y);
    
    outTexture.write( nextImage ? inTexture2.read(ngid) : inTexture.read(ngid), ngid);
}
