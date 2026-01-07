// GPU-accelerated particle shader with texture-based data
// Place in: shaders/particles.frag

#version 460 core
#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 uSize;        // Screen size
uniform float uTime;       // Animation time
uniform float uCount;      // Particle count
uniform sampler2D uParticleData; // Particle data texture

out vec4 fragColor;

// Smooth distance function for glow
float smoothGlow(float dist, float radius, float intensity) {
    float normalized = dist / radius;
    return intensity * exp(-normalized * normalized * 3.0);
}

// Read particle data from texture
// Row 0: x, y, radius, phase
// Row 1: r, g, b, alpha
void getParticle(int index, out vec2 pos, out float radius, out float phase, out vec4 color) {
    float u = (float(index) + 0.5) / 64.0; // Max 64 particles
    
    vec4 data0 = texture(uParticleData, vec2(u, 0.25));
    vec4 data1 = texture(uParticleData, vec2(u, 0.75));
    
    pos = data0.xy;
    radius = data0.z;
    phase = data0.w;
    color = data1;
}

// Neon glow with multiple rings
vec4 particleGlow(vec2 pos, vec2 center, float radius, vec4 color, float phase) {
    float dist = distance(pos, center);
    
    // Pulsing effect
    float pulse = 0.85 + 0.15 * sin(phase);
    float effectiveRadius = radius * pulse;
    
    if (dist > effectiveRadius * 5.0) return vec4(0.0);
    
    vec4 result = vec4(0.0);
    
    // Multiple glow layers (GPU does this efficiently)
    result += color * smoothGlow(dist, effectiveRadius * 4.5, 0.15);
    result += color * smoothGlow(dist, effectiveRadius * 3.0, 0.25);
    result += color * smoothGlow(dist, effectiveRadius * 2.0, 0.4);
    
    // Inner bright core
    if (dist < effectiveRadius * 1.5) {
        float coreFactor = 1.0 - (dist / (effectiveRadius * 1.5));
        vec4 coreColor = mix(color, vec4(1.0), 0.4);
        result += coreColor * coreFactor * 0.8;
    }
    
    // Bright center highlight
    if (dist < effectiveRadius * 0.5) {
        result += vec4(1.0) * (1.0 - dist / (effectiveRadius * 0.5)) * 0.4;
    }
    
    return result;
}

// Connection line glow
vec4 connectionGlow(vec2 pos, vec2 p1, vec2 p2, vec4 color) {
    vec2 pa = pos - p1;
    vec2 ba = p2 - p1;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    float dist = length(pa - ba * h);
    
    if (dist > 20.0) return vec4(0.0);
    
    float intensity = (1.0 - dist / 20.0);
    intensity = intensity * intensity;
    
    float flow = sin(uTime * 2.0 + h * 6.28) * 0.3 + 0.7;
    
    return color * intensity * 0.3 * flow;
}

void main() {
    vec2 pos = FlutterFragCoord().xy;
    vec4 color = vec4(0.0);
    
    int count = int(uCount);
    int maxParticles = min(count, 50);
    
    // Arrays to store particle data
    vec2 positions[50];
    float radii[50];
    float phases[50];
    vec4 colors[50];
    
    // Read all particles
    for (int i = 0; i < maxParticles; i++) {
        getParticle(i, positions[i], radii[i], phases[i], colors[i]);
    }
    
    // Draw connections first
    for (int i = 0; i < maxParticles; i++) {
        for (int j = i + 1; j < maxParticles; j++) {
            float dist = distance(positions[i], positions[j]);
            if (dist < 150.0) {
                color += connectionGlow(pos, positions[i], positions[j], colors[i]);
            }
        }
    }
    
    // Draw particles
    for (int i = 0; i < maxParticles; i++) {
        color += particleGlow(pos, positions[i], radii[i], colors[i], phases[i]);
    }
    
    // Tone mapping for HDR-like glow
    color.rgb = color.rgb / (1.0 + color.rgb);
    
    // Subtle vignette
    vec2 uv = pos / uSize;
    float vignette = 1.0 - 0.3 * length(uv - 0.5);
    color.rgb *= vignette;
    
    fragColor = vec4(color.rgb, 1.0);
}