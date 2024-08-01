using System.Collections.Generic;
using UnityEngine;

// ReSharper disable once CheckNamespace
namespace HM.HMSprite
{
    [CreateAssetMenu(fileName = "HMFrameAnimationSO", menuName = "HM/创建帧动画配置表(HMFrameAnimationSO)", order = 1)]
    public class HMFrameAnimationSO : UnityEngine.ScriptableObject
    {
        [Header("动画集")] public List<Sprite> frameAnimation;
        [Header("动画长度")] public float animationTotalTime = 1;
        [Header("是否循环")] public bool beLoop = true;
        [Header("播放速度"), Range(0, 10f)] public float animationSpeed = 1;
    }
}