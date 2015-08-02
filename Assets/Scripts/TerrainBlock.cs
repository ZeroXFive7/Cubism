using UnityEngine;
using System.Collections;

[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]
public class TerrainBlock : MonoBehaviour
{
    private MeshFilter meshFilter = null;
    private MeshRenderer meshRenderer = null;

    void Start()
    {
        meshFilter = GetComponent<MeshFilter>();
        meshRenderer = GetComponent<MeshRenderer>();

        CPUTerrainMeshGenerator meshGenerator = GetComponent<CPUTerrainMeshGenerator>();
        if (meshGenerator != null)
        {
            meshFilter.sharedMesh = meshGenerator.VoxelBlockMesh;
            meshRenderer.material = meshGenerator.Material;
        }
        else
        {
            meshFilter.sharedMesh = MarchingCubesManager.Instance.VoxelBlockPointMesh;
        }
    }
}
