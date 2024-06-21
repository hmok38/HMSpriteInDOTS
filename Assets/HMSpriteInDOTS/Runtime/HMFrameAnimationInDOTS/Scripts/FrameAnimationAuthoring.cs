using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using HMSpriteInDOTS;
using Unity.Entities;

namespace HM.FrameAnimation
{
    [RequireComponent(typeof(SpriteInDOTSAuthoring))]
    public class FrameAnimationAuthoring : MonoBehaviour
    {
        private SpriteInDOTSAuthoring _spriteInDOTSAuthoring;
        public FrameAnimationSO frameAnimationS0;

        [SerializeField, Range(0, 10f)] public float speed = 1;


        public float Progress
        {
            get => (_timer) / frameAnimationS0.animationTotalTime;
            set { _timer = value * frameAnimationS0.animationTotalTime; }
        }

        public int CurrentFrame
        {
            get =>
                frameAnimationS0 == null || frameAnimationS0.frameAnimation == null
                    ? -1
                    : Mathf.FloorToInt((Progress - Mathf.FloorToInt(Progress)) * frameAnimationS0.frameAnimation.Count);
            set => Progress = value / (float)frameAnimationS0.frameAnimation.Count;
        }

        private float _timer;
        public bool BePlaying { get; private set; }

        private void Awake()
        {
            _spriteInDOTSAuthoring = this.GetComponent<SpriteInDOTSAuthoring>();
        }

        private void OnValidate()
        {
            if (_spriteInDOTSAuthoring == null)
            {
                _spriteInDOTSAuthoring = this.GetComponent<SpriteInDOTSAuthoring>();
            }

            if (frameAnimationS0 != null && frameAnimationS0.frameAnimation.Count > 0)
            {
                _spriteInDOTSAuthoring.Sprite = frameAnimationS0.frameAnimation[0];
            }
        }

        private void Start()
        {
            if (frameAnimationS0 != null && frameAnimationS0.frameAnimation.Count > 0)
            {
                SetSprite(frameAnimationS0.frameAnimation[CurrentFrame]);

                if (Application.isPlaying)
                {
                    BePlaying = true;
                }
            }
        }

        public void Play(int frame = 0, bool loop = false)
        {
            CurrentFrame = frame;

            BePlaying = true;
        }

        public void Stop()
        {
            BePlaying = false;
        }


        private void Update()
        {
            if (frameAnimationS0 == null || frameAnimationS0.frameAnimation.Count == 0)
            {
                BePlaying = false;
                return;
            }

            if (!BePlaying) return;

            _timer += (Time.deltaTime * speed * frameAnimationS0.animationSpeed);
            if (_timer >= frameAnimationS0.animationTotalTime)
            {
                if (!frameAnimationS0.beLoop)
                {
                    Stop();
                    return;
                }
            }

            if (CurrentFrame >= 0)
            {
                SetSprite(frameAnimationS0.frameAnimation[CurrentFrame]);
            }
        }

        private void SetSprite(Sprite sprite)
        {
            _spriteInDOTSAuthoring.Sprite = sprite;
        }

        private class FrameAnimationBaker : Unity.Entities.Baker<FrameAnimationAuthoring>
        {
            public override void Bake(FrameAnimationAuthoring authoring)
            {
                DependsOn(authoring.frameAnimationS0);
                var entity = GetEntity(TransformUsageFlags.Renderable);
                var frameAnimation = new HMFrameAnimation()
                {
                    AnimationTotalTime = 1,
                    BeLoop = false,
                    Timer = 0,
                    AnimationSpeed = 1
                };
                if (authoring.frameAnimationS0 != null)
                {
                    frameAnimation.AnimationTotalTime = authoring.frameAnimationS0.animationTotalTime;
                    frameAnimation.BeLoop = authoring.frameAnimationS0.beLoop;
                    frameAnimation.AnimationSpeed = authoring.frameAnimationS0.animationSpeed;
                }

                AddComponent(entity, frameAnimation);
                var buff = AddBuffer<FrameSpriteData>(entity);


                var bakeSprite = new FrameAnimationRegisterBakerSprite()
                {
                    Sprites = new List<Sprite>()
                };
                if (authoring.frameAnimationS0 != null)
                {
                    foreach (var sprite in authoring.frameAnimationS0.frameAnimation)
                    {
                        bakeSprite.Sprites.Add(sprite);
                        //buff.Add(new FrameSpriteData() { SpriteHash = sprite.GetHashCode() });
                    }
                }

                Debug.Log($"FrameAnimationBaker 添加FrameAnimationRegisterBakerSprite");
                AddComponentObject(entity, bakeSprite);
            }
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
    }
}