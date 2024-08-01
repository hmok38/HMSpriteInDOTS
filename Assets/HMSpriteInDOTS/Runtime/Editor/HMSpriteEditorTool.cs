using UnityEditor;

namespace HM.HMSprite.HMSpriteInDOTS.Runtime.Editor
{
    public class HMSpriteEditorTool
    {
        [UnityEditor.MenuItem("HM/HMSprite/创建帧动画配置表(HMFrameAnimationSO)")]
        public static void CreatFrameAnimationSO()
        {
            EditorUtility.DisplayDialog("如何创建动画配置表", "在Project窗口选择要放置的目录,然后右键->create->HM->创建帧动画配置表", "知道了");
        }
    }
}