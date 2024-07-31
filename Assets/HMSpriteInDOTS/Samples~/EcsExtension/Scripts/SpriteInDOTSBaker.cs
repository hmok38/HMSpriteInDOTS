using Unity.Entities;
using Unity.Mathematics;
using UnityEngine;

namespace HM.HMSprite
{
    public class SpriteInDOTSBaker : Baker<HMSprite>
    {
        public override void Bake(HMSprite authoring)
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
            //Debug.Log($"烘焙 sprite {authoring.sprite.name} {authoring.sprite.GetHashCode()} texture: {authoring.sprite.texture.name}  {authoring.sprite.texture.GetHashCode()}");
               

            AddComponentObject(entity, spriteInDOTSRegisterBakeSprite);
        }
    }

}