using Unity.Mathematics;

// ReSharper disable once CheckNamespace
namespace HM.HMSprite.ECS
{
    public struct SpriteInDOTS : Unity.Entities.IComponentData
    {
        public int SpriteHashCode;
        public RenderType RenderTypeV;

        /// <summary>
        /// 预先计算出来的渲染模式为 Opaque 的key
        /// </summary>
        public int SpriteKeyOpaque;

        /// <summary>
        /// 预先计算出来的渲染模式为 Transparent 的key
        /// </summary>
        public int SpriteKeyTransparent;

        public int DrawType;
        public float AlphaClipThreshold;
        public float2 SlicedWidthAndHeight;
    }

    public static class SpriteInDOTSExtension
    {
        public static int GetSpriteKey(this SpriteInDOTS spriteInDOTS)
        {
            return spriteInDOTS.RenderTypeV == RenderType.Opaque
                ? spriteInDOTS.SpriteKeyOpaque
                : spriteInDOTS.SpriteKeyTransparent;
        }
    }
}