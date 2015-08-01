using UnityEngine;
using System.Collections;

[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]
public class TerrainBlock : MonoBehaviour
{
    private MeshFilter meshFilter = null;

    void Start()
    {
        meshFilter = GetComponent<MeshFilter>();
        meshFilter.sharedMesh = MarchingCubesManager.Instance.VoxelBlockMesh;
    }
}
