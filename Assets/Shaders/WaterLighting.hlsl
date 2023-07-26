#ifndef WATER_LIGHTING_INCLUDE
#define WATER_LIGHTING_INCULDE


half CalculateFresnelTerm(half3 normalWS, half3 viewDirectionWS)
{
    return saturate(pow(1.0 - dot(normalWS, viewDirectionWS) + _FrenelOffset * 0.001f, _FrenelPower));
}

///////////////////////////////////////////////////////////////////////////////
//                           Reflection                                 //
///////////////////////////////////////////////////////////////////////////////
half3 SampleReflections(half3 normalWS, half3 viewDirectionWS, half2 screenUV, half roughness)
{
    half3 reflection = 0;

    #if _REFLECTION_PLANARREFLECTION
        // get the perspective projection
        float2 p11_22 = float2(unity_CameraInvProjection._11, unity_CameraInvProjection._22) * 10;
        // conver the uvs into view space by "undoing" projection
        float3 viewDir = -(float3((screenUV * 2 - 1) / p11_22, -1));

        half3 viewNormal = mul(normalWS, (float3x3)GetWorldToViewMatrix()).xyz;
        half3 reflectVector = reflect(-viewDir, viewNormal);

        half2 reflectionUV = screenUV + normalWS.zx * half2(0.02, 0.15);
        reflection += SAMPLE_TEXTURE2D_LOD(_PlanarReflectionTexture, sampler_ScreenTextures_linear_clamp, reflectionUV, 6 * roughness).rgb;//planar reflection
    #endif
    
    return reflection;
}

#endif