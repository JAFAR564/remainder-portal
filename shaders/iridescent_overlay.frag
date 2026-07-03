#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 uResolution;
uniform float uTime;
uniform vec2 uOffset;

out vec4 fragColor;

// --- Portal palette (light ethereal aristocratic) ---
// Iridescent (#9BB5CE) drives the primary transition — a subtle blue-silver sheen
// Gold (#D4A857) and warm ivory (#FAF8F4) frame the shoulders of each wave
const vec3 IRIDESCENT = vec3(0.608, 0.710, 0.808); // #9BB5CE
const vec3 GOLD       = vec3(0.831, 0.659, 0.341); // #D4A857
const vec3 IVORY      = vec3(0.980, 0.973, 0.957); // #FAF8F4

void main() {
    vec2 uv = FlutterFragCoord() / uResolution;
    vec2 p = uv + uOffset;

    // --- Three-wave interference field ---
    // Frequencies are coprime ratios to avoid tiling artifacts
    // Phase offsets staggered to keep movement organic
    float waveA = sin(p.x * 3.2 + p.y * 2.1 + uTime * 0.250) * 0.5 + 0.5;
    float waveB = cos(p.x * 2.4 - p.y * 3.6 + uTime * 0.180 + 1.70) * 0.5 + 0.5;
    float waveC = sin(p.x * 5.0 - p.y * 4.0 + uTime * 0.150 + 0.93) * 0.5 + 0.5;

    float field = waveA * 0.50 + waveB * 0.30 + waveC * 0.20;

    // --- Slow horizontal drift (completes one cycle ~50 s) ---
    float t = fract(field + uTime * 0.020);

    // --- Soft ribbon with gaussian-like falloff ---
    float ribbon = 1.0 - abs(t - 0.5) * 2.0;
    ribbon = smoothstep(0.0, 0.45, ribbon);
    ribbon *= ribbon;

    // --- Iridescent colour progression ---
    // ribbon centre (t=0.5) → GOLD peak
    // ribbon shoulders (t~0.25/0.75) → IRIDESCENT
    // ribbon edges (t~0.0/1.0) → IVORY
    float edgeDist = abs(t - 0.5) * 2.0;
    float iriWeight = smoothstep(0.0, 0.6, edgeDist);
    float goldWeight = 1.0 - smoothstep(0.0, 0.5, edgeDist);

    vec3 color = mix(IVORY, IRIDESCENT, iriWeight);
    color = mix(color, GOLD, goldWeight);

    // --- Secondary micro-shimmer (high-frequency, low amplitude) ---
    float shimmer = sin(p.x * 8.0 + p.y * 6.0 + uTime * 0.400) * 0.5 + 0.5;
    vec3 shimmerColor = mix(IRIDESCENT, vec3(1.0), shimmer);
    color = mix(color, shimmerColor, shimmer * 0.12 * ribbon);

    // --- Alpha: whisper-thin so every layer beneath remains legible ---
    float alpha = ribbon * 0.08;

    fragColor = vec4(color, alpha);
}
