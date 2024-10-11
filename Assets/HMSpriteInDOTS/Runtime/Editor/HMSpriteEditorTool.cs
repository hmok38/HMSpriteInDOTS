using System;
using System.Reflection;
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
            // var cs = ((HMSprite)target);
            // Transform transform = cs.transform;
            // MeshRenderer meshRenderer = transform.GetComponent<MeshRenderer>();
            // MeshFilter meshFilter = transform.GetComponent<MeshFilter>();
            //
            // if (meshRenderer == null || meshFilter == null) return;
            // meshFilter.sharedMesh.bounds = meshRenderer.localBounds;
            // if (transform.hasChanged)
            // {
            //     transform.hasChanged = false;
            //
            //     cs.OnEditorCallTransformChanged();
            // }
        }

        private Type _sortingLayerEditorUtilityType;

        private static Type GetTypeByName(string className)
        {
            // 尝试直接从当前程序集获取类型
            Type type = Type.GetType(className);
            if (type != null)
            {
                return type;
            }

            // 如果直接获取失败，则遍历所有加载的程序集
            Assembly[] assemblies = AppDomain.CurrentDomain.GetAssemblies();
            foreach (Assembly assembly in assemblies)
            {
                type = assembly.GetType(className);
                if (type != null)
                {
                    return type;
                }
            }

            // 如果仍然没有找到类型，则返回null
            return null;
        }

        private SerializedProperty m_SortingOrder;
        private SerializedProperty m_SortingLayerID;

        private void OnEnable()
        {
            var cs = ((HMSprite)target);
            this.m_SortingOrder = this.serializedObject.FindProperty("m_SortingOrder");
            this.m_SortingLayerID = this.serializedObject.FindProperty("m_SortingLayerID");
        }

        public override void OnInspectorGUI()
        {
            var cs = ((HMSprite)target);
            
            //======================sortLayer相关===============
            this.serializedObject.Update();
            if (this._sortingLayerEditorUtilityType == null)
            {
                this._sortingLayerEditorUtilityType = GetTypeByName("UnityEditor.SortingLayerEditorUtility");
            }

            var oldOrder = this.m_SortingOrder.intValue;
            var oldLayerId = this.m_SortingLayerID.intValue;

            var method = this._sortingLayerEditorUtilityType.GetMethod("RenderSortingLayerFields",
                new Type[] { typeof(SerializedProperty), typeof(SerializedProperty) });
            method.Invoke(null, new[] { this.m_SortingOrder, this.m_SortingLayerID });

            this.serializedObject.ApplyModifiedProperties();
            if (this.m_SortingOrder.intValue != oldOrder || this.m_SortingLayerID.intValue != oldLayerId)
            {
                cs.OnSortOrderChange();
            }
            //=====================================
            
            
            base.OnInspectorGUI();


            if (cs.SpriteDrawMode == SpriteDrawMode.Sliced)
            {
                EditorGUILayout.Space();
                EditorGUILayout.BeginVertical(GUI.skin.textArea);
                EditorGUILayout.LabelField("---9宫格设置----");
                EditorGUILayout.Space();
                var old = cs.SlicedWidthAndHeight;
                cs.SlicedWidthAndHeight = EditorGUILayout.Vector2Field("9宫格宽高", cs.SlicedWidthAndHeight);

                EditorGUILayout.Space();
                EditorGUILayout.EndVertical();

                if (old != cs.SlicedWidthAndHeight)
                {
                    if (!Application.isPlaying)
                    {
                        UnityEditor.EditorUtility.SetDirty(cs);
                    }
                }

                if (cs.transform.localScale != Vector3.one)
                {
                    if (GUILayout.Button("将Scale转为宽高"))
                    {
                        cs.OnRestLocalScale();
                    }
                }
            }

            if (cs.Sprite != null && GUILayout.Button("设置原始宽高"))
            {
                if (cs.SpriteDrawMode == SpriteDrawMode.Sliced)
                {
                    var size = cs.Sprite.PivotAndUnitSize();
                    cs.SlicedWidthAndHeight = new Vector2(size.z, size.w);


                    if (cs.transform.localScale != Vector3.one)
                    {
                        cs.transform.localScale = Vector3.one;
                    }

                    if (!Application.isPlaying)
                    {
                        UnityEditor.EditorUtility.SetDirty(cs);
                    }
                }
                else if (cs.SpriteDrawMode == SpriteDrawMode.Simple)
                {
                    cs.transform.localScale = Vector3.one;
                    if (!Application.isPlaying)
                    {
                        UnityEditor.EditorUtility.SetDirty(cs);
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