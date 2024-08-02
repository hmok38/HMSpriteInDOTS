using System;
using Unity.Mathematics;
using Unity.Rendering;

// ReSharper disable once CheckNamespace
namespace HM.HMSprite.ECS
{
    /// <summary>
    /// 根据sprite属性生成的参数,不可自定义
    /// </summary>
    [Serializable]
    [MaterialProperty("_MeshWH")]
    public struct MaterialMeshWh: Unity.Entities.IComponentData
    {
        public float4 Value;
    }
}