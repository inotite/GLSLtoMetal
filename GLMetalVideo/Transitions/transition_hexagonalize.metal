//
//  transition_hexagonalize.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/16/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Hexagon {
    float q;
    float r;
    float s;
};

Hexagon createHexagon(float q, float r) {
    Hexagon hex;
    hex.q = q;
    hex.r = r;
    hex.s = -q - r;
    return hex;
}

Hexagon roundHexagon(Hexagon hex){
    
    float q = floor(hex.q + 0.5);
    float r = floor(hex.r + 0.5);
    float s = floor(hex.s + 0.5);
    
    float deltaQ = abs(q - hex.q);
    float deltaR = abs(r - hex.r);
    float deltaS = abs(s - hex.s);
    
    if (deltaQ > deltaR && deltaQ > deltaS)
        q = -r - s;
    else if (deltaR > deltaS)
        r = -q - s;
    else
        s = -q - r;
    
    return createHexagon(q, r);
}

Hexagon hexagonFromPoint(float2 point, float size, float ratio) {
    
    point.y /= ratio;
    point = (point - 0.5) / size;
    
    float q = (sqrt(3.0) / 3.0) * point.x + (-1.0 / 3.0) * point.y;
    float r = 0.0 * point.x + 2.0 / 3.0 * point.y;
    
    Hexagon hex = createHexagon(q, r);
    return roundHexagon(hex);
    
}

float2 pointFromHexagon(Hexagon hex, float size, float ratio) {
    
    float x = (sqrt(3.0) * hex.q + (sqrt(3.0) / 2.0) * hex.r) * size + 0.5;
    float y = (0.0 * hex.q + (3.0 / 2.0) * hex.r) * size + 0.5;
    
    return float2(x, y * ratio);
}

kernel void transition_hexagonalize(texture2d<float, access::read> inTexture [[ texture(0) ]],
                             texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                             texture2d<float, access::write> outTexture [[ texture(2) ]],
                             device const float *progress [[ buffer(0) ]],
                             uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 uv = float2(gid) / sizeTx;
    
    int steps = 50;
    float horizontalHexagons = 20;
    
    float ratio = sizeTx.x / sizeTx.y;
    float dist = 2.0 * min(prog, 1.0 - prog);
    dist = steps > 0 ? ceil(dist * float(steps)) / float(steps) : dist;
    
    float size = (sqrt(3.0) / 3.0) * dist / horizontalHexagons;
    
    float2 point = dist > 0.0 ? pointFromHexagon(hexagonFromPoint(uv, size, ratio), size, ratio) : uv;
    
    outTexture.write(mix(inTexture.read(uint2(point * sizeTx)), inTexture2.read(uint2(point * sizeTx)), prog), gid);
    
}
