using System.Collections.Generic;
using Unity.Entities;
using UnityEngine;

// ReSharper disable once CheckNamespace
namespace HM.HMSprite.FrameAnimation
{
    public class FrameAnimationRegisterBakerSprite : IComponentData
    {
        public List<Sprite> Sprites;
    }
}