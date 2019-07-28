//
//  transition_invertedpagecurl.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/16/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#define PI 3.141592653589793
#define MIN_AMOUNT -0.16
#define MAX_AMOUNT 1.5
#define scale 512.0
#define sharpness 3.0

float3 hitPoint(float hitAngle, float yc, float3 point, float3x3 rrotation)
{
    float hitPoint = hitAngle / (2.0 * PI);
    point.y = hitPoint;
    return rrotation * point;
}

float4 antiAlias(float4 color1, float4 color2, float distanc)
{
    distanc *= scale;
    if (distanc < 0.0) return color2;
    if (distanc > 2.0) return color1;
    float dd = pow(1.0 - distanc / 2.0, sharpness);
    return ((color2 - color1) * dd) + color1;
}

float distanceToEdge(float3 point)
{
    float dx = abs(point.x > 0.5 ? 1.0 - point.x : point.x);
    float dy = abs(point.y > 0.5 ? 1.0 - point.y : point.y);
    if (point.x < 0.0) dx = -point.x;
    if (point.x > 1.0) dx = point.x - 1.0;
    if (point.y < 0.0) dy = -point.y;
    if (point.y > 1.0) dy = point.y - 1.0;
    if ((point.x < 0.0 || point.x > 1.0) && (point.y < 0.0 || point.y > 1.0)) return sqrt(dx * dx + dy * dy);
    return min(dx, dy);
}

kernel void transition_invertedpagecurl(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                    texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                    texture2d<float, access::write> outTexture [[ texture(2) ]],
                                    device const float *progress [[ buffer(0) ]],
                                    uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 p = float2(gid) / sizeTx;
    
    float amount = prog * (MAX_AMOUNT - MIN_AMOUNT) + MIN_AMOUNT;
    float cylinderCenter = amount;
    float cylinderAngle = 2.0 * PI * amount;
    const float cylinderRadius = 1.0 / PI / 2.0;
    
    const float angle = 100.0 * PI / 180.0;
    float c = cos(-angle);
    float s = sin(-angle);
    
    float3x3 rotation = float3x3( c, s, 0,
                         -s, c, 0,
                         -0.801, 0.8900, 1
                         );
    c = cos(angle);
    s = sin(angle);
    
    float3x3 rrotation = float3x3(    c, s, 0,
                          -s, c, 0,
                          0.98500, 0.985, 1
                          );
    
    float3 point = rotation * float3(p, 1.0);
    
    float yc = point.y - cylinderCenter;
    
    if (yc < -cylinderRadius)
    {
        // Behind surface
        float shado = (1.0 - ((-cylinderRadius - yc) / amount * 7.0)) / 6.0;
        shado *= 1.0 - abs(point.x - 0.5);
        
        yc = (-cylinderRadius - cylinderRadius - yc);
        
        float hitAngle = (acos(yc / cylinderRadius) + cylinderAngle) - PI;
        point = hitPoint(hitAngle, yc, point, rrotation);
        
        if (yc < 0.0 && point.x >= 0.0 && point.y >= 0.0 && point.x <= 1.0 && point.y <= 1.0 && (hitAngle < PI || amount > 0.5))
        {
            shado = 1.0 - (sqrt(pow(point.x - 0.5, 2.0) + pow(point.y - 0.5, 2.0)) / (71.0 / 100.0));
            shado *= pow(-yc / cylinderRadius, 3.0);
            shado *= 0.5;
        }
        else
        {
            shado = 0.0;
        }
        outTexture.write(float4(inTexture2.read(uint2(gid.x, sizeTx.y - gid.y)).rgb - shado, 1.0), uint2(gid.x, sizeTx.y - gid.y));
        return;
    }
    
    if (yc > cylinderRadius)
    {
        // Flat surface
        outTexture.write(inTexture.read(uint2(gid.x, sizeTx.y - gid.y)), uint2(gid.x, sizeTx.y - gid.y));
    }
    
    float hitAngle = (acos(yc / cylinderRadius) + cylinderAngle) - PI;
    
    float hitAngleMod = fmod(hitAngle, 2.0 * PI);
    if ((hitAngleMod > PI && amount < 0.5) || (hitAngleMod > PI/2.0 && amount < 0.0))
    {
        float hitAngle = PI - (acos(yc / cylinderRadius) - cylinderAngle);
        float3 point = hitPoint(hitAngle, yc, rotation * float3(p, 1.0), rrotation);
        if (yc <= 0.0 && (point.x < 0.0 || point.y < 0.0 || point.x > 1.0 || point.y > 1.0))
        {
            outTexture.write(inTexture2.read(uint2(gid.x, sizeTx.y - gid.y)), uint2(gid.x, sizeTx.y - gid.y));
            return;
        }
        
        if (yc > 0.0) {
            outTexture.write(inTexture.read(uint2(gid.x, sizeTx.y - gid.y)), uint2(gid.x, sizeTx.y - gid.y));
            return;
        }
        
        float2 ngid = point.xy * sizeTx;
        float4 color = inTexture.read(uint2(ngid.x, sizeTx.y - ngid.y));
        float4 tcolor = float4(0.0);
        
        outTexture.write(antiAlias(color, tcolor, distanceToEdge(point)), uint2(gid.x, sizeTx.y - gid.y));
        return;
    }
    
    point = hitPoint(hitAngle, yc, point, rrotation);
    
    if (point.x < 0.0 || point.y < 0.0 || point.x > 1.0 || point.y > 1.0)
    {
        float shadow = distanceToEdge(point) * 30.0;
        shadow = (1.0 - shadow) / 3.0;
        float4 shadowColor;
        
        if (shadow < 0.0) shadow = 0.0; else shadow *= amount;
        
        float hitAngle = PI - (acos(yc / cylinderRadius) - cylinderAngle);
        float3 point = hitPoint(hitAngle, yc, rotation * float3(p, 1.0), rrotation);
        if (yc <= 0.0 && (point.x < 0.0 || point.y < 0.0 || point.x > 1.0 || point.y > 1.0))
        {
            shadowColor = inTexture2.read(uint2(gid.x, sizeTx.y - gid.y));
        }
        else if (yc > 0.0) {
            shadowColor = inTexture.read(uint2(gid.x, sizeTx.y - gid.y));
        }
        else {
            float2 ngid = point.xy * sizeTx;
            float4 color = inTexture.read(uint2(ngid.x, sizeTx.y - ngid.y));
            float4 tcolor = float4(0.0);
            
            shadowColor = antiAlias(color, tcolor, distanceToEdge(point));
        }
        shadowColor.r -= shadow;
        shadowColor.g -= shadow;
        shadowColor.b -= shadow;
        
        outTexture.write(shadowColor, uint2(gid.x, sizeTx.y - gid.y));
        return;
    }
    
    float2 ngid = point.xy * sizeTx;
    float4 color = inTexture.read(uint2(ngid.x, sizeTx.y - ngid.y));
    float gray = (color.r + color.b + color.g) / 15.0;
    gray += (8.0 / 10.0) * (pow(1.0 - abs(yc / cylinderRadius), 2.0 / 10.0) / 2.0 + (5.0 / 10.0));
    color.rgb = float3(gray);
    
    float4 otherColor;
    if (yc < 0.0)
    {
        float shado = 1.0 - (sqrt(pow(point.x - 0.5, 2.0) + pow(point.y - 0.5, 2.0)) / 0.71);
        shado *= pow(-yc / cylinderRadius, 3.0);
        shado *= 0.5;
        otherColor = float4(0.0, 0.0, 0.0, shado);
    }
    else
    {
        otherColor = inTexture.read(uint2(gid.x, sizeTx.y - gid.y));
    }
    
    color = antiAlias(color, otherColor, cylinderRadius - abs(yc));
    {
        float shadow = distanceToEdge(point) * 30.0;
        shadow = (1.0 - shadow) / 3.0;
        float4 shadowColor;
        
        if (shadow < 0.0) shadow = 0.0; else shadow *= amount;
        
        float hitAngle = PI - (acos(yc / cylinderRadius) - cylinderAngle);
        float3 point = hitPoint(hitAngle, yc, rotation * float3(p, 1.0), rrotation);
        if (yc <= 0.0 && (point.x < 0.0 || point.y < 0.0 || point.x > 1.0 || point.y > 1.0))
        {
            shadowColor = inTexture2.read(uint2(gid.x, sizeTx.y - gid.y));
        }
        else if (yc > 0.0) {
            shadowColor = inTexture.read(uint2(gid.x, sizeTx.y - gid.y));
        }
        else {
            float2 ngid = point.xy * sizeTx;
            float4 color = inTexture.read(uint2(ngid.x, sizeTx.y - ngid.y));
            float4 tcolor = float4(0.0);
            
            shadowColor = antiAlias(color, tcolor, distanceToEdge(point));
        }
        shadowColor.r -= shadow;
        shadowColor.g -= shadow;
        shadowColor.b -= shadow;
        
        float4 cl = shadowColor;
        float dist = distanceToEdge(point);
        
        outTexture.write( antiAlias(color, cl, dist), uint2(gid.x, sizeTx.y - gid.y));
    }
}
