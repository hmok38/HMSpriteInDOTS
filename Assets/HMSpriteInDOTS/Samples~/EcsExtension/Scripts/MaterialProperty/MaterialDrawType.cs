using System;
using Unity.Rendering;
// ReSharper disable once CheckNamespace
namespace HM.HMSprite.ECS
{
    /// <summary>
    /// 选择绘制的类型,0是Simple 1:Sliced 2:Tiled
    /// </summary>
    [Serializable]
    [MaterialProperty("_DrawType")]
    public struct MaterialDrawType: Unity.Entities.IComponentData
    {
        public float Value;
    }
}