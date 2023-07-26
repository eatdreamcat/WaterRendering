#ifndef WATER_COMMON_INCLUDED
#define WATER_COMMON_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "WaterInput.hlsl"
#include "WaterLighting.hlsl"



///////////////////////////////////////////////////////////////////////////////
//                  				Structs		                             //
///////////////////////////////////////////////////////////////////////////////
struct Attribute // vertex struct
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
   
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varying // frag struct
{
    // xyz : normal, w: bi-tangent.x
    float4 normalWS                : TEXCOORD0;
    float4 dirToViewWS             : TEXCOORD1;
    float4 positionCS              : TEXCOORD2;
    float4 positionWS              : TEXCOORD3;
    float4 uv                      : TEXCOORD4;  // xy: geometry uv
    half2  fogFactorNoise          : TEXCOORD5;	// x: fogFactor, y: noise
    float4 positionVS              : TEXCOORD6;
    float3 preWaveSP 			   : TEXCOORD7;	// screen position of the verticies before wave distortion
    
    float4 vertexCS     : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

// Simple noise from thebookofshaders.com
// 2D Random
float2 random(float2 st){
    st = float2( dot(st,float2(127.1,311.7)), dot(st,float2(269.5,183.3)) );
    return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
}

// 2D Noise based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (float2 st) {
    float2 i = floor(st);
    float2 f = frac(st);

    float2 u = f*f*(3.0-2.0*f);

    return lerp( lerp( dot( random(i), f),
                     dot( random(i + float2(1.0,0.0) ), f - float2(1.0,0.0) ), u.x),
                lerp( dot( random(i + float2(0.0,1.0) ), f - float2(0.0,1.0) ),
                     dot( random(i + float2(1.0,1.0) ), f - float2(1.0,1.0) ), u.x), u.y);
}


Varying WaveVertexOperations(Varying input)
{
    
    float time = _Time.y;

    input.fogFactorNoise.y = ((noise((input.positionWS.xz * 0.5) + time) + noise((input.positionWS.xz * 1) + time)) * 0.25 - 0.5) + 1;

    half4 screenUV = ComputeScreenPos(input.positionCS);
    screenUV.xyz /= screenUV.w;
    
    // Fog
    input.fogFactorNoise.x = ComputeFogFactor(input.positionCS.z);
    input.preWaveSP = screenUV.xyz; // pre-displaced screenUVs
    
    // Detail UVs
    input.uv.zw = input.positionWS.xz * _SurfaceTilling * 0.1h + time * 0.05h * _DetailWaveSpeed.x * 0.1f + (input.fogFactorNoise.y * 0.1);
    input.uv.xy = input.positionWS.xz * _SurfaceTilling * 0.4h - time.xx * 0.1h * _DetailWaveSpeed.y * 0.1f + (input.fogFactorNoise.y * 0.2);

    
    
    return input;
}


///////////////////////////////////////////////////////////////////////////////
//               	   Vertex and Fragment functions                         //
///////////////////////////////////////////////////////////////////////////////

Varying WaterVert(Attribute input)
{
    Varying output;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    
    output.vertexCS = vertexInput.positionCS;
    output.positionCS = vertexInput.positionCS;
    output.positionWS.xyz = vertexInput.positionWS;
    output.positionVS.xyz = vertexInput.positionVS;

    output.uv.xy = input.texcoord;

    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.normalWS = float4(normalInput.normalWS, normalInput.bitangentWS.x);

    output.dirToViewWS.xyz = GetWorldSpaceViewDir(vertexInput.positionWS);

    
    output = WaveVertexOperations(output);
    
    return output;
}

half2 DistortionUVs(float3 normalWS)
{
    float2 refractedScreenUV = - normalWS.xz * _DistortionIntensity * 0.001f;

    return refractedScreenUV;
}

half3 Scattering(half depth)
{
    half3 absorptionColor = SAMPLE_TEXTURE2D(_ScatteringRamp, sampler_ScatteringRamp, half2(depth + _Scattering * 0.001f, 0.0h)).rgb;
    
    return absorptionColor;
}

half3 Refraction(half2 distortion, half depth)
{
    half3 output = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture_linear_clamp, distortion).rgb;
    output *= saturate(pow(depth + 0.5f, _Absorption * 0.1f));
    return output;
}

float GetRawDepth(float2 uv)
{
    return SampleSceneDepth(uv.xy).r;
}


// x: depthMask, y: distance seabed to camera z: distance water plane to camera
float3 WaterDepth(float2 screenUV, float3 dirToViewWS, float3 positionVS)
{
    float rawDepth = GetRawDepth(screenUV);
    
    float sceneDepth = Linear01Depth(rawDepth, _ZBufferParams) / _ZBufferParams.w;
    
    float3 dirToViewWithWaterDepth = abs(sceneDepth + positionVS.z) * dirToViewWS;
    
    // world vertical water thickness
    float thicknessInVertical = max(0, abs(dot(dirToViewWithWaterDepth, half3(0, 1, 0))));
    
    half shrinkThickness = thicknessInVertical / max(abs(_DeepShrink), 1);

    half curvedThickness = exp2(-abs(_DeepCurve) * shrinkThickness);

    return half3(curvedThickness, sceneDepth, positionVS.z);
    
}

float4 WaterFrag(Varying input) : SV_Target
{
    half3 finalColor = 0;

    // water FX
    half4 waterFX = SAMPLE_TEXTURE2D(_WaterFXMap, sampler_ScreenTextures_linear_clamp, input.preWaveSP.xy);
    
    // Calculate Screen UV
    float4 screenPOS = ComputeScreenPos(input.positionCS);
    float2 screenUV = screenPOS.xy / input.positionCS.w;
   
    // normalize input
    input.dirToViewWS.xyz = SafeNormalize(input.dirToViewWS.xyz);

    // Detail waves
    half2 detailBump1 = SAMPLE_TEXTURE2D(_SurfaceMap, sampler_SurfaceMap, input.uv.zw).xy;
    half2 detailBump2 = SAMPLE_TEXTURE2D(_SurfaceMap, sampler_SurfaceMap, input.uv.xy).xy;
    half2 detailBump = (detailBump1 + detailBump2 * 0.5) * 2 - 1;

    half3 originNormalWS = SafeNormalize(input.normalWS);

    // Frenel
    half fresnelTerm = CalculateFresnelTerm(originNormalWS, input.dirToViewWS.xyz);
    
    input.normalWS.xyz += half3(detailBump.x, 0, detailBump.y) * _BumpScale;
    input.normalWS.xyz += half3(1 - waterFX.y * _DetailWaveSpeed.z, 0.5h, 1 - waterFX.z * _DetailWaveSpeed.w) - 0.5;
    input.normalWS.xyz = SafeNormalize(input.normalWS.xyz);

    
    // distance from seabed to camera
    float rawDepthDistortion = GetRawDepth( screenUV.xy + DistortionUVs(input.normalWS));
    float sceneDepth = Linear01Depth(rawDepthDistortion, _ZBufferParams) / _ZBufferParams.w;
    
    if (sceneDepth > abs(input.positionVS.z))
    {
        screenUV.xy = screenUV.xy + DistortionUVs(input.normalWS);
        #ifdef _SHOW_REFRACTION_MASK
        return half4(1 ,1, 1, 1.0);
        #endif
    }

    #ifdef _SHOW_REFRACTION_MASK
    return half4(0 ,0, 0, 1.0);
    #endif
    
    // Depth
    float3 depth = WaterDepth(screenUV, input.dirToViewWS.xyz, input.positionVS.xyz);

    #ifdef _SHOW_DEPTH
    return half4(depth.xxx, 1.0);
    #endif

    
    #ifdef _SHOW_NORMAL
    return half4(input.normalWS.xyz, 1.0);
    #endif

    #ifdef _SHOW_SCREEN_UV
    return half4(screenUV, 0, 1.0);
    #endif

   

    #ifdef _SHOW_FRENEL
    return half4(fresnelTerm.xxx, 1.0);
    #endif
    
    // Reflections
    half3 reflection = SampleReflections(input.normalWS, input.dirToViewWS.xyz, screenUV.xy, 0.0) * fresnelTerm;
    
    #ifdef _SHOW_REFLECTION
    return half4(reflection, 1.0);
    #endif
    
    // Refraction
    half3 refraction = Refraction(screenUV.xy, depth.x);
    #ifdef _SHOW_REFRACTION
    return half4(half3(0, 0.3, 0.4) * 0.25 + refraction.rgb * 0.75, 1.0);
    #endif

    
    half3 waterColor = lerp(_BaseColor.rgb, _DeepColor.rgb, saturate(1 - depth.x));

    #ifdef _SHOW_WATER_COLOR
    return half4(waterColor.rgb, 1.0);
    #endif

    // Lighting
    Light mainLight = GetMainLight(TransformWorldToShadowCoord(input.positionWS));
    half3 GI = SampleSH(input.normalWS) * _SHIntensity;
    #ifdef _SHOW_SH
    return half4(GI, 1.0);
    #endif
    
    // Foam
    half3 foamMap = SAMPLE_TEXTURE2D(_FoamMap, sampler_FoamMap,  input.uv.zw).rgb; //r=thick, g=medium, b=light
    half foamMask = pow(depth, _FoamDepth) * length(foamMap);
    half3 foam = foamMask.xxx * (mainLight.shadowAttenuation * mainLight.color + GI);
   
    
    // specular
    BRDFData brdfData;
    half alpha = 1;
    InitializeBRDFData(half3(0, 0, 0), 0, mainLight.color, 0.95 * (1 - foamMask), alpha, brdfData);
    float specularRange = saturate(pow((1.0 - abs(screenUV.x - 0.5)) * _SpecularRangeScale, _SpecularRangePower));
    half3 spec = DirectBDRF(brdfData, input.normalWS, mainLight.direction, input.dirToViewWS) * mainLight.shadowAttenuation * mainLight.color * specularRange * _SpecularIntensity;

    
    #ifdef _SHOW_SPECULAR
    return half4(spec, 1.0);
    #endif
    
    // SSS
    half3 scattering = Scattering(depth);
    #ifdef _SHOW_SCATTERING
    return half4(scattering.rgb, 1.0);
    #endif
    
    half3 directLighting = saturate(dot(SafeNormalize(-mainLight.direction), input.normalWS)) * mainLight.color;
    half3 sss = directLighting * mainLight.color * scattering + GI;
    sss *= _SSSIntensity;
    #ifdef _SHOW_SSS
    return half4(sss, 1.0);
    #endif

    waterColor += sss;

    alpha = alpha * max(1 - depth, fresnelTerm);
    
    finalColor.rgb = reflection // reflection
        + (1 - fresnelTerm) * (refraction * (1 - alpha) + alpha * waterColor)
        + spec;

    float foamWeight = foamMask * pow(smoothstep(alpha - _FoamOffset * 0.1, alpha + _FoamOffset * 0.1, _FoamFeather), _FoamGradient);
    finalColor.rgb = finalColor.rgb + foam * foamWeight;
    
    #ifdef _SHOW_FOAM
    return half4(foamWeight.xxx, 1.0);
    #endif
    return half4(finalColor.rgb, 1.0);
}


#endif