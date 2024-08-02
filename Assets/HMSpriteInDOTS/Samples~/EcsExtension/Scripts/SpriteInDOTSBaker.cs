using Unity.Entities;
using Unity.Mathematics;
using UnityEngine;

namespace HM.HMSprite
{
    public class SpriteInDOTSBaker : Baker<HMSprite>
    {
        public override void Bake(HMSprite authoring)
        {
            DependsOn(authoring.Sprite);
            authoring.Baked = true;

            var entity = GetEntity(TransformUsageFlags.Renderable);
            Color color = authoring.MainColor.linear;
            var colorF4 = new float4(color.r, color.g, color.b, color.a);
            AddComponent(entity, new Unity.Rendering.MaterialColor() { Value = colorF4 });
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

            AddComponent(entity, new SpriteInDOTS()
            {
                SpriteHashCode = authoring.Sprite != null ? authoring.Sprite.GetHashCode() : 0
            });
            var spriteInDOTSRegisterBakeSprite = new SpriteInDOTSRegisterBakeSprite()
            {
                Sprite = authoring.Sprite
            };
            //Debug.Log($"烘焙 sprite {authoring.sprite.name} {authoring.sprite.GetHashCode()} texture: {authoring.sprite.texture.name}  {authoring.sprite.texture.GetHashCode()}");
               

            AddComponentObject(entity, spriteInDOTSRegisterBakeSprite);
        }
    }

}