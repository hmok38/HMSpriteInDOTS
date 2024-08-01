using UnityEditor;
using UnityEngine;

// ReSharper disable once CheckNamespace
namespace HM.HMSprite.Editor
{
    [CustomEditor(typeof(HM.HMSprite.HMSprite))]
    public class HmSpriteEditor : UnityEditor.Editor
    {
        private void OnSceneGUI()
        {
            var cs = ((HMSprite)target);
            Transform transform = cs.transform;
            MeshRenderer meshRenderer = transform.GetComponent<MeshRenderer>();
            MeshFilter meshFilter = transform.GetComponent<MeshFilter>();

            if (meshRenderer == null || meshFilter == null) return;
            meshFilter.sharedMesh.bounds = meshRenderer.localBounds;
            if (transform.hasChanged)
            {
                transform.hasChanged = false;
                cs.OnEditorCall();
            }

            // Debug.Log($"OnSceneGUI {transform.name}");
        }
    }

    // [EditorTool("Rect Tool", typeof(HM.HMSprite.HMSprite))]
    // public class HMSpriteEditorTool : EditorTool
    // {
    //     // 绘制工具的GUI
    //     public override void OnToolGUI(EditorWindow window)
    //     {
    //         Transform transform = ((HMSprite)target).transform;
    //     }
    // }
    //
}