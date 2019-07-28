//
//  transition_stereoviewer.metal
//  GLMetalVideo
//
//  Created by HeRo Gold on 7/16/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#define zoom 0.88
#define corder_radius 0.22


// Check if a point is within a given corner
bool in_corner(float2 p, float2 corner, float2 radius) {
    // determine the direction we want to be filled
    float2 axis = (float2(1.0, 1.0) - corner) - corner;
    
    // warp the point so we are always testing the bottom left point with the
    // circle centered on the origin
    p = p - (corner + axis * radius);
    p *= axis / radius;
    return (p.x > 0.0 && p.y > -1.0) || (p.y > 0.0 && p.x > -1.0) || dot(p, p) < 1.0;
}

// Check all four corners
// return a float for v2 for anti-aliasing?
bool test_rounded_mask(float2 p, float2 corner_size) {
    return
    in_corner(p, float2(0.0, 0.0), corner_size) &&
    in_corner(p, float2(0.0, 1.0), corner_size) &&
    in_corner(p, float2(1.0, 0.0), corner_size) &&
    in_corner(p, float2(1.0, 1.0), corner_size);
}

// Screen blend mode - https://en.wikipedia.org/wiki/Blend_modes
// This more closely approximates what you see than linear blending
float4 screen(float4 a, float4 b) {
    return 1.0 - (1.0 - a) * (1.0 -b);
}

// Given RGBA, find a value that when screened with itself
// will yield the original value.
float4 unscreen(float4 c) {
    return 1.0 - sqrt(1.0 - c);
}

float4 getFromColor(float2 p, texture2d<float, access::read> texture [[ texture(0) ]]) {
    float2 size = float2(texture.get_width(), texture.get_height());
    return texture.read(uint2(p * size));
}

float4 getToColor(float2 p, texture2d<float, access::read> texture [[ texture(0) ]]) {
    float2 size = float2(texture.get_width(), texture.get_height());
    return texture.read(uint2(p * size));
}

// Grab a pixel, only if it isn't masked out by the rounded corners
float4 sample_with_corners_from(float2 p, float2 corner_size, texture2d<float, access::read> texture [[ texture(0) ]]) {
    p = (p - 0.5) / zoom + 0.5;
    if (!test_rounded_mask(p, corner_size)) {
        return float4(0.0, 0.0, 0.0, 1.0);
    }
    return unscreen(getFromColor(p, texture));
}

float4 sample_with_corners_to(float2 p, float2 corner_size, texture2d<float, access::read> texture [[ texture(0) ]]) {
    p = (p - 0.5) / zoom + 0.5;
    if (!test_rounded_mask(p, corner_size)) {
        return float4(0.0, 0.0, 0.0, 1.0);
    }
    return unscreen(getToColor(p, texture));
}

// special sampling used when zooming - extra zoom parameter and don't unscreen
float4 simple_sample_with_corners_from(float2 p, float2 corner_size, float zoom_amt, texture2d<float, access::read> texture [[ texture(0) ]]) {
    p = (p - 0.5) / (1.0 - zoom_amt + zoom * zoom_amt) + 0.5;
    if (!test_rounded_mask(p, corner_size)) {
        return float4(0.0, 0.0, 0.0, 1.0);
    }
    return getFromColor(p, texture);
}

float4 simple_sample_with_corners_to(float2 p, float2 corner_size, float zoom_amt, texture2d<float, access::read> texture [[ texture(0) ]]) {
    p = (p - 0.5) / (1.0 - zoom_amt + zoom * zoom_amt) + 0.5;
    if (!test_rounded_mask(p, corner_size)) {
        return float4(0.0, 0.0, 0.0, 1.0);
    }
    return getToColor(p, texture);
}

// Basic 2D affine transform matrix helpers
// These really shouldn't be used in a fragment shader - I should work out the
// the math for a translate & rotate function as a pair of dot products instead

float3x3 rotate2d(float angle, float ratio) {
    float s = sin(angle);
    float c = cos(angle);
    return float3x3(
                    c, s ,0.0,
                    -s, c, 0.0,
                    0.0, 0.0, 1.0);
}

float3x3 translate2d(float x, float y) {
    return float3x3(
                    1.0, 0.0, 0,
                    0.0, 1.0, 0,
                    -x, -y, 1.0);
}

float3x3 scale2d(float x, float y) {
    return float3x3(
                    x, 0.0, 0,
                    0.0, y, 0,
                    0, 0, 1.0);
}

// Split an image and rotate one up and one down along off screen pivot points
float4 get_cross_rotated(float3 p3, float angle, float2 corner_size, float ratio, texture2d<float, access::read> texture [[ texture(0) ]]) {
    angle = angle * angle; // easing
    angle /= 2.4; // works out to be a good number of radians
    
    float3x3 center_and_scale = translate2d(-0.5, -0.5) * scale2d(1.0, ratio);
    float3x3 unscale_and_uncenter = scale2d(1.0, 1.0/ratio) * translate2d(0.5,0.5);
    float3x3 slide_left = translate2d(-2.0,0.0);
    float3x3 slide_right = translate2d(2.0,0.0);
    float3x3 rotate = rotate2d(angle, ratio);
    
    float3x3 op_a = center_and_scale * slide_right * rotate * slide_left * unscale_and_uncenter;
    float3x3 op_b = center_and_scale * slide_left * rotate * slide_right * unscale_and_uncenter;
    
    float4 a = sample_with_corners_from((op_a * p3).xy, corner_size, texture);
    float4 b = sample_with_corners_from((op_b * p3).xy, corner_size, texture);
    
    return screen(a, b);
}

// Image stays put, but this time move two masks
float4 get_cross_masked(float3 p3, float angle, float2 corner_size, float ratio, texture2d<float, access::read> texture [[ texture(0) ]]) {
    angle = 1.0 - angle;
    angle = angle * angle; // easing
    angle /= 2.4;
    
    float4 img;
    
    float3x3 center_and_scale = translate2d(-0.5, -0.5) * scale2d(1.0, ratio);
    float3x3 unscale_and_uncenter = scale2d(1.0 / zoom, 1.0 / (zoom * ratio)) * translate2d(0.5,0.5);
    float3x3 slide_left = translate2d(-2.0,0.0);
    float3x3 slide_right = translate2d(2.0,0.0);
    float3x3 rotate = rotate2d(angle, ratio);
    
    float3x3 op_a = center_and_scale * slide_right * rotate * slide_left * unscale_and_uncenter;
    float3x3 op_b = center_and_scale * slide_left * rotate * slide_right * unscale_and_uncenter;
    
    bool mask_a = test_rounded_mask((op_a * p3).xy, corner_size);
    bool mask_b = test_rounded_mask((op_b * p3).xy, corner_size);
    
    if (mask_a || mask_b) {
        img = sample_with_corners_to(p3.xy, corner_size, texture);
        return screen(mask_a ? img : float4(0.0, 0.0, 0.0, 1.0), mask_b ? img : float4(0.0, 0.0, 0.0, 1.0));
    } else {
        return float4(0.0, 0.0, 0.0, 1.0);
    }
}

kernel void transition_stereoviewer(texture2d<float, access::read> inTexture [[ texture(0) ]],
                                    texture2d<float, access::read> inTexture2 [[ texture(1) ]],
                                    texture2d<float, access::write> outTexture [[ texture(2) ]],
                                    device const float *progress [[ buffer(0) ]],
                                    uint2 gid [[ thread_position_in_grid ]])
{
    float prog = 1.0 - *progress;
    float2 sizeTx = float2(outTexture.get_width(), outTexture.get_height());
    float2 uv = float2(gid) / sizeTx;
    float ratio = sizeTx.x / sizeTx.y;
    
    float a;
    float2 p = uv.xy / float2(1.0).xy;
    float3 p3 = float3(p.xy, 1.0);
    
    float2 corner_size = float2(corder_radius / ratio, corder_radius);
    
    if (prog <= 0.0) {
        outTexture.write(getFromColor(p, inTexture), gid);
    }
    else if(prog < 0.1) {
        a = prog / 0.1;
        outTexture.write(simple_sample_with_corners_from(p, corner_size * a, a, inTexture), gid);
    }
    else if(prog < 0.48) {
        a = (prog - 0.1) / 0.38;
        outTexture.write(get_cross_rotated(p3, a, corner_size, ratio, inTexture), gid);
    }
    else if(prog < 0.9) {
        outTexture.write(get_cross_masked(p3, (prog - 0.52) / 0.38, corner_size, ratio, inTexture2), gid);
    }
    else if(prog < 1.0) {
        a = (1.0 - prog) / 0.1;
        outTexture.write(simple_sample_with_corners_to(p, corner_size * a, a, inTexture2), gid);
    }
    else {
        outTexture.write(getToColor(p, inTexture2), gid);
    }
    
}
