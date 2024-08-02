using Unity.Collections;
using Unity.Entities;
using Unity.Rendering;
using UnityEngine;

// ReSharper disable once CheckNamespace
namespace HM.HMSprite.ECS
{
    [Unity.Entities.CreateAfter(typeof(HMSpriteInDOTSSystem)),
     Unity.Entities.UpdateBefore(typeof(HMSpriteInDOTSSystem))]
    public partial struct SpriteInDOTSRegisterBakeSpriteSystem : ISystem
    {
        public void OnCreate(ref SystemState state)
        {
            state.RequireForUpdate<SpriteInDOTSRegisterBakeSprite>();
        }

        public void OnUpdate(ref SystemState state)
        {
            var graphicsSystem = state.World.GetExistingSystemManaged<EntitiesGraphicsSystem>();
            var handle = state.WorldUnmanaged.GetExistingUnmanagedSystem<HMSpriteInDOTSSystem>();
            var ecb = new Unity.Entities.EntityCommandBuffer(Allocator.Temp);
            var spriteInDOTSSystem = state.WorldUnmanaged.GetUnsafeSystemRef<HMSpriteInDOTSSystem>(handle);


            foreach (var (spriteInDOTSRW, spriteInDOTSRegisterBakeSprite, entity) in
                     SystemAPI
                         .Query<RefRW<SpriteInDOTS>, SpriteInDOTSRegisterBakeSprite>().WithEntityAccess())
            {
                var sprite = spriteInDOTSRegisterBakeSprite.Sprite;

                if (sprite == null)
                {
                    Debug.Log($"SpriteInDOTSRegister注册sprite 为空");
                    continue;
                }


                var spriteHash = sprite.GetHashCode();

                if (!spriteInDOTSSystem.SpriteMap.ContainsKey(spriteHash))
                {
                    Debug.Log($"SpriteInDOTSRegister注册sprite {sprite.name} {spriteHash}");
                    var textureHash = sprite.texture.GetHashCode();
                    if (!spriteInDOTSSystem.MaterialMap.ContainsKey(textureHash))
                    {
                        Debug.Log($"SpriteInDOTSRegister注册texture {sprite.texture.name}  {textureHash}");
                        var mat = HMSprite.CreateMaterial(sprite.texture.name);
                        mat.mainTexture = sprite.texture;
                        var id = graphicsSystem.RegisterMaterial(mat);
                        spriteInDOTSSystem.MaterialMap.Add(textureHash, id);
                    }


                    spriteInDOTSSystem.SpriteMap.Add(spriteHash, new SpriteInDOTSId()
                    {
                        MaterialID = spriteInDOTSSystem.MaterialMap[textureHash],
                        MeshID = spriteInDOTSSystem.MeshID,
                        SpriteHashCode = spriteHash,
                        MaterialUvRect = sprite.UVRect(),
                        MaterialPivotAndSize = sprite.PivotAndUnitSize()
                    });
                }


                ecb.RemoveComponent<SpriteInDOTSRegisterBakeSprite>(entity);

                spriteInDOTSRW.ValueRW.SpriteHashCode = spriteInDOTSRegisterBakeSprite.Sprite.GetHashCode();
            }

            ecb.Playback(state.EntityManager);
            ecb.Dispose();
        }
    }
}