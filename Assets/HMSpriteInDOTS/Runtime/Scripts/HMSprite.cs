using UnityEditor.EditorTools;
using UnityEngine;

// ReSharper disable once CheckNamespace
namespace HM.HMSprite
{
    /// <summary>
    /// dots中的Sprite,可以使用BRG合批，且使用了DOTS Instancing。by:黄敏 20240606
    /// </summary>
    [RequireComponent(typeof(MeshRenderer)), RequireComponent(typeof(MeshFilter)), DisallowMultipleComponent,
     ExecuteAlways]
    public class HMSprite : MonoBehaviour
    {
        [SerializeField] public Sprite sprite;
        [SerializeField] public Color color = Color.white;
        private static readonly int PivotAndWhKey = Shader.PropertyToID("_PivotAndSize");
        private static readonly int RectKey = Shader.PropertyToID("_UvRect");
        private static readonly int MeshWhKey = Shader.PropertyToID("_MeshWH");
        private static readonly int BorderKey = Shader.PropertyToID("_Border");
        private static readonly int DrawTypeKey = Shader.PropertyToID("_DrawType");
        private static readonly int WidthAndHeightKey = Shader.PropertyToID("_WidthAndHeight");

        private Material _material;

        [System.NonSerialized] public bool Baked;
        public SpriteDrawMode spriteDrawMode = SpriteDrawMode.Simple;
        public RenderType renderType = RenderType.Opaque;
        public Vector2 slicedWidthAndHeight;

        public Sprite Sprite
        {
            get => sprite;
            set
            {
                var beSame = sprite != value;
                sprite = value;
                if (!beSame) SetSprite(sprite);
            }
        }

        public Color MainColor
        {
            get => color;
            set
            {
                var beSame = color != value;
                color = value;
                if (!beSame) SetSprite(sprite);
            }
        }

        void Start()
        {
            if (Baked) return;
            this.GetComponent<MeshRenderer>().sharedMaterial = null;
            SetSprite(sprite);
        }


        void SetSprite(Sprite spriteTemp)
        {
            if (Baked) return;

            // Debug.Log(spriteTemp.name + " " + spriteTemp.bounds + " " + spriteTemp.border + " " + spriteTemp.rect);

            var material = this.GetComponent<MeshRenderer>().sharedMaterial;


            if (_material == null || material != _material)
            {
                _material = HMSprite.CreateNewMaterial();
                this.GetComponent<MeshRenderer>().sharedMaterial = _material;
                material = _material;
            }

            var meshFilter = this.GetComponent<MeshFilter>();
            if (meshFilter.sharedMesh == null)
            {
                meshFilter.sharedMesh = HMSprite.SpriteMesh;
            }
            
            var uv = new Vector4(0, 0, 1, 1);
            var pivotAndSize = new Vector4(0.5f, 0.5f, 0, 0);
            if (spriteTemp != null && spriteTemp.texture != null)
            {
                material.mainTexture = spriteTemp.texture;
                uv = spriteTemp.UVRect();
                pivotAndSize = spriteTemp.PivotAndUnitSize();
            }
            else
            {
                material.mainTexture = null;
            }

            material.color = color;
            material.SetVector(RectKey, uv);
            material.SetVector(PivotAndWhKey, pivotAndSize);
            if (spriteTemp != null)

            {
                material.SetVector(MeshWhKey, new Vector4(1, 1, spriteTemp.pixelsPerUnit, 0.5f));
                material.SetVector(BorderKey, spriteTemp.border);
                if (slicedWidthAndHeight.x == 0 || slicedWidthAndHeight.y == 0)
                {
                    slicedWidthAndHeight.x = spriteTemp.PivotAndUnitSize().z;
                    slicedWidthAndHeight.y = spriteTemp.PivotAndUnitSize().w;
                }

                material.SetVector(WidthAndHeightKey, slicedWidthAndHeight);
                var meshRenderer = this.GetComponent<MeshRenderer>();

                Debug.Log(spriteTemp.name + " before " + meshRenderer.bounds);
                meshRenderer.bounds = spriteDrawMode == SpriteDrawMode.Sliced
                    ? new Bounds(this.transform.position,
                        new Vector3(slicedWidthAndHeight.x, slicedWidthAndHeight.y, 0.1f))
                    : new Bounds(this.transform.position, new Vector3(
                        spriteTemp.PivotAndUnitSize().z, spriteTemp.PivotAndUnitSize().w, 0.1f
                    ));
              
                Debug.Log(spriteTemp.name + " after " + meshRenderer.bounds);
              //  meshRenderer.ResetBounds();
                Debug.Log(spriteTemp.name + " after2 " + meshRenderer.bounds);
            }
            else
            {
                material.SetVector(MeshWhKey, new Vector4(1, 1, 100, 0.5f));
                material.SetVector(BorderKey, Vector4.zero);
                material.SetVector(WidthAndHeightKey, new Vector4(1, 1));
                var meshRenderer = this.GetComponent<MeshRenderer>();
                meshRenderer.ResetLocalBounds();
                meshRenderer.ResetBounds();
            }


            material.SetInt(DrawTypeKey, GetDrawTypeValue(this.spriteDrawMode));
        }

        private void OnValidate()
        {
            Baked = false;
            SetSprite(sprite);
        }

        public static int GetDrawTypeValue(SpriteDrawMode spriteDrawMode)
        {
            switch (spriteDrawMode)
            {
                case SpriteDrawMode.Simple: return 0;
                case SpriteDrawMode.Sliced: return 1;
                case SpriteDrawMode.Tiled: return 0;
            }

            return 0;
        }

        public static Material CreateNewMaterial(string name = "HMSpriteInDOTS")
        {
            var mat = Resources.Load<Material>(
                "Shader Graphs_HMSpriteInDOTS"); ////Shader.Find("Shader Graphs/" + nameof(HMSpriteInDOTS)
            var material = new Material(mat)
            {
                name = name,
                color = Color.cyan
            };
            return material;
        }

        private static Mesh _spriteMesh;

        /// <summary>
        /// 获取mesh
        /// </summary>
        public static Mesh SpriteMesh
        {
            get
            {
                if (_spriteMesh == null)
                {
                    _spriteMesh = CreateQuadMesh();
                }

                return _spriteMesh;
            }
        }

        public static Mesh CreateQuadMesh()
        {
            Mesh mesh = new Mesh();

            Vector3[] vertices = new Vector3[4]
            {
                new Vector3(-0.5f, -0.5f, 0),
                new Vector3(0.5f, -0.5f, 0),
                new Vector3(-0.5f, 0.5f, 0),
                new Vector3(0.5f, 0.5f, 0)
            };
            mesh.vertices = vertices;

            int[] tris = new int[6]
            {
                // lower left triangle
                0, 2, 1,
                // upper right triangle
                2, 3, 1
            };
            mesh.triangles = tris;

            Vector3[] normals = new Vector3[4]
            {
                -Vector3.forward,
                -Vector3.forward,
                -Vector3.forward,
                -Vector3.forward
            };
            mesh.normals = normals;

            Vector2[] uv = new Vector2[4]
            {
                new Vector2(0, 0),
                new Vector2(1, 0),
                new Vector2(0, 1),
                new Vector2(1, 1)
            };
            mesh.uv = uv;
            return mesh;
        }
    }


    public enum RenderType
    {
        Opaque,
        Transparent
    }


#if UNITY_EDITOR
    // [EditorTool("Platform Tool")]
    // public class HMSpriteEditor : UnityEditor.EditorTools.EditorTool
    // {
    // }


    // [UnityEditor.CustomEditor(typeof(HMSprite))]
    // public class HMSpriteEditor : UnityEditor.Editor
    // {
    //     private void OnSceneGUI()
    //     {
    //         HMSprite t = (target as HMSprite );
    //         if (Event.current.type == EventType.Repaint)
    //         {
    //             Transform transform = ((HMSprite)target).transform;
    //             Handles.color = Handles.xAxisColor;
    //             Handles.RectangleHandleCap(
    //                 0,
    //                 transform.position + new Vector3(3f, 0f, 0f),
    //                 transform.rotation * Quaternion.LookRotation(Vector3.right),
    //                 1,
    //                 EventType.Repaint
    //             );
    //             Handles.color = Handles.yAxisColor;
    //             Handles.RectangleHandleCap(
    //                 0,
    //                 transform.position + new Vector3(0f, 3f, 0f),
    //                 transform.rotation * Quaternion.LookRotation(Vector3.up),
    //                 1,
    //                 EventType.Repaint
    //             );
    //             Handles.color = Handles.zAxisColor;
    //             Handles.RectangleHandleCap(
    //                 0,
    //                 transform.position + new Vector3(0f, 0f, 3f),
    //                 transform.rotation * Quaternion.LookRotation(Vector3.forward),
    //                 1,
    //                 EventType.Repaint
    //             );
    //         }
    //         
    //     }
    // }
#endif
}