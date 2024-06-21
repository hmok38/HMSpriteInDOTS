using System;
using Unity.Entities;
using Unity.Mathematics;
using Unity.Rendering;
using UnityEngine;

namespace HMSpriteInDOTS
{
    [Serializable]
    [MaterialProperty("_PivotAndSize")]
    public struct MaterialPivotAndSize : Unity.Entities.IComponentData
    {
        /// <summary>
        /// The RGBA color value.
        /// </summary>
        public float4 Value;
    }

    [DisallowMultipleComponent]
    public class MaterialPivotAndSizeAuthoring : UnityEngine.MonoBehaviour
    {
        public Vector4 pivotAndSize = new Vector4(0.5f, 0.5f, 1f, 1f);

        private class Baker : Baker<MaterialPivotAndSizeAuthoring>
        {
            public override void Bake(MaterialPivotAndSizeAuthoring authoring)
            {
                var entity = GetEntity(TransformUsageFlags.Renderable);
                AddComponent(entity, new MaterialPivotAndSize() { Value = authoring.pivotAndSize });
            }
        }
    }
}