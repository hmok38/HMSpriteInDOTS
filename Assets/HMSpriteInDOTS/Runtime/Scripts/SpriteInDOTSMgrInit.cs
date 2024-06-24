
using UnityEngine;

public class SpriteInDOTSMgrInit : MonoBehaviour
{
    private void Awake()
    {
        var assets = Resources.LoadAll<Sprite>("TestSprite");
        HMSpriteInDOTS.SpriteInDOTSMgr.Instance.RegisterSprite((Sprite)assets[^1]);
        Debug.Log("SpriteInDOTSMgrInit");
    }
}