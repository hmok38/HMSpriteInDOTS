using HM.HMSprite.ECS;
using Unity.Collections;
using Unity.Entities;
using Unity.Rendering;

// ReSharper disable once CheckNamespace
namespace HM.HMSprite.FrameAnimation
{
    [CreateAfter(typeof(EntitiesGraphicsSystem))]
    [CreateAfter(typeof(HMSpriteInDOTSSystem))]
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
            var spriteInDOTSRegisterBakeHandle =
                state.WorldUnmanaged.GetExistingUnmanagedSystem<SpriteInDOTSRegisterBakeSpriteSystem>();

            var registerBakeSpriteSystem =
                state.WorldUnmanaged.GetUnsafeSystemRef<SpriteInDOTSRegisterBakeSpriteSystem>(
                    spriteInDOTSRegisterBakeHandle);

            //Debug.Log($"FrameAnimationRegisterBakerSpriteSystem MeshID ={spriteInDOTSSystem.MeshID.value}");
            foreach (var (spriteInDotsRw, spriteInDOTSRegisterBakeSprite, entity) in
                     SystemAPI
                         .Query<RefRW<SpriteInDOTS>, FrameAnimationRegisterBakerSprite>().WithEntityAccess())
            {
                DynamicBuffer<FrameSpriteData> buffer = ecb.SetBuffer<FrameSpriteData>(entity);
                buffer.Clear();

                bool hasFail = false;
                for (int i = 0; i < spriteInDOTSRegisterBakeSprite.Sprites.Count; i++)
                {
                    var sprite = spriteInDOTSRegisterBakeSprite.Sprites[i];

                    if (sprite == null)
                    {
                        continue;
                    }

                    var beSuc = registerBakeSpriteSystem.RegisterSprite(ref graphicsSystem, ref spriteInDOTSSystem,
                        sprite,
                        spriteInDotsRw.ValueRO.RenderTypeV, out var spriteHashCode, out var spriteKeyOpaque,
                        out var spriteKeyTransparent);

                    if (beSuc)
                    {
                        buffer.Add(new FrameSpriteData()
                        {
                            SpriteHash = spriteHashCode, SpriteKeyOpaque = spriteKeyOpaque,
                            SpriteKeyTransparent = spriteKeyTransparent
                        });
                    }
                    else
                    {
                        hasFail = true;
                    }
                }


                if (spriteInDOTSRegisterBakeSprite.Sprites.Count > 0 &&
                    spriteInDOTSRegisterBakeSprite.Sprites[0] != null)
                {
                    spriteInDotsRw.ValueRW.SpriteHashCode = spriteInDOTSRegisterBakeSprite.Sprites[0].GetHashCode();
                }

                if (!hasFail)
                    ecb.RemoveComponent<FrameAnimationRegisterBakerSprite>(entity);
            }

            ecb.Playback(state.EntityManager);
            ecb.Dispose();
        }
    }
}