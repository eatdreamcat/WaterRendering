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
    
        // Script references
        private PlanarReflections _planarReflections;
        
        private static readonly int CameraRoll = Shader.PropertyToID("_CameraRoll");
        private static readonly int InvViewProjection = Shader.PropertyToID("_InvViewProjection");
        
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
            
        }

        public void Init()
        {
            SetWaves();
            
            if (!gameObject.TryGetComponent(out _planarReflections))
            {
                _planarReflections = gameObject.AddComponent<PlanarReflections>();
            }
            
            _planarReflections.hideFlags = HideFlags.HideAndDontSave /*| HideFlags.HideInInspector*/;
            _planarReflections.enabled = true;
        }

        private void BeginCameraRendering(ScriptableRenderContext src, Camera cam)
        {
            if (cam.cameraType == CameraType.Preview) return;
            
            var roll = cam.transform.localEulerAngles.z;
            Shader.SetGlobalFloat(CameraRoll, roll);
            Shader.SetGlobalMatrix(InvViewProjection,
                (GL.GetGPUProjectionMatrix(cam.projectionMatrix, false) * cam.worldToCameraMatrix).inverse);
            
            
        }
    }
}