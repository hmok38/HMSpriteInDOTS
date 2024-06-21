using System.Collections.Generic;
using HMSpriteInDOTS;
using Unity.Collections;
using Unity.Entities;
using Unity.Rendering;
using UnityEngine;

namespace HM.FrameAnimation
{
    public partial struct FrameAnimationRegisterBakerSpriteSystem : Unity.Entities.ISystem
    {
        public void OnCreate(ref SystemState state)
        {
            state.RequireForUpdate<FrameAnimationRegisterBakerSprite>();
        }

        public void OnUpdate(ref SystemState state)
        {
            var graphicsSystem = state.World.GetExistingSystemManaged<EntitiesGraphicsSystem>();
            var handle = state.WorldUnmanaged.GetExistingUnmanagedSystem<HMSpriteInDOTSSystem>();
            var ecb = new Unity.Entities.EntityCommandBuffer(Allocator.Temp);
            var spriteInDOTSSystem = state.WorldUnmanaged.GetUnsafeSystemRef<HMSpriteInDOTSSystem>(handle);
           
          


            foreach (var (spriteInDotsRw, spriteInDOTSRegisterBakeSprite, entity) in
                     SystemAPI
                         .Query<RefRW<SpriteInDOTS>, FrameAnimationRegisterBakerSprite>().WithEntityAccess())
            {
                DynamicBuffer<FrameSpriteData> buffer = ecb.AddBuffer<FrameSpriteData>(entity);
                
                for (int i = 0; i < spriteInDOTSRegisterBakeSprite.Sprites.Count; i++)
                {
                    var sprite = spriteInDOTSRegisterBakeSprite.Sprites[i];

                    if (sprite == null)
                    {
                        continue;
                    }


                    var spriteHash = sprite.GetHashCode();

                    if (!spriteInDOTSSystem.SpriteMap.ContainsKey(spriteHash))
                    {
                        Debug.Log($"FrameAnimation注册sprite {sprite.name} {spriteHash}");
                        var textureHash = sprite.texture.GetHashCode();
                        if (!spriteInDOTSSystem.MaterialMap.ContainsKey(textureHash))
                        {
                            Debug.Log($"FrameAnimation注册texture {sprite.texture.name}  {textureHash}");
                            var mat = SpriteInDOTSMgr.CreateNewMaterial(sprite.texture.name);
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

                    buffer.Add(new FrameSpriteData() { SpriteHash = spriteHash });
                }

               
               
                if (spriteInDOTSRegisterBakeSprite.Sprites.Count > 0 &&
                    spriteInDOTSRegisterBakeSprite.Sprites[0] != null)
                {
                    spriteInDotsRw.ValueRW.SpriteHashCode = spriteInDOTSRegisterBakeSprite.Sprites[0].GetHashCode();
                }

                ecb.RemoveComponent<FrameAnimationRegisterBakerSprite>(entity);
            }

            ecb.Playback(state.EntityManager);
            ecb.Dispose();
        }
    }
}