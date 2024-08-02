using Unity.Entities;
using Unity.Mathematics;
using UnityEngine;

// ReSharper disable once CheckNamespace
namespace HM.HMSprite.ECS
{
    public class SpriteInDOTSBaker : Baker<HMSprite>
    {
        public override void Bake(HMSprite authoring)
        {
            DependsOn(authoring.Sprite);
            authoring.Baked = true;

            var entity = GetEntity(TransformUsageFlags.Renderable);

            //---以下4个是根据sprite属性生成的参数,不可自定义
            AddComponent(entity,
                new MaterialUvRect()
                    { Value = authoring.Sprite != null ? authoring.Sprite.UVRect() : new float4(0, 0, 1, 1) });
            AddComponent(entity,
                new MaterialPivotAndSize()
                {
                    Value = authoring.Sprite != null
                        ? authoring.Sprite.PivotAndUnitSize()
                        : new float4(0.5f, 0.5f, 0, 0)
                });
            AddComponent(entity,
                new MaterialMeshWh()
                {
                    Value = authoring.MeshWh
                });
            AddComponent(entity,
                new MaterialBorder()
                {
                    Value = authoring.Border
                });


            //----以下4个是可以自定义修改的参数----------
            Color color = authoring.MainColor.linear;
            var colorF4 = new float4(color.r, color.g, color.b, color.a);
            AddComponent(entity, new Unity.Rendering.MaterialColor() { Value = colorF4 });
            AddComponent(entity,
                new MaterialDrawType()
                {
                    Value = (float)authoring.SpriteDrawMode
                });
            AddComponent(entity,
                new MaterialWidthAndHeight()
                {
                    Value = authoring.SlicedWidthAndHeight
                });
            AddComponent(entity,
                new MaterialAlphaClipThreshold()
                {
                    Value = authoring.AlphaClipThreshold
                });
            var spriteInDOTS = new SpriteInDOTS()
            {
                SpriteHashCode = authoring.Sprite != null ? authoring.Sprite.GetHashCode() : 0,
                RenderTypeV = authoring.RenderType,
                AlphaClipThreshold = authoring.AlphaClipThreshold,
                DrawType = (int)authoring.spriteDrawMode,
                SlicedWidthAndHeight = authoring.SlicedWidthAndHeight
            };
            spriteInDOTS.SpriteKeyOpaque =
                SpriteInDOTSMgr.GetSpriteOrTextureKey(spriteInDOTS.SpriteHashCode, RenderType.Opaque);
            spriteInDOTS.SpriteKeyTransparent =
                SpriteInDOTSMgr.GetSpriteOrTextureKey(spriteInDOTS.SpriteHashCode, RenderType.Transparent);
            AddComponent(entity, spriteInDOTS);


            var spriteInDOTSRegisterBakeSprite = new SpriteInDOTSRegisterBakeSprite()
            {
                Sprite = authoring.Sprite,
                RenderTypeV = authoring.RenderType,
                AlphaClipThreshold = authoring.AlphaClipThreshold,
                DrawType = (int)authoring.spriteDrawMode,
                SlicedWidthAndHeight = authoring.SlicedWidthAndHeight
            };
            //Debug.Log($"烘焙 sprite {authoring.sprite.name} {authoring.sprite.GetHashCode()} texture: {authoring.sprite.texture.name}  {authoring.sprite.texture.GetHashCode()}");


            AddComponentObject(entity, spriteInDOTSRegisterBakeSprite);
        }
    }
}