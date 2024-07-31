using Unity.Burst;
using Unity.Entities;
using Unity.Mathematics;
using Unity.Rendering;
using UnityEngine;

// ReSharper disable once CheckNamespace
namespace HM.HMSprite.FrameAnimation
{
    [BurstCompile]
    public partial struct HMFrameAnimationSystem : Unity.Entities.ISystem
    {
        [BurstCompile]
        public void OnCreate(ref SystemState state)
        {
            state.RequireForUpdate<HMFrameAnimation>();
        }

        [BurstCompile]
        public void OnUpdate(ref SystemState state)
        {
            var job = new HMFrameAnimationJob() { DeltaTime = Time.deltaTime };
            job.ScheduleParallel();
        }
    }

    [BurstCompile]
    public partial struct HMFrameAnimationJob : IJobEntity
    {
        public float DeltaTime;

        [BurstCompile]
        void Execute(ref HMFrameAnimation frameAnimation, ref SpriteInDOTS spriteInDOTS,
            in DynamicBuffer<FrameSpriteData> buffer, in MaterialMeshInfo meshInfo)
        {
            if (buffer.Length <= 0) return;
            frameAnimation.Timer += DeltaTime * frameAnimation.AnimationSpeed;

            float progress = (frameAnimation.Timer) / frameAnimation.AnimationTotalTime;
            var index = (int)math.floor((progress - Unity.Mathematics.math.floor(progress)) * buffer.Length);
            spriteInDOTS.SpriteHashCode = buffer[index].SpriteHash;
        }
    }
}