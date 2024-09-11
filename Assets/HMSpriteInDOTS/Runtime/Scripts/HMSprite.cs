using System;
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
        [SerializeField] private Sprite sprite;
        [SerializeField] private Color color = Color.white;
        [SerializeField] private RenderType renderType = RenderType.Opaque;
        [System.NonSerialized] private Material _materialOpaque, _materialTransparent;
        public bool Baked { get; set; }


        [HideInInspector, SerializeField] private Vector2 slicedWidthAndHeight;
        [SerializeField] private float alphaClipThreshold = 0.5f;
        [SerializeField] private SpriteDrawMode spriteDrawMode = SpriteDrawMode.Simple;
        private MeshRenderer _meshRenderer;
        private MeshFilter _meshFilter;

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
                if (!beSame) SetSprite(Sprite);
            }
        }

        public RenderType RenderType
        {
            get => renderType;
            set
            {
                var beSame = renderType == value;
                renderType = value;
                if (!beSame) SetSprite(Sprite);
            }
        }

        public Vector2 SlicedWidthAndHeight
        {
            get
            {
                if (Sprite != null)
                {
                    if (slicedWidthAndHeight.x == 0 || slicedWidthAndHeight.y == 0)
                    {
                        slicedWidthAndHeight.x = Sprite.PivotAndUnitSize().z;
                        slicedWidthAndHeight.y = Sprite.PivotAndUnitSize().w;
                    }

                    return slicedWidthAndHeight;
                }

                return new Vector2(1, 1);
            }
            set
            {
                var beSame = slicedWidthAndHeight == value;
                slicedWidthAndHeight = value;
                if (!beSame) SetSprite(Sprite);
            }
        }

        public float AlphaClipThreshold
        {
            get => alphaClipThreshold;
            set
            {
                var beSame = Math.Abs(alphaClipThreshold - value) < 0.001f;
                alphaClipThreshold = value;
                if (!beSame) SetSprite(Sprite);
            }
        }

        public SpriteDrawMode SpriteDrawMode
        {
            get => spriteDrawMode;
            set
            {
                var beSame = spriteDrawMode == value;
                spriteDrawMode = value;
                if (!beSame) SetSprite(Sprite);
            }
        }

        public Material MaterialOpaque
        {
            get => _materialOpaque;
            set
            {
                var beSame = _materialOpaque == value;
                if (value != null)
                {
                    _materialOpaque = new Material(value)
                    {
                        name = value.name
                    };
                }
                else
                {
                    _materialOpaque = value;
                }

                if (!beSame) SetSprite(Sprite);
            }
        }

        public Material MaterialTransparent
        {
            get => _materialTransparent;
            set
            {
                var beSame = _materialTransparent == value;
                if (value != null)
                {
                    _materialTransparent = new Material(value)
                    {
                        name = value.name
                    };
                }
                else
                {
                    _materialTransparent = value;
                }

                if (!beSame) SetSprite(Sprite);
            }
        }

        public Vector4 MeshWh
        {
            get
            {
                if (Sprite != null)
                    return new Vector4(1, 1, Sprite.pixelsPerUnit, 0f);
                return new Vector4(1, 1, 100, 0f);
            }
        }

        public Vector4 Border
        {
            get { return Sprite != null ? Sprite.border : Vector4.zero; }
        }

        void Start()
        {
            if (Baked) return;
            if (this._meshRenderer == null) this._meshRenderer = this.GetComponent<MeshRenderer>();
            if (this._meshFilter == null) this._meshFilter = this.GetComponent<MeshFilter>();
            this._meshRenderer.sharedMaterial = null;
            SetSprite(Sprite);
        }


        void SetSprite(Sprite spriteTemp)
        {
            if (Baked) return;

            if (this._meshRenderer == null) this._meshRenderer = this.GetComponent<MeshRenderer>();
            if (this._meshFilter == null) this._meshFilter = this.GetComponent<MeshFilter>();

            var material = this._meshRenderer.sharedMaterial;

            if (material == null
                || (this.RenderType == RenderType.Opaque
                    ? (material != MaterialOpaque)
                    : (material != MaterialTransparent)))
            {
                if (this.RenderType == RenderType.Opaque)
                {
                    if (MaterialOpaque == null)
                    {
                        _materialOpaque = new Material(GlobalMaterialOpaqueRes)
                        {
                            name = GlobalMaterialOpaqueRes.name,
                            color = Color.white
                        };
                    }

                    this._meshRenderer.sharedMaterial = MaterialOpaque;
                }
                else if (this.RenderType == RenderType.Transparent)
                {
                    if (MaterialTransparent == null)
                    {
                        _materialTransparent = new Material(GlobalMaterialTransparentRes)
                        {
                            name = GlobalMaterialTransparentRes.name,
                            color = Color.white
                        };
                    }

                    this._meshRenderer.sharedMaterial = MaterialTransparent;
                }

                material = this._meshRenderer.sharedMaterial;
            }

            var meshFilter = this._meshFilter;
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

            material.color = MainColor;
            material.SetVector(RectKey, uv);
            material.SetVector(PivotAndWhKey, pivotAndSize);
            var meshRenderer = this._meshRenderer;
            if (spriteTemp != null)
            {
                material.SetVector(MeshWhKey, MeshWh);
                material.SetVector(BorderKey, Border);


                material.SetVector(WidthAndHeightKey, SlicedWidthAndHeight);
            }
            else
            {
                material.SetVector(MeshWhKey, MeshWh);
                material.SetVector(BorderKey, Border);
                material.SetVector(WidthAndHeightKey, SlicedWidthAndHeight);
            }

            CalculateBound(spriteTemp);
            material.SetFloat(AlphaClipThresholdKey, AlphaClipThreshold);
            material.SetInt(DrawTypeKey, GetDrawTypeValue(this.SpriteDrawMode));
        }

        private void CalculateBound(Sprite spriteTemp)
        {
            var meshRenderer = this._meshRenderer;
            if (spriteTemp != null)
            {
                var pivotAndSize = spriteTemp.PivotAndUnitSize();

                Vector3 offset = new Vector3(
                    -(pivotAndSize.x - 0.5f) *
                    (SpriteDrawMode == SpriteDrawMode.Sliced ? SlicedWidthAndHeight.x : pivotAndSize.z),
                    -(pivotAndSize.y - 0.5f) *
                    (SpriteDrawMode == SpriteDrawMode.Sliced ? SlicedWidthAndHeight.y : pivotAndSize.w));

                Vector3 scale = transform.lossyScale;
                // meshRenderer.bounds = SpriteDrawMode == SpriteDrawMode.Sliced
                //     ? new Bounds(this.transform.position + new Vector3(offset.x * scale.x, offset.y * scale.y),
                //         new Vector3(SlicedWidthAndHeight.x * scale.x, SlicedWidthAndHeight.y * scale.y, 0f))
                //     : new Bounds(this.transform.position + new Vector3(offset.x * scale.x, offset.y * scale.y),
                //         new Vector3(
                //             pivotAndSize.z * scale.x, pivotAndSize.w * scale.y, 0f
                //         ));
                //var bounds = meshRenderer.bounds;
                //Debug.DrawLine(bounds.min, bounds.max, Color.red, 1000);
                meshRenderer.localBounds = SpriteDrawMode == SpriteDrawMode.Sliced
                    ? new Bounds(offset,
                        new Vector3(SlicedWidthAndHeight.x, SlicedWidthAndHeight.y, 0f))
                    : new Bounds(offset, new Vector3(
                        pivotAndSize.z, pivotAndSize.w, 0f
                    ));
            }
            else
            {
                meshRenderer.ResetLocalBounds();
                //meshRenderer.ResetBounds();
            }
        }

        public void OnValidate()
        {
            Baked = false;
            SetSprite(Sprite);
        }

        #region **********Static  Method*****************************************

        public static readonly int PivotAndWhKey = Shader.PropertyToID("_PivotAndSize");
        public static readonly int RectKey = Shader.PropertyToID("_UvRect");
        public static readonly int MeshWhKey = Shader.PropertyToID("_MeshWH");
        public static readonly int BorderKey = Shader.PropertyToID("_Border");
        public static readonly int DrawTypeKey = Shader.PropertyToID("_DrawType");
        public static readonly int WidthAndHeightKey = Shader.PropertyToID("_WidthAndHeight");
        public static readonly int AlphaClipThresholdKey = Shader.PropertyToID("_AlphaClipThreshold");

        private static Material _globalMaterialOpaqueRes;

        public static Material GlobalMaterialOpaqueRes
        {
            get
            {
                if (_globalMaterialOpaqueRes == null)
                {
                    _globalMaterialOpaqueRes = Resources.Load<Material>("HMSpriteOpaque");
                }

                return _globalMaterialOpaqueRes;
            }
            set => _globalMaterialOpaqueRes = value;
        }

        private static Material _globalMaterialTransparentRes;

        public static Material GlobalMaterialTransparentRes
        {
            get
            {
                if (_globalMaterialTransparentRes == null)
                {
                    _globalMaterialTransparentRes =
                        Resources.Load<Material>("HMSpriteTransparent");
                }

                return _globalMaterialTransparentRes;
            }
            set => _globalMaterialTransparentRes = value;
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

        #endregion


#if UNITY_EDITOR
        public void OnEditorCallTransformChanged()
        {
            //Debug.Log("OnEditorCall");
            CalculateBound(Sprite);
        }

        public void OnRestLocalScale()
        {
            if (this.transform.localScale != Vector3.one)
            {
                var transform1 = this.transform;
                var localS = transform1.localScale;
                var old = this.SlicedWidthAndHeight;
                this.SlicedWidthAndHeight = new Vector2(old.x * localS.x, old.y * localS.y);
                transform1.localScale = Vector3.one;
            }
        }
#endif
    }


    public enum RenderType
    {
        Opaque,
        Transparent
    }
}