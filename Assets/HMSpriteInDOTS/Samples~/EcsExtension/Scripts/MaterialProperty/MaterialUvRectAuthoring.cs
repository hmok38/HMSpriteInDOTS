using System;
using Unity.Entities;
using Unity.Mathematics;
using Unity.Rendering;
using UnityEngine;

// ReSharper disable once CheckNamespace
namespace HM.HMSprite.ECS
{
    /// <summary>
    /// 根据sprite属性生成的参数,不可自定义
    /// </summary>
    [Serializable]
    [MaterialProperty("_UvRect")]
    public struct MaterialUvRect : Unity.Entities.IComponentData
    {
        /// <summary>
        /// The RGBA color value.
        /// </summary>
        public float4 Value;
    }

    [DisallowMultipleComponent]
    public class MaterialUvRectAuthoring : UnityEngine.MonoBehaviour
    {
        public Vector4 uvRect=new Vector4(0,0,1,1);

        public class MaterialUvRectBaker : Baker<MaterialUvRectAuthoring>
        {
            public override void Bake(MaterialUvRectAuthoring authoring)
            {
                var entity = GetEntity(TransformUsageFlags.Renderable);
                AddComponent(entity, new MaterialUvRect() { Value = authoring.uvRect });
            }
        }
    }
}