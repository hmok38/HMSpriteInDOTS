﻿using System.Collections.Generic;
using Unity.Entities;
using UnityEngine;

// ReSharper disable once CheckNamespace
namespace HM.HMSprite
{   
    //需要注册非runtimeMaterial的组件
    public class SpriteInDOTSRegisterBakeSprite:IComponentData
    {
        public Sprite Sprite;
    }
}