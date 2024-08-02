using System;
using Unity.Burst;
using Unity.Collections;
using Unity.Entities;
using Unity.Mathematics;
using Unity.Rendering;
using UnityEngine;
using UnityEngine.Rendering;

// ReSharper disable once CheckNamespace
namespace HM.HMSprite.ECS
{
    [BurstCompile]
    [CreateAfter(typeof(EntitiesGraphicsSystem))]
    public partial struct HMSpriteInDOTSSystem : Unity.Entities.ISystem
    {
        /// <summary>
        /// 使用sprite的hashcode和renderType拼接的 hashCode作为key的map,可以找到使用指定渲染方式(非透明或者半透)的sprite的id,
        /// </summary>
        public NativeHashMap<int, SpriteInDOTSId> SpriteKeyMap;

        /// <summary>
        /// 使用texture的hashcode和renderType拼接的 hashCode作为key的map,可以找到使用指定渲染方式(非透明或者半透)的 material的id,
        /// </summary>
        public NativeHashMap<int, BatchMaterialID> MaterialMap;

        public BatchMeshID MeshID;


        public void OnCreate(ref SystemState state)
        {
            SpriteInDOTSMgr.Init();
            SpriteKeyMap = new NativeHashMap<int, SpriteInDOTSId>(1000, Allocator.Persistent);
            MaterialMap = new NativeHashMap<int, BatchMaterialID>(100, Allocator.Persistent);
        }

        [BurstCompile]
        public void OnUpdate(ref SystemState state)
        {
            foreach (var (spriteInDOTS, uvRectRw, pivotAndSizeRw, meshInfoRw, materialBorder, meshWh) in SystemAPI
                         .Query<SpriteInDOTS, RefRW<MaterialUvRect>, RefRW<MaterialPivotAndSize>,
                             RefRW<MaterialMeshInfo>, RefRW<MaterialBorder>, RefRW<MaterialMeshWh>>()
                         .WithNone<SpriteInDOTSRegisterBakeSprite>())
            {
                var key = spriteInDOTS.GetSpriteKey();
                if (!SpriteKeyMap.ContainsKey(key))
                {
                    pivotAndSizeRw.ValueRW.Value = new float4(0, 0, 0, 0);
                    Debug.Log($"没有{spriteInDOTS.SpriteHashCode}  {SpriteKeyMap.Count}  {spriteInDOTS.GetSpriteKey()}");
                    continue;
                }

                var spriteInDOTSId = SpriteKeyMap[key];
                meshInfoRw.ValueRW.MeshID = spriteInDOTSId.MeshID;
                meshInfoRw.ValueRW.MaterialID = spriteInDOTSId.MaterialID;
                uvRectRw.ValueRW.Value = spriteInDOTSId.MaterialUvRect;
                pivotAndSizeRw.ValueRW.Value = spriteInDOTSId.MaterialPivotAndSize;
                materialBorder.ValueRW.Value = spriteInDOTSId.MaterialBorder;
                meshWh.ValueRW.Value = spriteInDOTSId.MaterialMeshWh;
            }
        }

        [BurstCompile]
        public void OnDestroy(ref SystemState state)
        {
            SpriteKeyMap.Dispose();
            MaterialMap.Dispose();
        }
    }
    
}