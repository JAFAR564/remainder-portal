#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 uResolution;
uniform float uTime;
uniform vec2 uOffset;

out vec4 fragColor;

// Premium dark basalt/teal accents (matches the mockup style)
const vec3 ACCENT_BLUE = vec3(0.07, 0.15, 0.24); // Deep Navy Glow (#12263F)
const vec3 ACCENT_TEAL = vec3(0.12, 0.22, 0.22); // Deep Teal Glow (#1F3E3E)
const vec3 DARK_VOID   = vec3(0.039, 0.039, 0.047); // Basalt Base (#0A0A0C)

void main() {
    vec2 uv = FlutterFragCoord() / uResolution;
    vec2 p = uv + uOffset;

    // A very slow, soft ambient radial glow centered at the top-right
    vec2 glowCenter = vec2(0.8, 0.2);
    float d = distance(p, glowCenter);
    
    // Smooth transition from glow center to dark background
    float glow = smoothstep(1.5, 0.2, d);
    
    // Gentle slow wave interference just to make the glow feel alive (very low amplitude)
    float wave = sin(p.x * 2.0 + uTime * 0.08) * cos(p.y * 2.0 - uTime * 0.06) * 0.5 + 0.5;
    
    vec3 glowColor = mix(ACCENT_BLUE, ACCENT_TEAL, wave);
    vec3 finalColor = mix(DARK_VOID, glowColor, glow * 0.25);
    
    // Solid background paint (alpha = 1.0)
    fragColor = vec4(finalColor, 1.0);
}
