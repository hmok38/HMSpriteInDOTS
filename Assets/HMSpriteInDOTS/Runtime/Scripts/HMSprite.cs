using System;
using Codice.Client.Common;
using UnityEditor;
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
        private static readonly int PivotAndWh = Shader.PropertyToID("_PivotAndSize");
        private static readonly int Rect1 = Shader.PropertyToID("_UvRect");
        private Material _material;

        // private MaterialUvRectAuthoring _uvRectAuthoring;
        // private MaterialPivotAndSizeAuthoring _pivotAndSizeAuthoring;
        // private MyMaterialColorAuthoring _materialColorAuthoring;
        [System.NonSerialized] public bool Baked;
        public SpriteDrawMode spriteDrawMode = SpriteDrawMode.Simple;

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

            Debug.Log(spriteTemp.name + " " + spriteTemp.bounds + " " + spriteTemp.border + " " + spriteTemp.rect);

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
            if (spriteTemp != null)
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
            material.SetVector(Rect1, uv);
            material.SetVector(PivotAndWh, pivotAndSize);

        
            //meshFilter.sharedMesh.bounds = spriteTemp.bounds;
            //Debug.Log(" sharedMesh.bounds " + meshFilter.sharedMesh.bounds);
            // _uvRectAuthoring = this.GetComponent<MaterialUvRectAuthoring>();
            // if (_uvRectAuthoring != null) _uvRectAuthoring.uvRect = uv;
            // _pivotAndSizeAuthoring = this.GetComponent<MaterialPivotAndSizeAuthoring>();
            // if (_pivotAndSizeAuthoring != null) _pivotAndSizeAuthoring.pivotAndSize = pivotAndSize;
            // _materialColorAuthoring = this.GetComponent<MyMaterialColorAuthoring>();
            // if (_materialColorAuthoring != null) _materialColorAuthoring.color = color;
        }

        private void OnValidate()
        {
            Baked = false;
            SetSprite(sprite);
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

#if UNITY_EDITOR
    [EditorTool("Platform Tool")]
    public class HMSpriteEditor:UnityEditor.EditorTools.EditorTool
    {
        
    }
    
    
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