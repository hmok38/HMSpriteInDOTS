using Unity.Collections;
using Unity.Entities;
using Unity.Mathematics;
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
            EntitiesGraphicsSystem graphicsSystem = state.World.GetExistingSystemManaged<EntitiesGraphicsSystem>();
            var handle = state.WorldUnmanaged.GetExistingUnmanagedSystem<HMSpriteInDOTSSystem>();
            var ecb = new Unity.Entities.EntityCommandBuffer(Allocator.Temp);
            var spriteInDOTSSystem = state.WorldUnmanaged.GetUnsafeSystemRef<HMSpriteInDOTSSystem>(handle);


            foreach (var (spriteInDotsRw, spriteInDOTSRegisterBakeSprite, entity) in
                     SystemAPI
                         .Query<RefRW<SpriteInDOTS>, SpriteInDOTSRegisterBakeSprite>().WithEntityAccess())
            {
                var sprite = spriteInDOTSRegisterBakeSprite.Sprite;
                var beSuc = RegisterSprite(ref graphicsSystem, ref spriteInDOTSSystem,
                    sprite, spriteInDOTSRegisterBakeSprite.RenderTypeV, out var spriteHashCode, out var spriteKeyOpaque,
                    out var spriteKeyTransparent);
                if (beSuc)
                {
                    ecb.RemoveComponent<SpriteInDOTSRegisterBakeSprite>(entity);
                    spriteInDotsRw.ValueRW.SpriteHashCode = spriteHashCode;
                    spriteInDotsRw.ValueRW.SpriteKeyOpaque = spriteKeyOpaque;
                    spriteInDotsRw.ValueRW.SpriteKeyTransparent = spriteKeyTransparent;
                }
            }

            ecb.Playback(state.EntityManager);
            ecb.Dispose();
        }

        /// <summary>
        /// 注册sprite
        /// </summary>
        /// <param name="graphicsSystem"></param>
        /// <param name="spriteInDOTSSystem"></param>
        /// <param name="sprite"></param>
        /// <param name="renderType"></param>
        /// <param name="spriteHashCode"></param>
        /// <param name="spriteKeyOpaque"></param>
        /// <param name="spriteKeyTransparent"></param>
        /// <returns></returns>
        public bool RegisterSprite(ref EntitiesGraphicsSystem graphicsSystem,
            ref HMSpriteInDOTSSystem spriteInDOTSSystem, in Sprite sprite, in RenderType renderType,
            out int spriteHashCode, out int spriteKeyOpaque, out int spriteKeyTransparent
        )
        {
            if (sprite == null)
            {
                Debug.Log($"SpriteInDOTSRegister注册sprite 为空");
                spriteHashCode = 0;
                spriteKeyOpaque = 0;
                spriteKeyTransparent = 0;
                return false;
            }


            var spriteHash = sprite.GetHashCode();
            var spriteKey =
                SpriteInDOTSMgr.GetSpriteOrTextureKey(spriteHash, renderType);


            if (!spriteInDOTSSystem.SpriteKeyMap.ContainsKey(spriteKey))
            {
                Debug.Log(
                    $"SpriteInDOTSRegister注册sprite {sprite.name} {spriteHash} RenderTypeV: {renderType} key={spriteKey}");
                var textureHash = sprite.texture.GetHashCode();
                var materialKey =
                    SpriteInDOTSMgr.GetSpriteOrTextureKey(textureHash,
                        renderType);

                if (!spriteInDOTSSystem.MaterialMap.ContainsKey(materialKey))
                {
                    Debug.Log(
                        $"SpriteInDOTSRegister注册texture {sprite.texture.name}  {textureHash} RenderTypeV: {renderType} key={materialKey}");
                    var mat = SpriteInDOTSMgr.CreateMaterial(
                        renderType == RenderType.Opaque
                            ? SpriteInDOTSMgr.DefaultOpaqueMaterialPath
                            : SpriteInDOTSMgr.DefaultTransparentMaterialPath, sprite.texture.name);
                    mat.mainTexture = sprite.texture;
                    var id = graphicsSystem.RegisterMaterial(mat);
                    spriteInDOTSSystem.MaterialMap.Add(materialKey, id);
                }


                spriteInDOTSSystem.SpriteKeyMap.Add(spriteKey, new SpriteInDOTSId()
                {
                    MaterialID = spriteInDOTSSystem.MaterialMap[materialKey],
                    MeshID = spriteInDOTSSystem.MeshID,
                    SpriteHashCode = spriteHash,
                    MaterialUvRect = sprite.UVRect(),
                    MaterialPivotAndSize = sprite.PivotAndUnitSize(),
                    MaterialBorder = sprite.border,
                    MaterialMeshWh = new float4(1, 1, sprite.pixelsPerUnit, 0)
                });
            }

            spriteHashCode = spriteHash;
            spriteKeyOpaque = SpriteInDOTSMgr.GetSpriteOrTextureKey(spriteHash, RenderType.Opaque);
            spriteKeyTransparent = SpriteInDOTSMgr.GetSpriteOrTextureKey(spriteHash, RenderType.Transparent);


            return true;
        }
    }
}