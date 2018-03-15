R"(
#version 330 core
in vec3 vposition;
in vec2 vtexcoord;

uniform mat4 M;
uniform mat4 V;
uniform mat4 P;

out vec2 uv;

void main() {
    uv = vtexcoord;
    // TODO: Calculate vertical displacement h given uv
    // parametric function, use uv coordinates
    float h = 0.1*sin(8*uv.x) + 0.1*cos(8*uv.y);
    // TODO: Apply displacement to vposition
    // some vector with h as the z coordinate
    vec3 temp = vposition + vec3(0,0,h);

    // DO THIS STEP FIRST:
    // TODO: Multiply model, view, and projection matrices in the correct order
    gl_Position = P*V*M*vec4(temp, 1.0);
}
)"
