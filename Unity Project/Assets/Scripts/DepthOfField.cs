using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class DepthOfField : MonoBehaviour {

    public float depthFocus = 0.5f;
    public float lensFocus = 0.1f;
    public bool displayDepthBuffer = false;

    public Material material;

    private Camera cam;

    void Awake()
    {
        cam = GetComponent<Camera>();
        cam.depthTextureMode = DepthTextureMode.Depth;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {

        Graphics.Blit(source, destination, material);
    }

    void Update() {
        if (material)
        {
            material.SetFloat("_DepthFocus", depthFocus);
            material.SetFloat("_LensFocus", lensFocus);
            if(displayDepthBuffer) 
                material.SetFloat("_DisplayDepth", 1); 
            else
                material.SetFloat("_DisplayDepth", 0);
        }
    }
}
