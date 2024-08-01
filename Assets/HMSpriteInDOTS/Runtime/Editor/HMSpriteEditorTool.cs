using System;
using UnityEditor;
using UnityEditor.EditorTools;
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

                cs.OnEditorCallTransformChanged();
            }
        }

        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            var cs = ((HMSprite)target);
            if (cs.spriteDrawMode == SpriteDrawMode.Sliced)
            {
                EditorGUILayout.Space();
                EditorGUILayout.BeginVertical(GUI.skin.textArea);
                EditorGUILayout.LabelField("---9宫格设置----");
                EditorGUILayout.Space();
                var old = cs.slicedWidthAndHeight;
                cs.slicedWidthAndHeight = EditorGUILayout.Vector2Field("9宫格宽高", cs.slicedWidthAndHeight);

                EditorGUILayout.Space();
                EditorGUILayout.EndVertical();

                if (old != cs.slicedWidthAndHeight)
                {
                    cs.OnValidate();
                }

                if (cs.transform.localScale != Vector3.one)
                {
                    if (GUILayout.Button("将Scale转为宽高"))
                    {
                        cs.OnRestLocalScale();
                    }
                }
            }
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