Shader "Custom/TestUnlit"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200
        Cull Off

        Pass
        {
            CGPROGRAM

            #include "UnityCG.cginc"
            #include "CGinc/TestDensity.cginc"
            #include "CGinc/MarchingCubesGS.cginc"

            #pragma vertex MarchingCubes_vert
            #pragma geometry MarchingCubes_geom
            #pragma fragment frag
            #pragma target 5.0

            float4 _Color;

            float4 frag(g2f i) : COLOR
            {
                return _Color;
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}