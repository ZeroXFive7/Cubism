StructuredBuffer<int> _MarchingCubesCaseLookup;
StructuredBuffer<float4> _MarchingCubesCornerOffsets;
StructuredBuffer<int> _MarchingCubesEdgesToVerts;

struct v2g
{
    float4 pos : POSITION;
};

struct g2f
{
    float4 pos : POSITION;
    float4 color : TEXCOORD0;
};

v2g MarchingCubes_vert(float4 vertex : POSITION)
{
    v2g o;
    o.pos = vertex;
    return o;
}

[maxvertexcount(15)]
void MarchingCubes_geom(point v2g p[1], inout TriangleStream<g2f> triStream)
{
    // Expand ws point in to 8 ws cube corners.
    // Lookup density value based on ws corner positions
    float corner_density[8];
    float4 corner_pos_ws[8];
    uint caseKey = 0;

    int i;
    for (i = 0; i < 8; ++i)
    {
        corner_pos_ws[i] = mul(_Object2World, (p[0].pos + _MarchingCubesCornerOffsets[i]));
        corner_density[i] = density(corner_pos_ws[i]);
        caseKey |= ((int)(corner_density[i] < 0) << i);
    }

    // Case table is 256 rows of 16 edge values.
    int caseIndexStart = caseKey * 16;
    int3 faceEdgeIndices;

    g2f v;
    v.color = float4(0, 1, 0, 1);

    for (i = 0; i < 16; i +=3)
    {
        faceEdgeIndices.x = _MarchingCubesCaseLookup[caseIndexStart + i];
        faceEdgeIndices.y = _MarchingCubesCaseLookup[caseIndexStart + i + 1];
        faceEdgeIndices.z = _MarchingCubesCaseLookup[caseIndexStart + i + 2];

        if (faceEdgeIndices.x < 0)
        {
            break;
        }

        for (int j = 0; j < 3; ++j)
        {
            int vertIndex0 = _MarchingCubesEdgesToVerts[faceEdgeIndices[j]] * 2;
            int vertIndex1 = vertIndex0 + 1;

            float t = abs(corner_density[vertIndex0]) / abs(corner_density[vertIndex1] - corner_density[vertIndex0]);
            v.pos = mul(UNITY_MATRIX_VP, lerp(corner_pos_ws[vertIndex0], corner_pos_ws[vertIndex1], t));
            triStream.Append(v);
        }
    }
}