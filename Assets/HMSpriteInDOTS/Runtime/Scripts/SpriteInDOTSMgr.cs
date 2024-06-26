﻿using System;
using Unity.Entities;
using Unity.Mathematics;
using Unity.Rendering;
using UnityEngine;
using UnityEngine.Rendering;
using Object = UnityEngine.Object;

namespace HMSpriteInDOTS
{
    /// <summary>
    /// 给mono访问的管理器
    /// </summary>
    public class SpriteInDOTSMgr
    {
        public static SpriteInDOTSMgr Instance { get; private set; } = new SpriteInDOTSMgr();

        private static World MWorld => Unity.Entities.World.DefaultGameObjectInjectionWorld;

        private static SystemHandle SpriteSystemHandle =>
            MWorld.Unmanaged
                .GetExistingUnmanagedSystem<HMSpriteInDOTSSystem>();

        private EntitiesGraphicsSystem CurrentGraphicsSystem => MWorld
            .GetExistingSystemManaged<EntitiesGraphicsSystem>();


        public BatchMeshID MeshID
        {
            get
            {
                BatchMeshID id = MWorld.Unmanaged.GetUnsafeSystemRef<HMSpriteInDOTSSystem>(SpriteSystemHandle).MeshID;
                if (id == BatchMeshID.Null)
                {
                    var go = GameObject.CreatePrimitive(PrimitiveType.Quad);
                    var mesh = go.GetComponent<MeshFilter>().sharedMesh;
                    id =
                        CurrentGraphicsSystem.RegisterMesh(mesh);
                    MWorld.Unmanaged.GetUnsafeSystemRef<HMSpriteInDOTSSystem>(SpriteSystemHandle).MeshID = id;
                    Object.Destroy(go);
                }

                return id;
            }
        }

        public static Material CreateNewMaterial(string name = "HMSpriteInDOTS")
        {
            var mat = Resources.Load<Material>(
                "Shader Graphs_HMSpriteInDOTS"); ////Shader.Find("Shader Graphs/" + nameof(HMSpriteInDOTS)
            var material = new Material(mat)
            {
                name = name,
                color = Color.cyan
            };
            return material;
        }

        public SpriteInDOTSId RegisterSprite(Sprite sprite)
        {
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
                    var mat = CreateNewMaterial(sprite.texture.name);
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