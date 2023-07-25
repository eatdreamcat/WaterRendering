using System;

namespace UnityEngine.Rendering.Universal
{
    [ExecuteAlways]
    public class PlanarReflections : MonoBehaviour
    {
        [Serializable]
        public enum ResolutionMulltiplier
        {
            Full,
            Half,
            Third,
            Quarter
        }
        
        [Serializable]
        public class PlanarReflectionSettings
        {
            public ResolutionMulltiplier m_ResolutionMultiplier = ResolutionMulltiplier.Third;
            public float m_ClipPlaneOffset = 0.07f;
            public LayerMask m_ReflectLayers = -1;
            public bool m_Shadows;
        }
        
        [SerializeField]
        public PlanarReflectionSettings m_settings = new PlanarReflectionSettings();
        
        private static Camera _reflectionCamera;
        private RenderTexture _reflectionTexture;
        private readonly int _planarReflectionTextureId = Shader.PropertyToID("_PlanarReflectionTexture");
        
        
        public static event Action<ScriptableRenderContext, Camera> BeginPlanarReflections;

        private void OnEnable()
        {
            RenderPipelineManager.beginCameraRendering += ExecutePlanarReflections;
        }

        // Cleanup all the objects we possibly have created
        private void OnDisable()
        {
            Cleanup();
        }

        private void OnDestroy()
        {
            Cleanup();
        }

        private void Cleanup()
        {
            RenderPipelineManager.beginCameraRendering -= ExecutePlanarReflections;

            if(_reflectionCamera)
            {
                _reflectionCamera.targetTexture = null;
                SafeDestroy(_reflectionCamera.gameObject);
            }
            if (_reflectionTexture)
            {
                RenderTexture.ReleaseTemporary(_reflectionTexture);
            }
        }

        private static void SafeDestroy(Object obj)
        {
            if (Application.isEditor)
            {
                DestroyImmediate(obj);
            }
            else
            {
                Destroy(obj);
            }
        }

        private Camera CreateMirrorObjects()
        {
            var go = new GameObject("Planar Reflections",typeof(Camera));
            var cameraData = go.AddComponent(typeof(UniversalAdditionalCameraData)) as UniversalAdditionalCameraData;

            cameraData.requiresColorOption = CameraOverrideOption.Off;
            cameraData.requiresDepthOption = CameraOverrideOption.Off;
            cameraData.SetRenderer(1);

            var t = transform;
            var reflectionCamera = go.GetComponent<Camera>();
            reflectionCamera.transform.SetPositionAndRotation(t.position, t.rotation);
            reflectionCamera.depth = -10;
            reflectionCamera.enabled = false;
            go.hideFlags = HideFlags.HideAndDontSave;

            return reflectionCamera;
        }

        private void UpdateReflectionCamera(Camera realCamera)
        {
            if (_reflectionCamera == null)
                _reflectionCamera = CreateMirrorObjects();
            
            // find out the reflection plane: position and normal in world space
            Vector3 pos = Vector3.zero;
            Vector3 normal = Vector3.up;
            
            UpdateCamera(realCamera, _reflectionCamera);
        }

        private void UpdateCamera(Camera src, Camera dest)
        {
            if (dest == null) return;

            dest.CopyFrom(src);
            dest.useOcclusionCulling = false;
            if (dest.gameObject.TryGetComponent(out UniversalAdditionalCameraData camData))
            {
                camData.renderShadows = m_settings.m_Shadows; // turn off shadows for the reflection camera
            }
        }
        
        private void ExecutePlanarReflections(ScriptableRenderContext context, Camera camera)
        {
            // we dont want to render planar reflections in reflections or previews
            if (camera.cameraType == CameraType.Reflection || camera.cameraType == CameraType.Preview)
                return;
            
            UpdateReflectionCamera(camera); // create reflected camera
        }

    }
    
}