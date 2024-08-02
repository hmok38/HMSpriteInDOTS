using Unity.Entities;
using Unity.Mathematics;
using UnityEngine;

// ReSharper disable once CheckNamespace
namespace HM.HMSprite.ECS
{   
    /// <summary>
    /// 需要注册非runtimeMaterial的组件--就是bake的Sprite,因为编辑器中sprite的hashCode和运行时的sprite的hashCode不同
    /// </summary>
    public class SpriteInDOTSRegisterBakeSprite:IComponentData
    {
        public Sprite Sprite;
        public RenderType RenderTypeV;
        public int DrawType;
        public float AlphaClipThreshold;
        public float2 SlicedWidthAndHeight;
    }
}