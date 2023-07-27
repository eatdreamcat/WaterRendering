#ifndef WATER_LIGHTING_INCLUDE
#define WATER_LIGHTING_INCULDE


half CalculateFresnelTerm(half3 normalWS, half3 viewDirectionWS)
{
    return saturate(pow(1.0 - dot(normalWS, viewDirectionWS) + _FrenelOffset * 0.001f, _FrenelPower));
}

///////////////////////////////////////////////////////////////////////////////
//                           Reflection                                 //
///////////////////////////////////////////////////////////////////////////////
half3 SampleReflections(half2 screenUV, half roughness)
{
    half3 reflection = 0;

    #if _REFLECTION_PLANARREFLECTION
    reflection += SAMPLE_TEXTURE2D_LOD(_PlanarReflectionTexture, sampler_ScreenTextures_linear_clamp, screenUV, 6 * roughness).rgb;//planar reflection
    #endif
    
    return reflection;
}

#endif