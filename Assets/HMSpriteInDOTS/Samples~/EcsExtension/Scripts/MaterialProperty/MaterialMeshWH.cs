using System;
using Unity.Mathematics;
using Unity.Rendering;

// ReSharper disable once CheckNamespace
namespace HM.HMSprite.ECS
{
    [Serializable]
    [MaterialProperty("_MeshWH")]
    public struct MaterialMeshWh: Unity.Entities.IComponentData
    {
        public float4 Value;
    }
}