using System.Collections.Generic;
using UnityEngine;

// ReSharper disable once CheckNamespace
namespace HM.HMSprite.FrameAnimation
{
    [CreateAssetMenu(fileName = "FrameAnimationSO", menuName = "HMFrameAnimation/FrameAnimationSO", order = 1)]
    public class FrameAnimationSO : UnityEngine.ScriptableObject
    {
        [Header("动画集")] public List<Sprite> frameAnimation;
        [Header("动画长度")] public float animationTotalTime = 1;
        [Header("是否循环")] public bool beLoop = true;
        [Header("播放速度"), Range(0, 10f)] public float animationSpeed = 1;
    }
}