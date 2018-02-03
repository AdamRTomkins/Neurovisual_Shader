using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class NeurovisualEffect : MonoBehaviour {

    public Shader shader;
    public float size = 10;
    public int gray = 1;
    private Material Material
    {
        get
        {
            if(_mat == null && shader != null)
            {
                _mat = new Material(shader);
            }
            return _mat;

        }
    }

    private Material _mat;

    void OnDestroy()
    {
        DestroyImmediate(_mat);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Material != null)
            Graphics.Blit(source, destination, Material);
        else
            Graphics.Blit(source, destination);
    }

    void Update()
    {
        if (Material)
        {
            Material.SetFloat("_Size", size);
            Material.SetInt("_Gray", gray);

        }
    }
}
