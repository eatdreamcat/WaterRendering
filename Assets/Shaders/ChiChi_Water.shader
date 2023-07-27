Shader "ChiChi/ChiChi_Water"
{
    Properties 
    {
        [Header(Surface)]
        _BaseColor("BaseColor", Color) = (1,1,1,1)
        _DeepColor("DeepColor", Color) = (1,1,1,1)
        _SurfaceMap("Surface", 2D) = "white" {}
        _SurfaceTilling("Surface Tilling", float) = 1
        _WaterFXMap("Water FX", 2D) = "white" {}
        _ScatteringRamp("ScatteringRamp", 2D) = "white" {}
        _BumpScale("BumpScale", float) = 1
        
        
        [Header(Wave)]
        _DetailWaveSpeed("Detail Wave Speed(xy) Intensity(zw)", Vector) = (1,1,1,1)
        
        [Header(Depth)]
        _DeepShrink("Deep Shrink", float) = 1
        _DeepCurve("Deep Curve", float) = 1
        _Absorption("Absorption", float) = 1
        
        [Header(Reflection)]
        _FrenelPower("Frenel Power", float) = 1
        _FrenelOffset("Frenel Offset", float) = 0
        
        [Header(Refraction)]
        _DistortionIntensity("Distortion Intensity", float) = 1
        
        [Header(Lighting)]
        _SpecularIntensity("Specular Intensity", float) = 1
        _SHIntensity("SH Intensity", Range(0, 5)) = 0.1
        _SSSIntensity("SSS Intensity", Range(0, 5)) = 0.1
        _Scattering("Scattering", float) = 0
        _SpecularRangeScale("SpecularRangeScale", float) = 1
        _SpecularRangePower("SpecularRangePower", float) = 1
        _Smoothness("Smoothness", Range(0, 1)) = 0.95
        
        [Header(Foam)]
        _FoamMap("FoamMap", 2D) = "white" {}
        _FoamDepth("Foam Depth", float) = 0
        _FoamGradient("Foam Gradient", Range(0, 10)) = 0
        _FoamOffset("Foam Offset", Range(0, 10)) = 0
        _FoamFeather("Foam Featuer", Range(0, 10)) = 0
        
        [Header(Debug)]
        [Toggle(_SHOW_SCREEN_UV)]_SHOW_SCREEN_UV("Show Screen UV", Float) = 0
        [Toggle(_SHOW_REFLECTION)]_SHOW_REFLECTION("Show Reflection", Float) = 0
        [Toggle(_SHOW_DEPTH)]_SHOW_DEPTH("Show Depth", Float) = 0
        [Toggle(_SHOW_NORMAL)]_SHOW_NORMAL("Show Normal", Float) = 0
        [Toggle(_SHOW_FRENEL)]_SHOW_FRENEL("Show Frenel", Float) = 0
        [Toggle(_SHOW_REFRACTION)]_SHOW_REFRACTION("Show Refraction", Float) = 0
        [Toggle(_SHOW_REFRACTION_MASK)]_SHOW_REFRACTION_MASK("Show Refraction Mask", Float) = 0
        [Toggle(_SHOW_WATER_COLOR)]_SHOW_WATER_COLOR("Show Water Color", Float) = 0
        [Toggle(_SHOW_SH)]_SHOW_SH("Show SH", Float) = 0
        [Toggle(_SHOW_SSS)]_SHOW_SSS("Show SSS", Float) = 0
        [Toggle(_SHOW_SCATTERING)]_SHOW_SCATTERING("Show Scattering", Float) = 0
        [Toggle(_SHOW_SPECULAR)]_SHOW_SPECULAR("Show Specular", Float) = 0
        [Toggle(_SHOW_FOAM)]_SHOW_FOAM("Show Foam", Float) = 0
        [Toggle(_SHOW_ALPHA)]_SHOW_ALPHA("Show Alpha", Float) = 0
        
    }
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

            #pragma shader_feature _ _REFLECTION_PLANARREFLECTION

            // Debug Feature
            #pragma shader_feature_local _ _SHOW_REFLECTION
            #pragma shader_feature_local _ _SHOW_SCREEN_UV
            #pragma shader_feature_local _ _SHOW_DEPTH
            #pragma shader_feature_local _ _SHOW_NORMAL
            #pragma shader_feature_local _ _SHOW_FRENEL
            #pragma shader_feature_local _ _SHOW_REFRACTION
            #pragma shader_feature_local _ _SHOW_REFRACTION_MASK
            #pragma shader_feature_local _ _SHOW_WATER_COLOR
            #pragma shader_feature_local _ _SHOW_SH
            #pragma shader_feature_local _ _SHOW_SSS
            #pragma shader_feature_local _ _SHOW_SCATTERING
            #pragma shader_feature_local _ _SHOW_SPECULAR
            #pragma shader_feature_local _ _SHOW_FOAM
            #pragma shader_feature_local _ _SHOW_ALPHA
            ////////////////////INCLUDES//////////////////////
			#include "WaterCommon.hlsl"

            
            #pragma vertex WaterVert
            #pragma fragment WaterFrag
            
           
            ENDHLSL
        }
    }
}