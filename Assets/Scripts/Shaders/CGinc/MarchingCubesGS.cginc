StructuredBuffer<int> _MarchingCubesCaseLookup;
StructuredBuffer<float4> _MarchingCubesCornerOffsets;

float _MarchingCubesCubeSize;

struct v2g
{
    float4 pos_ws : POSITION;
};

struct g2f
{
    float4 pos : POSITION;
};

v2g MarchingCubes_vert(float4 vertex : POSITION)
{
    v2g o;
    o.pos_ws = mul(_Object2World, vertex);
    return o;
}

[maxvertexcount(3)]
void MarchingCubes_geom(point v2g p[1], inout TriangleStream<g2f> triStream)
{
    // Expand ws point in to 8 ws cube corners.
    float4 corner_pos_ws[8];
    int i;
    for (i = 0; i < 8; ++i)
    {
        corner_pos_ws[i] = p[0].pos_ws + _MarchingCubesCornerOffsets[i] * _MarchingCubesCubeSize;
    }

    // Lookup density value based on ws corner positions
    float corner_density[8];
    for (i = 0; i < 8; ++i)
    {
        corner_density[i] = density(corner_pos_ws[i]);
    }

    // Build case lookup key based on corner density values

    //g2f v0;
    //v0.pos = mul(UNITY_MATRIX_VP, p[0].pos_ws);

    //g2f v1;
    //v1.pos = mul(UNITY_MATRIX_VP, p[0].pos_ws + float4(0.1, 0.0f, 0.0f));

    //g2f v2;
    //v2.pos = mul(UNITY_MATRIX_VP, p[0].pos_ws + +float4(0.1, 0.1f, 0.0f)[2]);

    //// Generate triangles based on Marching Cubes lookup table
    //triStream.Append(v0);
    //triStream.Append(v1);
    //triStream.Append(v2);

    //triStream.RestartStrip();

    float3 up = float3(0, 1, 0);
    float3 look = _WorldSpaceCameraPos - p[0].pos_ws;
    look.y = 0;
    look = normalize(look);
    float3 right = cross(up, look);

    float halfS = 0.5f * _MarchingCubesCubeSize;

    float4 v[4];
    v[0] = float4(p[0].pos_ws + halfS * right - halfS * up, 1.0f);
    v[1] = float4(p[0].pos_ws + halfS * right + halfS * up, 1.0f);
    v[2] = float4(p[0].pos_ws - halfS * right - halfS * up, 1.0f);
    v[3] = float4(p[0].pos_ws - halfS * right + halfS * up, 1.0f);

    float4x4 vp = mul(UNITY_MATRIX_MVP, _World2Object);
    g2f pIn;
    pIn.pos = mul(UNITY_MATRIX_VP, v[0]);
    triStream.Append(pIn);

    pIn.pos = mul(UNITY_MATRIX_VP, v[1]);
    triStream.Append(pIn);

    pIn.pos = mul(UNITY_MATRIX_VP, v[2]);
    triStream.Append(pIn);

    pIn.pos = mul(UNITY_MATRIX_VP, v[3]);
    triStream.Append(pIn);
}