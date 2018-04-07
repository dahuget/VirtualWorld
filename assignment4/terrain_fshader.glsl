R"(
#version 330 core
uniform sampler2D noiseTex;

uniform sampler2D grass;
uniform sampler2D rock;
uniform sampler2D sand;
uniform sampler2D snow;
uniform sampler2D water;

// The camera position
uniform vec3 viewPos;

in vec2 uv;
// Fragment position in world space coordinates
in vec3 fragPos;

out vec4 color;

vec3 phong (vec4 color, vec3 lightDir, vec3 N){
    /* --- Basic 3.1.1 --- */
    /// TODO: Calculate ambient, diffuse, and specular lighting
    /// HINT: max(,) dot(,) reflect(,) normalize()
    // Phong Shader implementation from https://www.opengl.org/sdk/docs/tutorials/ClockworkCoders/lighting.php
    vec3 ambient = vec3(0.1, 0.1, 0.1);
    //vec3 diffuse = vec3(0.8, 0.8, 0.8);
    vec3 diffuse = max(-dot(N,lightDir), 0.0)*color.rgb;
    // we have light direction, so set up eye and half vectors
    vec3 E = normalize(-fragPos);
    vec3 H = normalize(lightDir + E);
    vec3 reflectDir = normalize(-reflect(lightDir, N));
    float shininess = 5.0;
    vec3 specular = pow(max(dot(reflectDir, E), 0.0), 0.3*shininess)*color.rgb;
    //vec3 specular = c*spec;
    return vec3(ambient + diffuse + specular);
}

void main() {

    // Directional light source
    vec3 lightDir = normalize(vec3(1,1,1));

    // Texture size in pixels
    ivec2 size = textureSize(noiseTex, 0);

    /* --- Basic 3.1.1 --- */
    /// TODO: Calculate surface normal N
    // normal at the point will be cross product of two tangent vectors normalized
    /// HINT: Use textureOffset(,,) to read height at uv + pixelwise offset
    /// HINT: Account for texture x,y dimensions in world space coordinates (default f_width=f_height=5)
    // A = vec3(uv.x + .0/width, uv.y, texture offset function(noiseTex, center point uv, ivec2(1,0)))
    vec3 A = vec3( uv.x + 1.0/size.x, uv.y, textureOffset(noiseTex, uv, ivec2(1,0)) );
    vec3 B = vec3( uv.x - 1.0/size.x, uv.y, textureOffset(noiseTex, uv, ivec2(-1,0)) );
    vec3 C = vec3( uv.x, uv.y + 1.0/size.y, textureOffset(noiseTex, uv, ivec2(0,1)) );
    vec3 D = vec3( uv.x, uv.y - 1.0/size.y, textureOffset(noiseTex, uv, ivec2(0,-1)) );
    vec3 N = normalize( cross(normalize(A-B), normalize(C-D)) );

    /* --- Basic 3.1.2 --- */
    /// TODO: Texture according to height and slope
    /// HINT: Read noiseTex for height at uv
    // Sample height from texture and normalize to [0,1]]
    // output color = color of the texture at the specified UV
    vec3 c = vec3((texture(noiseTex, uv).z + 1.0f)/2.0f);

    // "Slope" is the absolute value of the dot product of the normal and "up" vector
    // aka the angle between the normal and a vertical line
    //  the z coordinate is the cosine, so you need to take the arccos of z acos(z)
    float angle = (dot(N, vec3(0,0,1)));

    // check height, below zero is water
    if(fragPos.z <= 0.0f) {
        color = texture(water, uv).rgba;
        c = phong(color, lightDir, N);
        color = vec4(c,1);
    } // high altitude is snow
    else if(fragPos.z >0.5f){
        color = texture(snow, uv).rgba;
        c = phong(color, lightDir, N);
        color = vec4(c,1);
    } // steep slope is rock
    else {
        if(angle > 0.5f){
            color = texture(rock, uv).rgba;
            c = phong(color, lightDir, N);
            color = vec4(c,1);
        } else{
            color = texture(grass, uv).rgba;
            c = phong(color, lightDir, N);
            color = vec4(c,1);
        }
    }

}
)"
