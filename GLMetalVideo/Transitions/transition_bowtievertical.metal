//
//  transition_bowtievertical.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/16/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float check(float2 p1, float2 p2, float2 p3)
{
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
}

bool PointInTriangle (float2 pt, float2 p1, float2 p2, float2 p3)
{
    bool b1, b2, b3;
    b1 = check(pt, p1, p2) < 0.0;
    b2 = check(pt, p2, p3) < 0.0;
    b3 = check(pt, p3, p1) < 0.0;
    return ((b1 == b2) && (b2 == b3));
}

bool in_top_triangle(float2 p, float progress){
    float2 vertex1, vertex2, vertex3;
    vertex1 = float2(0.5, progress);
    vertex2 = float2(0.5-progress, 0.0);
    vertex3 = float2(0.5+progress, 0.0);
    if (PointInTriangle(p, vertex1, vertex2, vertex3))
    {
        return true;
    }
    return false;
}

bool in_bottom_triangle(float2 p, float progress){
    float2 vertex1, vertex2, vertex3;
    vertex1 = float2(0.5, 1.0 - progress);
    vertex2 = float2(0.5-progress, 1.0);
    vertex3 = float2(0.5+progress, 1.0);
    if (PointInTriangle(p, vertex1, vertex2, vertex3))
    {
        return true;
    }
    return false;
}

float blur_edge(float2 bot1, float2 bot2, float2 top, float2 testPt)
{
    float2 lineDir = bot1 - top;
    float2 perpDir = float2(lineDir.y, -lineDir.x);
    float2 dirToPt1 = bot1 - testPt;
    float dist1 = abs(dot(normalize(perpDir), dirToPt1));
    
    lineDir = bot2 - top;
    perpDir = float2(lineDir.y, -lineDir.x);
    dirToPt1 = bot2 - testPt;
    float min_dist = min(abs(dot(normalize(perpDir), dirToPt1)), dist1);
    
    if (min_dist < 0.005) {
        return min_dist / 0.005;
    }
    else  {
        return 1.0;
    };
}

kernel void transition_bowtievertical(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                  texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                  texture2d<float, access::write> outTexture [[ texture(2) ]],
                                  device const float *progress [[ buffer(0) ]],
                                  uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 uv= float2(gid) / sizeTx;
    
    if (in_top_triangle(uv, prog))
    {
        if (prog < 0.1)
        {
            outTexture.write(inTexture.read(gid), gid);
        }
        if (uv.y < 0.5)
        {
            float2 vertex1 = float2(0.5, prog);
            float2 vertex2 = float2(0.5-prog, 0.0);
            float2 vertex3 = float2(0.5+prog, 0.0);
            outTexture.write(mix(
                       inTexture.read(gid),
                       inTexture2.read(gid),
                       blur_edge(vertex2, vertex3, vertex1, uv)
                       ), gid);
        }
        else
        {
            if (prog > 0.0)
            {
                outTexture.write(inTexture2.read(gid), gid);
            }
            else
            {
                outTexture.write(inTexture.read(gid), gid);
            }
        }
    }
    else if (in_bottom_triangle(uv, prog))
    {
        if (uv.y >= 0.5)
        {
            float2 vertex1 = float2(0.5, 1.0-prog);
            float2 vertex2 = float2(0.5-prog, 1.0);
            float2 vertex3 = float2(0.5+prog, 1.0);
            outTexture.write(mix(
                                 inTexture.read(gid),
                                 inTexture2.read(gid),
                                 blur_edge(vertex2, vertex3, vertex1, uv)
                                 ), gid);
        }
        else
        {
            outTexture.write(inTexture.read(gid), gid);
        }
    }
    else {
        outTexture.write(inTexture.read(gid), gid);
    }
}
