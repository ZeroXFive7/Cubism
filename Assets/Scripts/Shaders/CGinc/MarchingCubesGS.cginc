StructuredBuffer<int> _MarchingCubesCaseLookup;
StructuredBuffer<int> _MarchingCubesEdgeMasks;
StructuredBuffer<float4> _MarchingCubesCornerOffsets;
StructuredBuffer<int> _MarchingCubesEdgesToVerts;

struct v2g
{
    float4 pos : POSITION;
};

struct g2f
{
    float4 pos : POSITION;
};

v2g MarchingCubes_vert(float4 vertex : POSITION)
{
    v2g o;
    o.pos = vertex;
    return o;
}

float edgeInterpolate(float density0, float density1)
{
    float result = 0.0f;
    if (abs(density0) < 0.00001f)
    {
        result = 0.0f;
    }
    else if (abs(density1) < 0.00001f)
    {
        result = 1.0f;
    }
    else if (abs(density1 - density0) < 0.00001f)
    {
        result = 0.0f;
    }
    else
    {
        result = (-density0) / (density1 - density0);
    }
    return result;
}

[maxvertexcount(15)]
void MarchingCubes_geom(point v2g p[1], inout TriangleStream<g2f> triStream)
{
    float corner_density[8];
    float4 corner_pos_ws[8];
    uint case_key = 0;

    // Expand ws point in to 8 ws cube corners.
    // Lookup density value based on ws corner positions
    for (int corner = 0; corner < 8; ++corner)
    {
        corner_pos_ws[corner] = mul(_Object2World, (p[0].pos + _MarchingCubesCornerOffsets[corner]));
        corner_density[corner] = density(corner_pos_ws[corner]);
        case_key |= ((int)(corner_density[corner] < 0) << corner);
    }

    int edge_mask = _MarchingCubesEdgeMasks[case_key];

    // Entirely inside or entirely outside isosurface.  Early out.
    if (edge_mask == 0)
    {
        return;
    }

    // Build vertices for each edge that intersects isosurface.
    float4 edge_vertices[12];
    for (int edge = 0; edge < 12; ++edge)
    {
        if ((edge_mask & (1 << edge)) != 0)
        {
            int corner_index0 = _MarchingCubesEdgesToVerts[edge * 2];
            int corner_index1 = _MarchingCubesEdgesToVerts[edge * 2 + 1];
            float t = edgeInterpolate(corner_density[corner_index0], corner_density[corner_index1]);
            edge_vertices[edge] = mul(UNITY_MATRIX_VP, lerp(corner_pos_ws[corner_index0], corner_pos_ws[corner_index1], t));
        }
    }

    // Case table is 256 rows of 16 edge values.
    int case_index_start = case_key * 16;
    for (int i = 0; i < 16; i += 3)
    {
        if (_MarchingCubesCaseLookup[case_index_start + i] < 0)
        {
            break;
        }

        g2f v;
        int index = _MarchingCubesCaseLookup[case_index_start + i];
        v.pos = edge_vertices[index];
        triStream.Append(v);

        index = _MarchingCubesCaseLookup[case_index_start + i + 1];
        v.pos = edge_vertices[index];
        triStream.Append(v);

        index = _MarchingCubesCaseLookup[case_index_start + i + 2];
        v.pos = edge_vertices[index];
        triStream.Append(v);

        triStream.RestartStrip();
    }
}