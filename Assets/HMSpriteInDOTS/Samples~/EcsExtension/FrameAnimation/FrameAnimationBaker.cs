using System.Collections.Generic;
using Unity.Entities;
using UnityEngine;

namespace HM.HMSprite.FrameAnimation
{
    public class FrameAnimationBaker : Unity.Entities.Baker<HM.HMSprite.HMFrameAnimation>
    {
        public override void Bake(HM.HMSprite.HMFrameAnimation authoring)
        {
            DependsOn(authoring.hmFrameAnimationS0);
            var entity = GetEntity(TransformUsageFlags.Renderable);
            var frameAnimation = new HMFrameAnimation()
            {
                AnimationTotalTime = 1,
                BeLoop = false,
                Timer = 0,
                AnimationSpeed = 1
            };
            if (authoring.hmFrameAnimationS0 != null)
            {
                frameAnimation.AnimationTotalTime = authoring.hmFrameAnimationS0.animationTotalTime;
                frameAnimation.BeLoop = authoring.hmFrameAnimationS0.beLoop;
                frameAnimation.AnimationSpeed = authoring.hmFrameAnimationS0.animationSpeed;
            }

            AddComponent(entity, frameAnimation);
            var buff = AddBuffer<FrameSpriteData>(entity);


            var bakeSprite = new FrameAnimationRegisterBakerSprite()
            {
                Sprites = new List<Sprite>()
            };
            if (authoring.hmFrameAnimationS0 != null)
            {
                foreach (var sprite in authoring.hmFrameAnimationS0.frameAnimation)
                {
                    bakeSprite.Sprites.Add(sprite);
                    //buff.Add(new FrameSpriteData() { SpriteHash = sprite.GetHashCode() });
                }
            }

            //Debug.Log($"FrameAnimationBaker 添加FrameAnimationRegisterBakerSprite");
            AddComponentObject(entity, bakeSprite);
        }
    }

    public struct HMFrameAnimation : Unity.Entities.IComponentData, Unity.Entities.IEnableableComponent
    {
        public float AnimationTotalTime;
        public bool BeLoop;
        public float Timer;
        public float AnimationSpeed;
    }

    [InternalBufferCapacity(50)]
    public struct FrameSpriteData : Unity.Entities.IBufferElementData
    {
        public int SpriteHash;

        /// <summary>
        /// 预先计算出来的渲染模式为 Opaque 的key
        /// </summary>
        public int SpriteKeyOpaque;

        /// <summary>
        /// 预先计算出来的渲染模式为 Transparent 的key
        /// </summary>
        public int SpriteKeyTransparent;
    }
}