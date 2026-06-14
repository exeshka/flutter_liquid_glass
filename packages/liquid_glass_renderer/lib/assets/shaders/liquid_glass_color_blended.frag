// Copyright 2025, Tim Lehmann for whynotmake.it
//
// Color matte pass for blended liquid glass shapes.

#version 460 core
precision highp float;

#include <flutter/runtime_effect.glsl>
#include "sdf.glsl"

layout(location = 0) uniform vec2 uSize;
layout(location = 1) uniform float uBlend;
layout(location = 2) uniform float uNumShapes;
layout(location = 3) uniform float uShapeData[MAX_SHAPES * 10];

layout(location = 0) out vec4 fragColor;

float getPackedShapeSDF(int index, vec2 p) {
    int baseIndex = index * 10;
    float type = uShapeData[baseIndex];
    vec2 center = vec2(uShapeData[baseIndex + 1], uShapeData[baseIndex + 2]);
    vec2 size = vec2(uShapeData[baseIndex + 3], uShapeData[baseIndex + 4]);
    float cornerRadius = uShapeData[baseIndex + 5];

    return getShapeSDF(type, p, center, size, cornerRadius);
}

vec4 getShapeColor(int index) {
    int baseIndex = index * 10 + 6;
    return vec4(
        uShapeData[baseIndex],
        uShapeData[baseIndex + 1],
        uShapeData[baseIndex + 2],
        uShapeData[baseIndex + 3]
    );
}

float sceneSDFPacked(vec2 p, int numShapes, float blend) {
    if (numShapes == 0) {
        return 1e9;
    }

    float result = getPackedShapeSDF(0, p);

    if (numShapes <= 4) {
        if (numShapes >= 2) {
            result = smoothUnion(result, getPackedShapeSDF(1, p), blend);
        }
        if (numShapes >= 3) {
            result = smoothUnion(result, getPackedShapeSDF(2, p), blend);
        }
        if (numShapes >= 4) {
            result = smoothUnion(result, getPackedShapeSDF(3, p), blend);
        }
    } else {
        for (int i = 1; i < MAX_SHAPES; i++) {
            if (i >= numShapes) {
                break;
            }
            result = smoothUnion(result, getPackedShapeSDF(i, p), blend);
        }
    }

    return result;
}

void accumulateShapeColor(int index, vec2 p, inout vec4 colorSum, inout float weightSum) {
    float sd = getPackedShapeSDF(index, p);
    float blendRadius = max(uBlend, 2.0);
    float weight = 1.0 - smoothstep(-2.0, blendRadius, sd);

    if (weight <= 0.0) {
        return;
    }

    colorSum += getShapeColor(index) * weight;
    weightSum += weight;
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    int numShapes = int(uNumShapes);

    if (numShapes == 0) {
        fragColor = vec4(0.0);
        return;
    }

    float sd = sceneSDFPacked(fragCoord, numShapes, uBlend);
    float foregroundAlpha = sdfAntiAliasAlpha(sd);
    if (foregroundAlpha < 0.01) {
        fragColor = vec4(0.0);
        return;
    }

    vec4 colorSum = vec4(0.0);
    float weightSum = 0.0;

    accumulateShapeColor(0, fragCoord, colorSum, weightSum);
    if (numShapes >= 2) {
        accumulateShapeColor(1, fragCoord, colorSum, weightSum);
    }
    if (numShapes >= 3) {
        accumulateShapeColor(2, fragCoord, colorSum, weightSum);
    }
    if (numShapes >= 4) {
        accumulateShapeColor(3, fragCoord, colorSum, weightSum);
    }
    for (int i = 4; i < MAX_SHAPES; i++) {
        if (i >= numShapes) {
            break;
        }
        accumulateShapeColor(i, fragCoord, colorSum, weightSum);
    }

    if (weightSum <= 0.0) {
        fragColor = vec4(0.0);
        return;
    }

    vec4 color = colorSum / weightSum;
    float alpha = color.a * foregroundAlpha;
    fragColor = vec4(color.rgb * alpha, alpha);
}
