using UnityEngine;
using System.Collections.Generic;

public class CPUTerrainMeshGenerator : MonoBehaviour
{
    public Material Material = null;

    private Mesh voxelBlockMesh = null;
    public Mesh VoxelBlockMesh
    {
        get
        {
            if (voxelBlockMesh == null)
            {
                voxelBlockMesh = GenerateMesh(MarchingCubesManager.Instance.VoxelBlockPointMesh);
            }
            return voxelBlockMesh;
        }
    }

    private Mesh GenerateMesh(Mesh pointMesh)
    {
        List<Vector3> vertices = new List<Vector3>();
        List<int> indices = new List<int>();

        foreach (var point in pointMesh.vertices)
        {
            AppendCube(point, vertices, indices);
        }

        Mesh mesh = new Mesh();
        mesh.vertices = vertices.ToArray();
        mesh.triangles = indices.ToArray();
        return mesh;
    }

    private void AppendCube(Vector4 point, List<Vector3> vertices, List<int> indices)
    {
        float[] corner_density = new float[8];
        Vector3[] corner_pos_ws = new Vector3[8];
        uint case_key = 0;

        // Expand ws point in to 8 ws cube corners.
        // Lookup density value based on ws corner positions
        for (int corner = 0; corner < 8; ++corner)
        {
            corner_pos_ws[corner] = transform.TransformPoint((point + MarchingCubesManager.Instance.scaledCornerOffsets[corner]));
            corner_density[corner] = Density(corner_pos_ws[corner]);
            if (corner_density[corner] < 0)
            {
                case_key |= ((uint)1 << corner);
            }
        }

        int corner_mask = MarchingCubesManager.Instance.cornerMasks[case_key];

        // Entirely inside or entirely outside isosurface.  Early out.
        if (corner_mask == 0)
        {
            return;
        }

        // Build vertices for each edge that intersects isosurface.
        Vector3[] edge_vertices = new Vector3[12];
        for (int edge = 0; edge < 12; ++edge)
        {
            if ((corner_mask & (1 << edge)) != 0)
            {
                int corner_index0 = MarchingCubesManager.Instance.edgesToVerts[edge,0];
                int corner_index1 = MarchingCubesManager.Instance.edgesToVerts[edge,1];
                float t = edgeInterpolate(corner_density[corner_index0], corner_density[corner_index1]);

                edge_vertices[edge] = Vector3.Lerp(corner_pos_ws[corner_index0], corner_pos_ws[corner_index1], t);
            }
        }

        // Case table is 256 rows of 16 edge values.
        uint case_index_start = case_key * 16;
        for (int i = 0; i < 16; i += 3)
        {
            if (MarchingCubesManager.Instance.cubeCases[case_key,0] < 0)
            {
                break;
            }

            indices.Add(vertices.Count);
            vertices.Add(edge_vertices[MarchingCubesManager.Instance.cubeCases[case_key, 0]]);

            indices.Add(vertices.Count);
            vertices.Add(edge_vertices[MarchingCubesManager.Instance.cubeCases[case_key, 1]]);

            indices.Add(vertices.Count);
            vertices.Add(edge_vertices[MarchingCubesManager.Instance.cubeCases[case_key, 2]]);
        }
    }

    private float edgeInterpolate(float density0, float density1)
    {
        if (Mathf.Abs(density0) < 0.00001f)
        {
            return density0;
        }
        if (Mathf.Abs(density1) < 0.00001f)
        {
            return density1;
        }
        if (Mathf.Abs(density1 - density0) < 0.00001f)
        {
            return density0;
        }
        return (-density0) / (density1 - density0);
    }

    private float Density(Vector3 pos_ws)
    {
        return -pos_ws.y;
    }
}
