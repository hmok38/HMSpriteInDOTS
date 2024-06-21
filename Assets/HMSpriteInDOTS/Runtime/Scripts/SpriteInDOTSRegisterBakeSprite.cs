using System.Collections.Generic;
using Unity.Entities;
using UnityEngine;

namespace HMSpriteInDOTS
{   
    //需要注册非runtimeMaterial的组件
    public class SpriteInDOTSRegisterBakeSprite:IComponentData
    {
        public Sprite Sprite;
    }
}