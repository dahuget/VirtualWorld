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

void main() {

    // Directional light source
    vec3 lightDir = normalize(vec3(1,1,1));

    // Texture size in pixels
    ivec2 size = textureSize(noiseTex, 0);

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

    /// TODO: Texture according to height and slope
    /// HINT: Read noiseTex for height at uv
    // Sample height from texture and normalize to [0,1]
    vec3 c = vec3((texture(noiseTex, uv).r + 1.0f)/2.0f);

    // (Optional): Visualize normals as RGB vector
    //c = (N +vec3(1.0)) / 2.0;

    /// TODO: Calculate ambient, diffuse, and specular lighting
    // diffuse = -dot(normal, lightDir)
    /// HINT: max(,) dot(,) reflect(,) normalize()
    vec3 ambient = vec3(0.2, 0.2, 0.2);
    vec3 diffuse = max(dot(N,lightDir), 0.0);
    // we have light direction, so set up eye and half vectors
    vec3 E = normalize(-fragPos);
    vec3 H = normalize(lightDir + E);
    vec3 reflectDir = reflect(-lightDir, N);
    float shininess = 8.0;
    vec3 specular = pow(max(dot(E, reflectDir), 0.0), shininess);

    vec3 c = ambient + diffuse + specular;

    color = vec4(c,1);
}
)"
