using System;
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


        public static SpriteInDOTSId RegisterSprite(Sprite sprite)
        {
            if (MWorld == null || !MWorld.IsCreated)
            {
                Debug.LogError("使用SpriteInDOTS系统的时候请先调用Init");
                return default;
            }

            if (sprite == null) return default;
            var hashCode = sprite.GetHashCode();
            var textureCode = sprite.texture.GetHashCode();
            var spriteMap = MWorld.Unmanaged.GetUnsafeSystemRef<HMSpriteInDOTSSystem>(SpriteSystemHandle).SpriteMap;
            if (!spriteMap.ContainsKey(hashCode))
            {
                var materialMap = MWorld.Unmanaged.GetUnsafeSystemRef<HMSpriteInDOTSSystem>(SpriteSystemHandle)
                    .MaterialMap;
                SpriteInDOTSId v;
                if (!materialMap.ContainsKey(textureCode))
                {
                    var mat = HMSprite.CreateMaterial(sprite.texture.name);
                    mat.mainTexture = sprite.texture;
                    var id = CurrentGraphicsSystem.RegisterMaterial(mat);
                    materialMap.Add(textureCode, id);
                }

                v.SpriteHashCode = hashCode;
                v.MaterialID = materialMap[textureCode];
                v.MeshID = MeshID;
                v.MaterialUvRect = sprite.UVRect();
                v.MaterialPivotAndSize = sprite.PivotAndUnitSize();
                spriteMap.Add(hashCode, v);
            }

            return spriteMap[hashCode];
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

        public bool Equals(SpriteInDOTSId other)
        {
            return SpriteHashCode == other.SpriteHashCode && MaterialID.Equals(other.MaterialID) &&
                   MeshID.Equals(other.MeshID) && MaterialUvRect.Equals(other.MaterialUvRect) &&
                   MaterialPivotAndSize.Equals(other.MaterialPivotAndSize);
        }

        public override bool Equals(object obj)
        {
            return obj is SpriteInDOTSId other && Equals(other);
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(SpriteHashCode, MaterialID, MeshID, MaterialUvRect, MaterialPivotAndSize);
        }
    }
}