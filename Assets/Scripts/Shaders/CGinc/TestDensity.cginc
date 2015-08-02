sampler3D _PerlinNoise;

float density(float4 pos_ws)
{
    float density = -pos_ws.y;
    density += tex3Dlod(_PerlinNoise, float4(pos_ws.xyz * 4.03f, 0)).x * 0.25f;
    density += tex3Dlod(_PerlinNoise, float4(pos_ws.xyz * 1.96f, 0)).x * 0.50f;
    density += tex3Dlod(_PerlinNoise, float4(pos_ws.xyz * 1.01f, 0)).x * 1.00f;
    return density;
}