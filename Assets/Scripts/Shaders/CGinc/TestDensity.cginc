sampler3D _PerlinNoise;

float density(float4 pos_ws)
{
    float density = -pos_ws.y;
    density += tex3Dlod(_PerlinNoise, float4(pos_ws.xyz * 4.03, 0)).x*0.25;
    density += tex3Dlod(_PerlinNoise, float4(pos_ws.xyz * 1.96, 0)).x*0.50;
    density += tex3Dlod(_PerlinNoise, float4(pos_ws.xyz * 1.01, 0)).x*1.00;
    return density;
}