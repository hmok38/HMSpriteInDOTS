using Unity.Burst;
using Unity.Collections;
using Unity.Entities;
using Unity.Mathematics;
using Unity.Rendering;
using UnityEngine;
using UnityEngine.Rendering;

namespace HMSpriteInDOTS
{
    [BurstCompile][CreateAfter(typeof(EntitiesGraphicsSystem))]
    public partial struct HMSpriteInDOTSSystem : Unity.Entities.ISystem
    {
        public NativeHashMap<int, SpriteInDOTSId> SpriteMap;
        public NativeHashMap<int, BatchMaterialID> MaterialMap;
        public BatchMeshID MeshID;


        public void OnCreate(ref SystemState state)
        {
            SpriteInDOTSMgr.Init();
            SpriteMap = new NativeHashMap<int, SpriteInDOTSId>(1000, Allocator.Persistent);
            MaterialMap = new NativeHashMap<int, BatchMaterialID>(100, Allocator.Persistent);
        }

        [BurstCompile]
        public void OnUpdate(ref SystemState state)
        {
            foreach (var (spriteInDOTS, uvRectRw, pivotAndSizeRw, meshInfoRw) in SystemAPI
                         .Query<SpriteInDOTS, RefRW<MaterialUvRect>, RefRW<MaterialPivotAndSize>,
                             RefRW<MaterialMeshInfo>>().WithNone<SpriteInDOTSRegisterBakeSprite>())
            {
                if (!SpriteMap.ContainsKey(spriteInDOTS.SpriteHashCode))
                {
                    pivotAndSizeRw.ValueRW.Value = new float4(0, 0, 0, 0);
                    Debug.Log($"没有{spriteInDOTS.SpriteHashCode}  {SpriteMap.Count}");


                    continue;
                }

                var spriteInDOTSId = SpriteMap[spriteInDOTS.SpriteHashCode];
                meshInfoRw.ValueRW.MeshID = spriteInDOTSId.MeshID;
                meshInfoRw.ValueRW.MaterialID = spriteInDOTSId.MaterialID;
                uvRectRw.ValueRW.Value = spriteInDOTSId.MaterialUvRect;
                pivotAndSizeRw.ValueRW.Value = spriteInDOTSId.MaterialPivotAndSize;
            }
        }

        [BurstCompile]
        public void OnDestroy(ref SystemState state)
        {
            SpriteMap.Dispose();
            MaterialMap.Dispose();
        }
    }
}