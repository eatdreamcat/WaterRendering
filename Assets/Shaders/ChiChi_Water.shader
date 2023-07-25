Shader "ChiChi/ChiChi_Water"
{
    Properties {}
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent" "Queue"="Transparent-100" "RenderPipeline" = "UniversalPipeline"
        }
        LOD 100
        ZWrite On
        Pass
        {

            Tags
            {
                "LightMode" = "UniversalForward"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


            struct attribute
            {
                float4 positionOS : POSITION;
            };

            struct varying
            {
                float4 vertexCS : SV_POSITION;
            };

            varying vert(attribute input)
            {
                varying output;
                float3 positionWS = TransformObjectToWorld(input.positionOS);
                output.vertexCS = TransformWorldToHClip(positionWS);
                return output;
            }

            float4 frag(varying input) : SV_Target
            {
                half4 waterColor = half4(0, 0.1, 0.3, 0.7);

                return waterColor;
            }
            ENDHLSL
        }
    }
}