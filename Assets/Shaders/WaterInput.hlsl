#ifndef WATER_INPUT_INCLUDE
#define WATER_INPUT_INCULDE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D(_PlanarReflectionTexture);
SAMPLER(sampler_ScreenTextures_linear_clamp);

TEXTURE2D(_CameraOpaqueTexture);
SAMPLER(sampler_CameraOpaqueTexture_linear_clamp);

TEXTURE2D(_SurfaceMap);
SAMPLER(sampler_SurfaceMap);

TEXTURE2D(_WaterFXMap);
SAMPLER(sampler_WaterFXMap_linear_clamp);

TEXTURE2D(_ScatteringRamp);
SAMPLER(sampler_ScatteringRamp);

TEXTURE2D(_FoamMap);
SAMPLER(sampler_FoamMap);


CBUFFER_START(UnityPerMaterial)
// depth
float _DeepShrink;
float _DeepCurve;
float _Absorption;

// surface
float _BumpScale;
float _SurfaceTilling;
half4 _BaseColor; // ("BaseColor", Color) = (1,1,1,1)
half4 _DeepColor; //("DeepColor", Color) = (1,1,1,1)

// wave
float4 _DetailWaveSpeed;

// reflection
float _FrenelPower;
float _FrenelOffset;

// refraction
float _DistortionIntensity;

// ligting
float _SpecularIntensity;
float _SHIntensity;
float _SSSIntensity;
float _Scattering;
float _SpecularRangeScale; //("SpecularRangeScale", float) = 1
float _SpecularRangePower; //("SpecularRangePower", float) = 1
float _Smoothness;

// foam
float _FoamDepth;
float _FoamGradient;
float _FoamOffset; //("Foam Offset", Range(0, 10)) = 0
float _FoamFeather; //("Foam Featuer", Range(0, 10)) = 0

CBUFFER_END


#endif
