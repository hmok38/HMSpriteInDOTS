using System.Collections.Generic;
using Unity.Entities;
using Unity.Mathematics;
using Unity.Rendering.Authoring;
using UnityEngine;

namespace HMSpriteInDOTS
{
    /// <summary>
    /// dots中的Sprite,可以使用BRG合批，且使用了DOTS Instancing。by:黄敏 20240606
    /// </summary>
    [RequireComponent(typeof(MeshRenderer)), RequireComponent(typeof(MeshFilter)), DisallowMultipleComponent,
     ExecuteAlways]
    public class SpriteInDOTSAuthoring : MonoBehaviour
    {
        [SerializeField] private Sprite sprite;
        [SerializeField] private Color color = Color.white;
        private static readonly int PivotAndWh = Shader.PropertyToID("_PivotAndSize");
        private static readonly int Rect1 = Shader.PropertyToID("_UvRect");
        private Material _material;

        private MaterialUvRectAuthoring _uvRectAuthoring;
        private MaterialPivotAndSizeAuthoring _pivotAndSizeAuthoring;
        private MaterialColor _materialColorAuthoring;
        [System.NonSerialized] public bool Baked;

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
            var material = this.GetComponent<MeshRenderer>().sharedMaterial;


            if (_material == null || material != _material)
            {
                _material = SpriteInDOTSMgr.CreateNewMaterial();
                this.GetComponent<MeshRenderer>().sharedMaterial = _material;
                material = _material;
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

            _uvRectAuthoring = this.GetComponent<MaterialUvRectAuthoring>();
            if (_uvRectAuthoring != null) _uvRectAuthoring.uvRect = uv;
            _pivotAndSizeAuthoring = this.GetComponent<MaterialPivotAndSizeAuthoring>();
            if (_pivotAndSizeAuthoring != null) _pivotAndSizeAuthoring.pivotAndSize = pivotAndSize;
            _materialColorAuthoring = this.GetComponent<MaterialColor>();
            if (_materialColorAuthoring != null) _materialColorAuthoring.color = color;
        }

        private void OnValidate()
        {
            Baked = false;
            SetSprite(sprite);
        }


        private class SpriteInDOTSBaker : Baker<SpriteInDOTSAuthoring>
        {
            public override void Bake(SpriteInDOTSAuthoring authoring)
            {
                DependsOn(authoring.sprite);
                authoring.Baked = true;

                var entity = GetEntity(TransformUsageFlags.Renderable);
                Color color = authoring.color.linear;
                var colorF4 = new float4(color.r, color.g, color.b, color.a);
                AddComponent(entity, new Unity.Rendering.MaterialColor() { Value = colorF4 });
                AddComponent(entity,
                    new MaterialUvRect()
                        { Value = authoring.sprite != null ? authoring.sprite.UVRect() : new float4(0, 0, 1, 1) });
                AddComponent(entity,
                    new MaterialPivotAndSize()
                    {
                        Value = authoring.sprite != null
                            ? authoring.sprite.PivotAndUnitSize()
                            : new float4(0.5f, 0.5f, 0, 0)
                    });

                AddComponent(entity, new SpriteInDOTS()
                {
                    SpriteHashCode = authoring.sprite != null ? authoring.sprite.GetHashCode() : 0
                });
                var spriteInDOTSRegisterBakeSprite = new SpriteInDOTSRegisterBakeSprite()
                {
                    Sprite = authoring.sprite
                };
                Debug.Log($"烘焙 sprite {authoring.sprite.name} {authoring.sprite.GetHashCode()} texture: {authoring.sprite.texture.name}  {authoring.sprite.texture.GetHashCode()}");
               

                AddComponentObject(entity, spriteInDOTSRegisterBakeSprite);
            }
        }
    }

    /// <summary>
    /// 
    /// </summary>
    public static class SpriteInDOTSExtend
    {
        public static Vector4 UVRect(this Sprite sprite)
        {
            var textWidth = sprite.texture.width;
            var textHeight = sprite.texture.height;
            var rect = sprite.textureRect;
            var uv = new Vector4(0, 0, 1, 1)
            {
                x = rect.x / textWidth,
                y = rect.y / textHeight,
                z = (rect.x + rect.width) / textWidth,
                w = (rect.y + rect.height) / textHeight
            };

            return uv;
        }

        public static Vector4 PivotAndUnitSize(this Sprite sprite)
        {
            var pu = new Vector4(0, 0, 1, 1)
            {
                x = sprite.pivot.x / sprite.rect.width,
                y = sprite.pivot.y / sprite.rect.height,
                z = sprite.textureRect.width / sprite.pixelsPerUnit,
                w = sprite.textureRect.height / sprite.pixelsPerUnit
            };
            return pu;
        }
    }
}