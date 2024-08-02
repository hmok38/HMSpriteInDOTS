using System;
using Unity.Rendering;

// ReSharper disable once CheckNamespace
namespace HM.HMSprite.ECS
{
    [Serializable]
    [MaterialProperty("_AlphaClipThreshold")]
    public struct MaterialAlphaClipThreshold : Unity.Entities.IComponentData
    {
        public float Value;
    }
}