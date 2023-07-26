using UnityEngine.Experimental.Rendering;

namespace UnityEngine.Rendering.Universal
{
    [ExecuteAlways]
    public class Water : MonoBehaviour
    {
        // Singleton
        private static Water _instance;
        public static Water Instance
        {
            get
            {
                if (_instance == null)
                    _instance = (Water)FindObjectOfType(typeof(Water));
                return _instance;
            }
        }
    
        [SerializeField]
        public PlanarReflections.PlanarReflectionSettings m_settings = new PlanarReflections.PlanarReflectionSettings();

        [SerializeField]
        private bool m_EnablePlanarReflection = true;
        
        // Script references
        private PlanarReflections _planarReflections;
       
        private void OnEnable()
        {
            
            Init();
            RenderPipelineManager.beginCameraRendering += BeginCameraRendering;
            
          
            
        }
        
        private void OnDisable() {
            Cleanup();
        }

        void Cleanup()
        {
            RenderPipelineManager.beginCameraRendering -= BeginCameraRendering;
        }

        private void SetWaves()
        {
            if (m_EnablePlanarReflection)
            {
                Shader.EnableKeyword("_REFLECTION_PLANARREFLECTION");
            }
            else
            {
                Shader.DisableKeyword("_REFLECTION_PLANARREFLECTION");
            }
        }

        private void GenerateColorRamp()
        {
          
        }
        
        public void Init()
        {
            SetWaves();
            GenerateColorRamp();
            if (m_EnablePlanarReflection)
            {
                if (!gameObject.TryGetComponent(out _planarReflections))
                {
                    _planarReflections = gameObject.AddComponent<PlanarReflections>();
                }
            
                _planarReflections.hideFlags = HideFlags.HideAndDontSave /*| HideFlags.HideInInspector*/;
                _planarReflections.enabled = true;
                _planarReflections.m_settings = m_settings;
            }
        }

        private void BeginCameraRendering(ScriptableRenderContext src, Camera cam)
        {
            if (cam.cameraType == CameraType.Preview) return;
            
        }
    }
}