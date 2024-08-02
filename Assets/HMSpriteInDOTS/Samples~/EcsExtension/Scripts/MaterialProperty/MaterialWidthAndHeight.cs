using System;
using Unity.Mathematics;
using Unity.Rendering;

// ReSharper disable once CheckNamespace
namespace HM.HMSprite.ECS
{
    [Serializable]
    [MaterialProperty("_WidthAndHeight")]
    public struct MaterialWidthAndHeight : Unity.Entities.IComponentData
    {
        public float2 Value;
    }
}