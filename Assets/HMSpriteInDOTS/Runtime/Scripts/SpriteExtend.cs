using UnityEngine;

// ReSharper disable once CheckNamespace
namespace HM.HMSprite
{
    public static class SpriteExtend
    {
        public static Vector4 UVRect(this Sprite sprite)
        {
            var textWidth = sprite.texture.width;
            var textHeight = sprite.texture.height;
            var rect = sprite.textureRect;
            var uv = new Vector4(0, 0, 1, 1)
            {
                x = rect.x / textWidth,
                y = rect.y / textHeight,
                z = (rect.x + rect.width) / textWidth,
                w = (rect.y + rect.height) / textHeight
            };

            return uv;
        }

        public static Vector4 PivotAndUnitSize(this Sprite sprite)
        {
            var pu = new Vector4(0, 0, 1, 1)
            {
                x = sprite.pivot.x / sprite.rect.width,
                y = sprite.pivot.y / sprite.rect.height,
                z = sprite.textureRect.width / sprite.pixelsPerUnit,
                w = sprite.textureRect.height / sprite.pixelsPerUnit
            };
            return pu;
        }
    }
}