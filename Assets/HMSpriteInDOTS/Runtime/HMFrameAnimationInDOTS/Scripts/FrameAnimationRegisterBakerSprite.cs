using System.Collections.Generic;
using Unity.Entities;
using UnityEngine;

namespace HM.FrameAnimation
{
    public class FrameAnimationRegisterBakerSprite : IComponentData
    {
        public List<Sprite> Sprites;
    }
}