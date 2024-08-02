using System;
using System.Collections.Generic;
using Unity.Entities;
using Unity.Mathematics;
using Unity.Rendering;
using UnityEngine;
using UnityEngine.Rendering;

// ReSharper disable once CheckNamespace
namespace HM.HMSprite.ECS
{
    /// <summary>
    /// 给mono访问的管理器
    /// </summary>
    public static class SpriteInDOTSMgr
    {
        public static string DefaultOpaqueMaterialPath = "HMSpriteOpaqueECS";
        public static string DefaultTransparentMaterialPath = "HMSpriteTransparentECS";
        public static World MWorld => World.DefaultGameObjectInjectionWorld;


        private static SystemHandle SpriteSystemHandle
        {
            get
            {
                if (MWorld == null || !MWorld.IsCreated)
                {
                    Debug.LogError("使用SpriteInDOTS系统的时候请先调用Init");
                    return default;
                }

                return MWorld.Unmanaged
                    .GetExistingUnmanagedSystem<HMSpriteInDOTSSystem>();
            }
        }


        private static EntitiesGraphicsSystem CurrentGraphicsSystem
        {
            get
            {
                if (MWorld == null || !MWorld.IsCreated)
                {
                    Debug.LogError("使用SpriteInDOTS系统的时候请先调用Init");
                    return default;
                }

                return MWorld
                    .GetExistingSystemManaged<EntitiesGraphicsSystem>();
            }
        }


        public static BatchMeshID MeshID
        {
            get
            {
                if (MWorld == null || !MWorld.IsCreated)
                {
                    Debug.LogError("使用SpriteInDOTS系统的时候请先调用Init");
                    return default;
                }

                BatchMeshID id = MWorld.Unmanaged.GetUnsafeSystemRef<HMSpriteInDOTSSystem>(SpriteSystemHandle).MeshID;
                if (id == BatchMeshID.Null)
                {
                    id =
                        CurrentGraphicsSystem.RegisterMesh(HMSprite.SpriteMesh);
                    MWorld.Unmanaged.GetUnsafeSystemRef<HMSpriteInDOTSSystem>(SpriteSystemHandle).MeshID = id;
                }

                return id;
            }
        }

        public static bool Init()
        {
            var id = MeshID;
            Debug.Log($"SpriteInDOTS Init id={id.value}");
            return true;
        }

        private static readonly System.Collections.Generic.Dictionary<string, Material> MaterialResMap =
            new Dictionary<string, Material>(100);

        public static Material CreateMaterial(string resPath = "HMSpriteOpaque", string materialName = "HMSpriteOpaque")
        {
            if (!MaterialResMap.TryGetValue(resPath, out var mat))
            {
                mat = Resources.Load<Material>(
                    resPath);
                MaterialResMap.Add(resPath, mat);
            }

            var material = new Material(mat)
            {
                name = materialName,
                color = Color.white
            };
            return material;
        }

        public static SpriteInDOTSId RegisterSprite(Sprite sprite, RenderType renderType)
        {
            if (MWorld == null || !MWorld.IsCreated)
            {
                Debug.LogError("使用SpriteInDOTS系统的时候请先调用Init");
                return default;
            }

            if (sprite == null) return default;
            var spriteHashCode = sprite.GetHashCode();
            var spriteKey = SpriteInDOTSMgr.GetSpriteOrTextureKey(spriteHashCode, renderType);

            var textureCode = sprite.texture.GetHashCode();
            var textureKey = SpriteInDOTSMgr.GetSpriteOrTextureKey(textureCode, renderType);

            var spriteMap = MWorld.Unmanaged.GetUnsafeSystemRef<HMSpriteInDOTSSystem>(SpriteSystemHandle).SpriteKeyMap;
            if (!spriteMap.ContainsKey(spriteKey))
            {
                var materialMap = MWorld.Unmanaged.GetUnsafeSystemRef<HMSpriteInDOTSSystem>(SpriteSystemHandle)
                    .MaterialMap;
                SpriteInDOTSId v;
                if (!materialMap.ContainsKey(textureKey))
                {
                    var mat = SpriteInDOTSMgr.CreateMaterial(
                        renderType == RenderType.Opaque ? DefaultOpaqueMaterialPath : DefaultTransparentMaterialPath,
                        sprite.texture.name);
                    mat.mainTexture = sprite.texture;
                    var id = CurrentGraphicsSystem.RegisterMaterial(mat);
                    materialMap.Add(textureKey, id);
                }

                v.SpriteHashCode = spriteHashCode;
                v.MaterialID = materialMap[textureKey];
                v.MeshID = MeshID;
                v.MaterialUvRect = sprite.UVRect();
                v.MaterialPivotAndSize = sprite.PivotAndUnitSize();
                v.MaterialBorder = sprite.border;
                v.MaterialMeshWh = new float4(1, 1, sprite.pixelsPerUnit, 0);
                spriteMap.Add(spriteKey, v);
            }

            return spriteMap[spriteKey];
        }

        /// <summary>
        /// 获取查询sprite或者texture的key
        /// </summary>
        /// <param name="spriteOrTextureHashCode"></param>
        /// <param name="renderType"></param>
        /// <returns></returns>
        public static int GetSpriteOrTextureKey(int spriteOrTextureHashCode, RenderType renderType)
        {
            return HashCode.Combine(spriteOrTextureHashCode, renderType);
        }
    }

    public struct SpriteInDOTSId : IEquatable<SpriteInDOTSId>
    {
        public static readonly SpriteInDOTSId Null = new SpriteInDOTSId()
        {
            SpriteHashCode = 0,
            MaterialID = BatchMaterialID.Null,
            MeshID = BatchMeshID.Null
        };

        public int SpriteHashCode;
        public BatchMaterialID MaterialID;
        public BatchMeshID MeshID;
        public float4 MaterialUvRect;
        public float4 MaterialPivotAndSize;
        public float4 MaterialBorder;
        public float4 MaterialMeshWh;


        public bool Equals(SpriteInDOTSId other)
        {
            return SpriteHashCode == other.SpriteHashCode && MaterialID.Equals(other.MaterialID) &&
                   MeshID.Equals(other.MeshID) && MaterialUvRect.Equals(other.MaterialUvRect) &&
                   MaterialPivotAndSize.Equals(other.MaterialPivotAndSize) &&
                   MaterialBorder.Equals(other.MaterialBorder)
                   && MaterialMeshWh.Equals(other.MaterialMeshWh);
        }

        public override bool Equals(object obj)
        {
            return obj is SpriteInDOTSId other && Equals(other);
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(SpriteHashCode, MaterialID, MeshID, MaterialUvRect, MaterialPivotAndSize,
                MaterialBorder, MaterialMeshWh);
        }
    }
}