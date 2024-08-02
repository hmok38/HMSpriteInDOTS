using System;
using Unity.Rendering;
// ReSharper disable once CheckNamespace
namespace HM.HMSprite.ECS
{
    [Serializable]
    [MaterialProperty("_DrawType")]
    public struct MaterialDrawType: Unity.Entities.IComponentData
    {
        public float Value;
    }
}