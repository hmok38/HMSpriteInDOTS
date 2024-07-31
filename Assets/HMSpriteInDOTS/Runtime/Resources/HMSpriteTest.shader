Shader "Shader Graphs/HMSpriteTest"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 0)
        [NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
        _UvRect("UvRect", Vector) = (0, 0, 1, 1)
        _PivotAndSize("PivotAndSize", Vector) = (0.5, 0.5, 1, 1)
        _MeshWH("MeshWH", Vector) = (1, 1, 100, 0.5)
        _Border("Border", Vector) = (0, 0, 0, 0)
        _DrawType("DrawType", Float) = 0
        _WidthAndHeight("WidthAndHeight", Vector) = (1, 1, 0, 0)
        [HideInInspector]_CastShadows("_CastShadows", Float) = 0
        [HideInInspector]_Surface("_Surface", Float) = 0
        [HideInInspector]_Blend("_Blend", Float) = 0
        [HideInInspector]_AlphaClip("_AlphaClip", Float) = 1
        [HideInInspector]_SrcBlend("_SrcBlend", Float) = 1
        [HideInInspector]_DstBlend("_DstBlend", Float) = 0
        [HideInInspector][ToggleUI]_ZWrite("_ZWrite", Float) = 1
        [HideInInspector]_ZWriteControl("_ZWriteControl", Float) = 1
        [HideInInspector]_ZTest("_ZTest", Float) = 4
        [HideInInspector]_Cull("_Cull", Float) = 2
        [HideInInspector]_AlphaToMask("_AlphaToMask", Float) = 1
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Unlit"
            "Queue"="AlphaTest"
            "DisableBatching"="LODFading"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalUnlitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                // LightMode: <None>
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        AlphaToMask [_AlphaToMask]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma multi_compile _ LOD_FADE_CROSSFADE
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define _FOG_FRAGMENT 1
        #define USE_UNITY_CROSSFADE 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
             float3 normalWS : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _MainTex_TexelSize;
        float4 _UvRect;
        float4 _PivotAndSize;
        float4 _MeshWH;
        float4 _Border;
        float _DrawType;
        float2 _WidthAndHeight;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void GetPosition_float(float3 positionOS, float4 MeshWH, float4 PivotAndSize, float2 WidthAndHeight, float DrawType, out float3 outPosition){
            outPosition=positionOS;
            if(abs(DrawType-0)<=0.01)
            {
            	outPosition.x=positionOS.x+0.5*MeshWH.x;
            	outPosition.y=positionOS.y+0.5*MeshWH.y;
            	outPosition.x-=PivotAndSize.x*MeshWH.x;
            	outPosition.y-=PivotAndSize.y*MeshWH.y;
            	outPosition.x*=PivotAndSize.z;
            	outPosition.y*=PivotAndSize.w;
            }
            else if(abs(DrawType-1)<=0.01)
            {
            	outPosition.x=positionOS.x+0.5*MeshWH.x;
            	outPosition.y=positionOS.y+0.5*MeshWH.y;
            	outPosition.x-=PivotAndSize.x*MeshWH.x;
            	outPosition.y-=PivotAndSize.y*MeshWH.y;
            	outPosition.x*=WidthAndHeight.x;
            	outPosition.y*=WidthAndHeight.y;
            }
        }
        
        void DrawTypeUV_float(float DrawType, float4 InputUV, float4 PivotAndSize, float2 WidthAndHeight, float4 Border, float PixelsPerUnit, out float4 UVOut){
            UVOut = InputUV;
            
                            if (abs(DrawType - 0) < 0.01)return;
            
                            if (abs(DrawType - 1) < 0.01)
            
                            {
            
                                float finalWidth = WidthAndHeight.x * PixelsPerUnit; //最终宽度(实际宽度)
            
                                float finalHeight = WidthAndHeight.y * PixelsPerUnit; //最终高度(实际高度)
            
                                float texSizeWidth = PivotAndSize.z * PixelsPerUnit; //贴图宽度
            
                                float texSizeHeight = PivotAndSize.w * PixelsPerUnit; //贴图高度
            
            
            
                                float min_x_width = Border.x; //9宫格左边的x轴宽度
            
                                float min_x_value = min_x_width; //9宫格左边的x轴值
            
                                float max_x_width = Border.z; //9宫格右边线到最后的x轴宽度
            
                                float max_x_value = finalWidth - max_x_width; //9宫格右边线的x轴值
            
            
            
                                float min_y_height = Border.y; //9宫格下边的y轴高度--bottom
            
                                float min_y_value = min_y_height; //9宫格下边的y轴值
            
                                float max_y_height = Border.w; //9宫格上边的y轴高度--top
            
                                float max_y_value = finalHeight - max_y_height; //9宫格上边的y轴值(最下边到这条线的高度)
            
                                if (min_x_width + max_x_width > finalWidth)
            
                                {
            
                                    float sum = min_x_width + max_x_width;
            
                                    min_x_width = min_x_width / sum * finalWidth;
            
                                    min_x_value = min_x_width;
            
                                    max_x_width = finalWidth - min_x_width;
            
                                    max_x_value = finalWidth - max_x_width;
            
                                }
            
            
            
                                if (min_y_height + max_y_height > finalHeight)
            
                                {
            
                                    float sum = min_y_height + max_y_height;
            
                                    min_y_height = min_y_height / sum * finalHeight;
            
                                    min_y_value = min_y_height;
            
                                    max_y_height = finalHeight - min_y_height;
            
                                    max_y_value = finalHeight - max_y_height;
            
                                }
            
                                float x = InputUV.x * finalWidth;
            
                                float y = InputUV.y * finalHeight;
            
                                if (x <= min_x_value)
            
                                {
            
                                    UVOut.x *= finalWidth / texSizeWidth;
            
                                }
            
                                else if (x >= max_x_value)
            
                                {
            
                                    UVOut.x = 1 - ((1 - UVOut.x) * (finalWidth / texSizeWidth));
            
                                }
            
                                else
            
                                {
            
                                    float min_rate_x = min_x_value / texSizeWidth;
            
                                    float max_rate_x = (texSizeWidth - max_x_width) / texSizeWidth;
            
                                    float borderWidth = max_x_value - min_x_value;
            
                                    float xCha = x - min_x_value;
            
                                    float rate = xCha / borderWidth;
            
                                    UVOut.x = (max_rate_x - min_rate_x) * rate + min_rate_x;
            
                                }
            
            
            
                                if (y <= min_y_value)
            
                                {
            
                                    UVOut.y *= finalHeight / texSizeHeight;
            
                                }
            
                                else if (y >= max_y_value)
            
                                {
            
                                    UVOut.y = 1 - ((1 - UVOut.y) * (finalHeight / texSizeHeight));
            
                                }
            
                                else
            
                                {
            
                                    float min_rate_y = min_y_value / texSizeHeight;
            
                                    float max_rate_y = (texSizeHeight - max_y_height) / texSizeHeight;
            
                                    float border_height = max_y_value - min_y_value;
            
                                    float y_cha = y - min_y_value;
            
                                    float rate = y_cha / border_height;
            
                                    UVOut.y = (max_rate_y - min_rate_y) * rate + min_rate_y;
            
                                }
            
                            }
        }
        
        void GetUv_float(float4 _UvRect, float2 uvTemp, out float2 _out){
            _out=_UvRect.xy;
            
            _out.x=uvTemp.x * (_UvRect.z - _UvRect.x) + _UvRect.x;
            _out.y=uvTemp.y * (_UvRect.w - _UvRect.y) + _UvRect.y;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float4 _Property_2c211408dc3b437ab6f31899b8953b97_Out_0_Vector4 = _MeshWH;
            float4 _Property_1434c3f966ff459a960d8365ca5b6e33_Out_0_Vector4 = _PivotAndSize;
            float2 _Property_c6a9a778594b42d3a377e98c496d93c1_Out_0_Vector2 = _WidthAndHeight;
            float _Property_00c5f1e862f04770a75337e4dfb72e8d_Out_0_Float = _DrawType;
            float3 _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3;
            GetPosition_float(IN.ObjectSpacePosition, _Property_2c211408dc3b437ab6f31899b8953b97_Out_0_Vector4, _Property_1434c3f966ff459a960d8365ca5b6e33_Out_0_Vector4, _Property_c6a9a778594b42d3a377e98c496d93c1_Out_0_Vector2, _Property_00c5f1e862f04770a75337e4dfb72e8d_Out_0_Float, _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3);
            description.Position = _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_3056f453a9074d778c4583019576b46f_Out_0_Vector4 = _Color;
            UnityTexture2D _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _Property_691fe2672c4e427e81bf1480bdd91a73_Out_0_Vector4 = _UvRect;
            float _Property_bae20385e6f845c4b611e48bc7744935_Out_0_Float = _DrawType;
            float4 _UV_9fa10a2b0f354fdf8a75654d82e2e719_Out_0_Vector4 = IN.uv0;
            float4 _Property_874c47cfc09e4c7bad1707edba3cf783_Out_0_Vector4 = _PivotAndSize;
            float2 _Property_528dc8a2cbca45a9b6ec87f95cbf90b8_Out_0_Vector2 = _WidthAndHeight;
            float4 _Property_bb379e706808487f9c2e7c8358feca98_Out_0_Vector4 = _Border;
            float4 _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4 = _MeshWH;
            float _Split_f4276b026ecb4c69866ab3d1840e320d_R_1_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[0];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_G_2_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[1];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_B_3_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[2];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_A_4_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[3];
            float4 _DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4;
            DrawTypeUV_float(_Property_bae20385e6f845c4b611e48bc7744935_Out_0_Float, _UV_9fa10a2b0f354fdf8a75654d82e2e719_Out_0_Vector4, _Property_874c47cfc09e4c7bad1707edba3cf783_Out_0_Vector4, _Property_528dc8a2cbca45a9b6ec87f95cbf90b8_Out_0_Vector2, _Property_bb379e706808487f9c2e7c8358feca98_Out_0_Vector4, _Split_f4276b026ecb4c69866ab3d1840e320d_B_3_Float, _DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4);
            float2 _GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2;
            GetUv_float(_Property_691fe2672c4e427e81bf1480bdd91a73_Out_0_Vector4, (_DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4.xy), _GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2);
            float4 _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.tex, _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.samplerstate, _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.GetTransformedUV(_GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2) );
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_R_4_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.r;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_G_5_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.g;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_B_6_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.b;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_A_7_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.a;
            float4 _Multiply_8baa08899cee4bc8b97bf35d9e397bb4_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_3056f453a9074d778c4583019576b46f_Out_0_Vector4, _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4, _Multiply_8baa08899cee4bc8b97bf35d9e397bb4_Out_2_Vector4);
            surface.BaseColor = (_Multiply_8baa08899cee4bc8b97bf35d9e397bb4_Out_2_Vector4.xyz);
            surface.Alpha = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_A_7_Float;
            surface.AlphaClipThreshold = _Split_f4276b026ecb4c69866ab3d1840e320d_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask R
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma multi_compile _ LOD_FADE_CROSSFADE
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define USE_UNITY_CROSSFADE 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _MainTex_TexelSize;
        float4 _UvRect;
        float4 _PivotAndSize;
        float4 _MeshWH;
        float4 _Border;
        float _DrawType;
        float2 _WidthAndHeight;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void GetPosition_float(float3 positionOS, float4 MeshWH, float4 PivotAndSize, float2 WidthAndHeight, float DrawType, out float3 outPosition){
            outPosition=positionOS;
            if(abs(DrawType-0)<=0.01)
            {
            	outPosition.x=positionOS.x+0.5*MeshWH.x;
            	outPosition.y=positionOS.y+0.5*MeshWH.y;
            	outPosition.x-=PivotAndSize.x*MeshWH.x;
            	outPosition.y-=PivotAndSize.y*MeshWH.y;
            	outPosition.x*=PivotAndSize.z;
            	outPosition.y*=PivotAndSize.w;
            }
            else if(abs(DrawType-1)<=0.01)
            {
            	outPosition.x=positionOS.x+0.5*MeshWH.x;
            	outPosition.y=positionOS.y+0.5*MeshWH.y;
            	outPosition.x-=PivotAndSize.x*MeshWH.x;
            	outPosition.y-=PivotAndSize.y*MeshWH.y;
            	outPosition.x*=WidthAndHeight.x;
            	outPosition.y*=WidthAndHeight.y;
            }
        }
        
        void DrawTypeUV_float(float DrawType, float4 InputUV, float4 PivotAndSize, float2 WidthAndHeight, float4 Border, float PixelsPerUnit, out float4 UVOut){
            UVOut = InputUV;
            
                            if (abs(DrawType - 0) < 0.01)return;
            
                            if (abs(DrawType - 1) < 0.01)
            
                            {
            
                                float finalWidth = WidthAndHeight.x * PixelsPerUnit; //最终宽度(实际宽度)
            
                                float finalHeight = WidthAndHeight.y * PixelsPerUnit; //最终高度(实际高度)
            
                                float texSizeWidth = PivotAndSize.z * PixelsPerUnit; //贴图宽度
            
                                float texSizeHeight = PivotAndSize.w * PixelsPerUnit; //贴图高度
            
            
            
                                float min_x_width = Border.x; //9宫格左边的x轴宽度
            
                                float min_x_value = min_x_width; //9宫格左边的x轴值
            
                                float max_x_width = Border.z; //9宫格右边线到最后的x轴宽度
            
                                float max_x_value = finalWidth - max_x_width; //9宫格右边线的x轴值
            
            
            
                                float min_y_height = Border.y; //9宫格下边的y轴高度--bottom
            
                                float min_y_value = min_y_height; //9宫格下边的y轴值
            
                                float max_y_height = Border.w; //9宫格上边的y轴高度--top
            
                                float max_y_value = finalHeight - max_y_height; //9宫格上边的y轴值(最下边到这条线的高度)
            
                                if (min_x_width + max_x_width > finalWidth)
            
                                {
            
                                    float sum = min_x_width + max_x_width;
            
                                    min_x_width = min_x_width / sum * finalWidth;
            
                                    min_x_value = min_x_width;
            
                                    max_x_width = finalWidth - min_x_width;
            
                                    max_x_value = finalWidth - max_x_width;
            
                                }
            
            
            
                                if (min_y_height + max_y_height > finalHeight)
            
                                {
            
                                    float sum = min_y_height + max_y_height;
            
                                    min_y_height = min_y_height / sum * finalHeight;
            
                                    min_y_value = min_y_height;
            
                                    max_y_height = finalHeight - min_y_height;
            
                                    max_y_value = finalHeight - max_y_height;
            
                                }
            
                                float x = InputUV.x * finalWidth;
            
                                float y = InputUV.y * finalHeight;
            
                                if (x <= min_x_value)
            
                                {
            
                                    UVOut.x *= finalWidth / texSizeWidth;
            
                                }
            
                                else if (x >= max_x_value)
            
                                {
            
                                    UVOut.x = 1 - ((1 - UVOut.x) * (finalWidth / texSizeWidth));
            
                                }
            
                                else
            
                                {
            
                                    float min_rate_x = min_x_value / texSizeWidth;
            
                                    float max_rate_x = (texSizeWidth - max_x_width) / texSizeWidth;
            
                                    float borderWidth = max_x_value - min_x_value;
            
                                    float xCha = x - min_x_value;
            
                                    float rate = xCha / borderWidth;
            
                                    UVOut.x = (max_rate_x - min_rate_x) * rate + min_rate_x;
            
                                }
            
            
            
                                if (y <= min_y_value)
            
                                {
            
                                    UVOut.y *= finalHeight / texSizeHeight;
            
                                }
            
                                else if (y >= max_y_value)
            
                                {
            
                                    UVOut.y = 1 - ((1 - UVOut.y) * (finalHeight / texSizeHeight));
            
                                }
            
                                else
            
                                {
            
                                    float min_rate_y = min_y_value / texSizeHeight;
            
                                    float max_rate_y = (texSizeHeight - max_y_height) / texSizeHeight;
            
                                    float border_height = max_y_value - min_y_value;
            
                                    float y_cha = y - min_y_value;
            
                                    float rate = y_cha / border_height;
            
                                    UVOut.y = (max_rate_y - min_rate_y) * rate + min_rate_y;
            
                                }
            
                            }
        }
        
        void GetUv_float(float4 _UvRect, float2 uvTemp, out float2 _out){
            _out=_UvRect.xy;
            
            _out.x=uvTemp.x * (_UvRect.z - _UvRect.x) + _UvRect.x;
            _out.y=uvTemp.y * (_UvRect.w - _UvRect.y) + _UvRect.y;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float4 _Property_2c211408dc3b437ab6f31899b8953b97_Out_0_Vector4 = _MeshWH;
            float4 _Property_1434c3f966ff459a960d8365ca5b6e33_Out_0_Vector4 = _PivotAndSize;
            float2 _Property_c6a9a778594b42d3a377e98c496d93c1_Out_0_Vector2 = _WidthAndHeight;
            float _Property_00c5f1e862f04770a75337e4dfb72e8d_Out_0_Float = _DrawType;
            float3 _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3;
            GetPosition_float(IN.ObjectSpacePosition, _Property_2c211408dc3b437ab6f31899b8953b97_Out_0_Vector4, _Property_1434c3f966ff459a960d8365ca5b6e33_Out_0_Vector4, _Property_c6a9a778594b42d3a377e98c496d93c1_Out_0_Vector2, _Property_00c5f1e862f04770a75337e4dfb72e8d_Out_0_Float, _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3);
            description.Position = _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _Property_691fe2672c4e427e81bf1480bdd91a73_Out_0_Vector4 = _UvRect;
            float _Property_bae20385e6f845c4b611e48bc7744935_Out_0_Float = _DrawType;
            float4 _UV_9fa10a2b0f354fdf8a75654d82e2e719_Out_0_Vector4 = IN.uv0;
            float4 _Property_874c47cfc09e4c7bad1707edba3cf783_Out_0_Vector4 = _PivotAndSize;
            float2 _Property_528dc8a2cbca45a9b6ec87f95cbf90b8_Out_0_Vector2 = _WidthAndHeight;
            float4 _Property_bb379e706808487f9c2e7c8358feca98_Out_0_Vector4 = _Border;
            float4 _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4 = _MeshWH;
            float _Split_f4276b026ecb4c69866ab3d1840e320d_R_1_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[0];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_G_2_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[1];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_B_3_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[2];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_A_4_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[3];
            float4 _DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4;
            DrawTypeUV_float(_Property_bae20385e6f845c4b611e48bc7744935_Out_0_Float, _UV_9fa10a2b0f354fdf8a75654d82e2e719_Out_0_Vector4, _Property_874c47cfc09e4c7bad1707edba3cf783_Out_0_Vector4, _Property_528dc8a2cbca45a9b6ec87f95cbf90b8_Out_0_Vector2, _Property_bb379e706808487f9c2e7c8358feca98_Out_0_Vector4, _Split_f4276b026ecb4c69866ab3d1840e320d_B_3_Float, _DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4);
            float2 _GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2;
            GetUv_float(_Property_691fe2672c4e427e81bf1480bdd91a73_Out_0_Vector4, (_DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4.xy), _GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2);
            float4 _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.tex, _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.samplerstate, _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.GetTransformedUV(_GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2) );
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_R_4_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.r;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_G_5_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.g;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_B_6_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.b;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_A_7_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.a;
            surface.Alpha = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_A_7_Float;
            surface.AlphaClipThreshold = _Split_f4276b026ecb4c69866ab3d1840e320d_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormalsOnly"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma multi_compile _ LOD_FADE_CROSSFADE
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define USE_UNITY_CROSSFADE 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _MainTex_TexelSize;
        float4 _UvRect;
        float4 _PivotAndSize;
        float4 _MeshWH;
        float4 _Border;
        float _DrawType;
        float2 _WidthAndHeight;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void GetPosition_float(float3 positionOS, float4 MeshWH, float4 PivotAndSize, float2 WidthAndHeight, float DrawType, out float3 outPosition){
            outPosition=positionOS;
            if(abs(DrawType-0)<=0.01)
            {
            	outPosition.x=positionOS.x+0.5*MeshWH.x;
            	outPosition.y=positionOS.y+0.5*MeshWH.y;
            	outPosition.x-=PivotAndSize.x*MeshWH.x;
            	outPosition.y-=PivotAndSize.y*MeshWH.y;
            	outPosition.x*=PivotAndSize.z;
            	outPosition.y*=PivotAndSize.w;
            }
            else if(abs(DrawType-1)<=0.01)
            {
            	outPosition.x=positionOS.x+0.5*MeshWH.x;
            	outPosition.y=positionOS.y+0.5*MeshWH.y;
            	outPosition.x-=PivotAndSize.x*MeshWH.x;
            	outPosition.y-=PivotAndSize.y*MeshWH.y;
            	outPosition.x*=WidthAndHeight.x;
            	outPosition.y*=WidthAndHeight.y;
            }
        }
        
        void DrawTypeUV_float(float DrawType, float4 InputUV, float4 PivotAndSize, float2 WidthAndHeight, float4 Border, float PixelsPerUnit, out float4 UVOut){
            UVOut = InputUV;
            
                            if (abs(DrawType - 0) < 0.01)return;
            
                            if (abs(DrawType - 1) < 0.01)
            
                            {
            
                                float finalWidth = WidthAndHeight.x * PixelsPerUnit; //最终宽度(实际宽度)
            
                                float finalHeight = WidthAndHeight.y * PixelsPerUnit; //最终高度(实际高度)
            
                                float texSizeWidth = PivotAndSize.z * PixelsPerUnit; //贴图宽度
            
                                float texSizeHeight = PivotAndSize.w * PixelsPerUnit; //贴图高度
            
            
            
                                float min_x_width = Border.x; //9宫格左边的x轴宽度
            
                                float min_x_value = min_x_width; //9宫格左边的x轴值
            
                                float max_x_width = Border.z; //9宫格右边线到最后的x轴宽度
            
                                float max_x_value = finalWidth - max_x_width; //9宫格右边线的x轴值
            
            
            
                                float min_y_height = Border.y; //9宫格下边的y轴高度--bottom
            
                                float min_y_value = min_y_height; //9宫格下边的y轴值
            
                                float max_y_height = Border.w; //9宫格上边的y轴高度--top
            
                                float max_y_value = finalHeight - max_y_height; //9宫格上边的y轴值(最下边到这条线的高度)
            
                                if (min_x_width + max_x_width > finalWidth)
            
                                {
            
                                    float sum = min_x_width + max_x_width;
            
                                    min_x_width = min_x_width / sum * finalWidth;
            
                                    min_x_value = min_x_width;
            
                                    max_x_width = finalWidth - min_x_width;
            
                                    max_x_value = finalWidth - max_x_width;
            
                                }
            
            
            
                                if (min_y_height + max_y_height > finalHeight)
            
                                {
            
                                    float sum = min_y_height + max_y_height;
            
                                    min_y_height = min_y_height / sum * finalHeight;
            
                                    min_y_value = min_y_height;
            
                                    max_y_height = finalHeight - min_y_height;
            
                                    max_y_value = finalHeight - max_y_height;
            
                                }
            
                                float x = InputUV.x * finalWidth;
            
                                float y = InputUV.y * finalHeight;
            
                                if (x <= min_x_value)
            
                                {
            
                                    UVOut.x *= finalWidth / texSizeWidth;
            
                                }
            
                                else if (x >= max_x_value)
            
                                {
            
                                    UVOut.x = 1 - ((1 - UVOut.x) * (finalWidth / texSizeWidth));
            
                                }
            
                                else
            
                                {
            
                                    float min_rate_x = min_x_value / texSizeWidth;
            
                                    float max_rate_x = (texSizeWidth - max_x_width) / texSizeWidth;
            
                                    float borderWidth = max_x_value - min_x_value;
            
                                    float xCha = x - min_x_value;
            
                                    float rate = xCha / borderWidth;
            
                                    UVOut.x = (max_rate_x - min_rate_x) * rate + min_rate_x;
            
                                }
            
            
            
                                if (y <= min_y_value)
            
                                {
            
                                    UVOut.y *= finalHeight / texSizeHeight;
            
                                }
            
                                else if (y >= max_y_value)
            
                                {
            
                                    UVOut.y = 1 - ((1 - UVOut.y) * (finalHeight / texSizeHeight));
            
                                }
            
                                else
            
                                {
            
                                    float min_rate_y = min_y_value / texSizeHeight;
            
                                    float max_rate_y = (texSizeHeight - max_y_height) / texSizeHeight;
            
                                    float border_height = max_y_value - min_y_value;
            
                                    float y_cha = y - min_y_value;
            
                                    float rate = y_cha / border_height;
            
                                    UVOut.y = (max_rate_y - min_rate_y) * rate + min_rate_y;
            
                                }
            
                            }
        }
        
        void GetUv_float(float4 _UvRect, float2 uvTemp, out float2 _out){
            _out=_UvRect.xy;
            
            _out.x=uvTemp.x * (_UvRect.z - _UvRect.x) + _UvRect.x;
            _out.y=uvTemp.y * (_UvRect.w - _UvRect.y) + _UvRect.y;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float4 _Property_2c211408dc3b437ab6f31899b8953b97_Out_0_Vector4 = _MeshWH;
            float4 _Property_1434c3f966ff459a960d8365ca5b6e33_Out_0_Vector4 = _PivotAndSize;
            float2 _Property_c6a9a778594b42d3a377e98c496d93c1_Out_0_Vector2 = _WidthAndHeight;
            float _Property_00c5f1e862f04770a75337e4dfb72e8d_Out_0_Float = _DrawType;
            float3 _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3;
            GetPosition_float(IN.ObjectSpacePosition, _Property_2c211408dc3b437ab6f31899b8953b97_Out_0_Vector4, _Property_1434c3f966ff459a960d8365ca5b6e33_Out_0_Vector4, _Property_c6a9a778594b42d3a377e98c496d93c1_Out_0_Vector2, _Property_00c5f1e862f04770a75337e4dfb72e8d_Out_0_Float, _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3);
            description.Position = _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _Property_691fe2672c4e427e81bf1480bdd91a73_Out_0_Vector4 = _UvRect;
            float _Property_bae20385e6f845c4b611e48bc7744935_Out_0_Float = _DrawType;
            float4 _UV_9fa10a2b0f354fdf8a75654d82e2e719_Out_0_Vector4 = IN.uv0;
            float4 _Property_874c47cfc09e4c7bad1707edba3cf783_Out_0_Vector4 = _PivotAndSize;
            float2 _Property_528dc8a2cbca45a9b6ec87f95cbf90b8_Out_0_Vector2 = _WidthAndHeight;
            float4 _Property_bb379e706808487f9c2e7c8358feca98_Out_0_Vector4 = _Border;
            float4 _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4 = _MeshWH;
            float _Split_f4276b026ecb4c69866ab3d1840e320d_R_1_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[0];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_G_2_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[1];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_B_3_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[2];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_A_4_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[3];
            float4 _DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4;
            DrawTypeUV_float(_Property_bae20385e6f845c4b611e48bc7744935_Out_0_Float, _UV_9fa10a2b0f354fdf8a75654d82e2e719_Out_0_Vector4, _Property_874c47cfc09e4c7bad1707edba3cf783_Out_0_Vector4, _Property_528dc8a2cbca45a9b6ec87f95cbf90b8_Out_0_Vector2, _Property_bb379e706808487f9c2e7c8358feca98_Out_0_Vector4, _Split_f4276b026ecb4c69866ab3d1840e320d_B_3_Float, _DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4);
            float2 _GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2;
            GetUv_float(_Property_691fe2672c4e427e81bf1480bdd91a73_Out_0_Vector4, (_DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4.xy), _GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2);
            float4 _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.tex, _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.samplerstate, _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.GetTransformedUV(_GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2) );
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_R_4_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.r;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_G_5_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.g;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_B_6_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.b;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_A_7_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.a;
            surface.Alpha = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_A_7_Float;
            surface.AlphaClipThreshold = _Split_f4276b026ecb4c69866ab3d1840e320d_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma multi_compile _ LOD_FADE_CROSSFADE
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define USE_UNITY_CROSSFADE 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _MainTex_TexelSize;
        float4 _UvRect;
        float4 _PivotAndSize;
        float4 _MeshWH;
        float4 _Border;
        float _DrawType;
        float2 _WidthAndHeight;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void GetPosition_float(float3 positionOS, float4 MeshWH, float4 PivotAndSize, float2 WidthAndHeight, float DrawType, out float3 outPosition){
            outPosition=positionOS;
            if(abs(DrawType-0)<=0.01)
            {
            	outPosition.x=positionOS.x+0.5*MeshWH.x;
            	outPosition.y=positionOS.y+0.5*MeshWH.y;
            	outPosition.x-=PivotAndSize.x*MeshWH.x;
            	outPosition.y-=PivotAndSize.y*MeshWH.y;
            	outPosition.x*=PivotAndSize.z;
            	outPosition.y*=PivotAndSize.w;
            }
            else if(abs(DrawType-1)<=0.01)
            {
            	outPosition.x=positionOS.x+0.5*MeshWH.x;
            	outPosition.y=positionOS.y+0.5*MeshWH.y;
            	outPosition.x-=PivotAndSize.x*MeshWH.x;
            	outPosition.y-=PivotAndSize.y*MeshWH.y;
            	outPosition.x*=WidthAndHeight.x;
            	outPosition.y*=WidthAndHeight.y;
            }
        }
        
        void DrawTypeUV_float(float DrawType, float4 InputUV, float4 PivotAndSize, float2 WidthAndHeight, float4 Border, float PixelsPerUnit, out float4 UVOut){
            UVOut = InputUV;
            
                            if (abs(DrawType - 0) < 0.01)return;
            
                            if (abs(DrawType - 1) < 0.01)
            
                            {
            
                                float finalWidth = WidthAndHeight.x * PixelsPerUnit; //最终宽度(实际宽度)
            
                                float finalHeight = WidthAndHeight.y * PixelsPerUnit; //最终高度(实际高度)
            
                                float texSizeWidth = PivotAndSize.z * PixelsPerUnit; //贴图宽度
            
                                float texSizeHeight = PivotAndSize.w * PixelsPerUnit; //贴图高度
            
            
            
                                float min_x_width = Border.x; //9宫格左边的x轴宽度
            
                                float min_x_value = min_x_width; //9宫格左边的x轴值
            
                                float max_x_width = Border.z; //9宫格右边线到最后的x轴宽度
            
                                float max_x_value = finalWidth - max_x_width; //9宫格右边线的x轴值
            
            
            
                                float min_y_height = Border.y; //9宫格下边的y轴高度--bottom
            
                                float min_y_value = min_y_height; //9宫格下边的y轴值
            
                                float max_y_height = Border.w; //9宫格上边的y轴高度--top
            
                                float max_y_value = finalHeight - max_y_height; //9宫格上边的y轴值(最下边到这条线的高度)
            
                                if (min_x_width + max_x_width > finalWidth)
            
                                {
            
                                    float sum = min_x_width + max_x_width;
            
                                    min_x_width = min_x_width / sum * finalWidth;
            
                                    min_x_value = min_x_width;
            
                                    max_x_width = finalWidth - min_x_width;
            
                                    max_x_value = finalWidth - max_x_width;
            
                                }
            
            
            
                                if (min_y_height + max_y_height > finalHeight)
            
                                {
            
                                    float sum = min_y_height + max_y_height;
            
                                    min_y_height = min_y_height / sum * finalHeight;
            
                                    min_y_value = min_y_height;
            
                                    max_y_height = finalHeight - min_y_height;
            
                                    max_y_value = finalHeight - max_y_height;
            
                                }
            
                                float x = InputUV.x * finalWidth;
            
                                float y = InputUV.y * finalHeight;
            
                                if (x <= min_x_value)
            
                                {
            
                                    UVOut.x *= finalWidth / texSizeWidth;
            
                                }
            
                                else if (x >= max_x_value)
            
                                {
            
                                    UVOut.x = 1 - ((1 - UVOut.x) * (finalWidth / texSizeWidth));
            
                                }
            
                                else
            
                                {
            
                                    float min_rate_x = min_x_value / texSizeWidth;
            
                                    float max_rate_x = (texSizeWidth - max_x_width) / texSizeWidth;
            
                                    float borderWidth = max_x_value - min_x_value;
            
                                    float xCha = x - min_x_value;
            
                                    float rate = xCha / borderWidth;
            
                                    UVOut.x = (max_rate_x - min_rate_x) * rate + min_rate_x;
            
                                }
            
            
            
                                if (y <= min_y_value)
            
                                {
            
                                    UVOut.y *= finalHeight / texSizeHeight;
            
                                }
            
                                else if (y >= max_y_value)
            
                                {
            
                                    UVOut.y = 1 - ((1 - UVOut.y) * (finalHeight / texSizeHeight));
            
                                }
            
                                else
            
                                {
            
                                    float min_rate_y = min_y_value / texSizeHeight;
            
                                    float max_rate_y = (texSizeHeight - max_y_height) / texSizeHeight;
            
                                    float border_height = max_y_value - min_y_value;
            
                                    float y_cha = y - min_y_value;
            
                                    float rate = y_cha / border_height;
            
                                    UVOut.y = (max_rate_y - min_rate_y) * rate + min_rate_y;
            
                                }
            
                            }
        }
        
        void GetUv_float(float4 _UvRect, float2 uvTemp, out float2 _out){
            _out=_UvRect.xy;
            
            _out.x=uvTemp.x * (_UvRect.z - _UvRect.x) + _UvRect.x;
            _out.y=uvTemp.y * (_UvRect.w - _UvRect.y) + _UvRect.y;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float4 _Property_2c211408dc3b437ab6f31899b8953b97_Out_0_Vector4 = _MeshWH;
            float4 _Property_1434c3f966ff459a960d8365ca5b6e33_Out_0_Vector4 = _PivotAndSize;
            float2 _Property_c6a9a778594b42d3a377e98c496d93c1_Out_0_Vector2 = _WidthAndHeight;
            float _Property_00c5f1e862f04770a75337e4dfb72e8d_Out_0_Float = _DrawType;
            float3 _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3;
            GetPosition_float(IN.ObjectSpacePosition, _Property_2c211408dc3b437ab6f31899b8953b97_Out_0_Vector4, _Property_1434c3f966ff459a960d8365ca5b6e33_Out_0_Vector4, _Property_c6a9a778594b42d3a377e98c496d93c1_Out_0_Vector2, _Property_00c5f1e862f04770a75337e4dfb72e8d_Out_0_Float, _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3);
            description.Position = _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _Property_691fe2672c4e427e81bf1480bdd91a73_Out_0_Vector4 = _UvRect;
            float _Property_bae20385e6f845c4b611e48bc7744935_Out_0_Float = _DrawType;
            float4 _UV_9fa10a2b0f354fdf8a75654d82e2e719_Out_0_Vector4 = IN.uv0;
            float4 _Property_874c47cfc09e4c7bad1707edba3cf783_Out_0_Vector4 = _PivotAndSize;
            float2 _Property_528dc8a2cbca45a9b6ec87f95cbf90b8_Out_0_Vector2 = _WidthAndHeight;
            float4 _Property_bb379e706808487f9c2e7c8358feca98_Out_0_Vector4 = _Border;
            float4 _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4 = _MeshWH;
            float _Split_f4276b026ecb4c69866ab3d1840e320d_R_1_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[0];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_G_2_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[1];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_B_3_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[2];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_A_4_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[3];
            float4 _DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4;
            DrawTypeUV_float(_Property_bae20385e6f845c4b611e48bc7744935_Out_0_Float, _UV_9fa10a2b0f354fdf8a75654d82e2e719_Out_0_Vector4, _Property_874c47cfc09e4c7bad1707edba3cf783_Out_0_Vector4, _Property_528dc8a2cbca45a9b6ec87f95cbf90b8_Out_0_Vector2, _Property_bb379e706808487f9c2e7c8358feca98_Out_0_Vector4, _Split_f4276b026ecb4c69866ab3d1840e320d_B_3_Float, _DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4);
            float2 _GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2;
            GetUv_float(_Property_691fe2672c4e427e81bf1480bdd91a73_Out_0_Vector4, (_DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4.xy), _GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2);
            float4 _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.tex, _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.samplerstate, _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.GetTransformedUV(_GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2) );
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_R_4_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.r;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_G_5_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.g;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_B_6_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.b;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_A_7_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.a;
            surface.Alpha = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_A_7_Float;
            surface.AlphaClipThreshold = _Split_f4276b026ecb4c69866ab3d1840e320d_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma multi_compile _ LOD_FADE_CROSSFADE
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define USE_UNITY_CROSSFADE 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP0;
            #endif
             float4 texCoord0 : INTERP1;
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _MainTex_TexelSize;
        float4 _UvRect;
        float4 _PivotAndSize;
        float4 _MeshWH;
        float4 _Border;
        float _DrawType;
        float2 _WidthAndHeight;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void GetPosition_float(float3 positionOS, float4 MeshWH, float4 PivotAndSize, float2 WidthAndHeight, float DrawType, out float3 outPosition){
            outPosition=positionOS;
            if(abs(DrawType-0)<=0.01)
            {
            	outPosition.x=positionOS.x+0.5*MeshWH.x;
            	outPosition.y=positionOS.y+0.5*MeshWH.y;
            	outPosition.x-=PivotAndSize.x*MeshWH.x;
            	outPosition.y-=PivotAndSize.y*MeshWH.y;
            	outPosition.x*=PivotAndSize.z;
            	outPosition.y*=PivotAndSize.w;
            }
            else if(abs(DrawType-1)<=0.01)
            {
            	outPosition.x=positionOS.x+0.5*MeshWH.x;
            	outPosition.y=positionOS.y+0.5*MeshWH.y;
            	outPosition.x-=PivotAndSize.x*MeshWH.x;
            	outPosition.y-=PivotAndSize.y*MeshWH.y;
            	outPosition.x*=WidthAndHeight.x;
            	outPosition.y*=WidthAndHeight.y;
            }
        }
        
        void DrawTypeUV_float(float DrawType, float4 InputUV, float4 PivotAndSize, float2 WidthAndHeight, float4 Border, float PixelsPerUnit, out float4 UVOut){
            UVOut = InputUV;
            
                            if (abs(DrawType - 0) < 0.01)return;
            
                            if (abs(DrawType - 1) < 0.01)
            
                            {
            
                                float finalWidth = WidthAndHeight.x * PixelsPerUnit; //最终宽度(实际宽度)
            
                                float finalHeight = WidthAndHeight.y * PixelsPerUnit; //最终高度(实际高度)
            
                                float texSizeWidth = PivotAndSize.z * PixelsPerUnit; //贴图宽度
            
                                float texSizeHeight = PivotAndSize.w * PixelsPerUnit; //贴图高度
            
            
            
                                float min_x_width = Border.x; //9宫格左边的x轴宽度
            
                                float min_x_value = min_x_width; //9宫格左边的x轴值
            
                                float max_x_width = Border.z; //9宫格右边线到最后的x轴宽度
            
                                float max_x_value = finalWidth - max_x_width; //9宫格右边线的x轴值
            
            
            
                                float min_y_height = Border.y; //9宫格下边的y轴高度--bottom
            
                                float min_y_value = min_y_height; //9宫格下边的y轴值
            
                                float max_y_height = Border.w; //9宫格上边的y轴高度--top
            
                                float max_y_value = finalHeight - max_y_height; //9宫格上边的y轴值(最下边到这条线的高度)
            
                                if (min_x_width + max_x_width > finalWidth)
            
                                {
            
                                    float sum = min_x_width + max_x_width;
            
                                    min_x_width = min_x_width / sum * finalWidth;
            
                                    min_x_value = min_x_width;
            
                                    max_x_width = finalWidth - min_x_width;
            
                                    max_x_value = finalWidth - max_x_width;
            
                                }
            
            
            
                                if (min_y_height + max_y_height > finalHeight)
            
                                {
            
                                    float sum = min_y_height + max_y_height;
            
                                    min_y_height = min_y_height / sum * finalHeight;
            
                                    min_y_value = min_y_height;
            
                                    max_y_height = finalHeight - min_y_height;
            
                                    max_y_value = finalHeight - max_y_height;
            
                                }
            
                                float x = InputUV.x * finalWidth;
            
                                float y = InputUV.y * finalHeight;
            
                                if (x <= min_x_value)
            
                                {
            
                                    UVOut.x *= finalWidth / texSizeWidth;
            
                                }
            
                                else if (x >= max_x_value)
            
                                {
            
                                    UVOut.x = 1 - ((1 - UVOut.x) * (finalWidth / texSizeWidth));
            
                                }
            
                                else
            
                                {
            
                                    float min_rate_x = min_x_value / texSizeWidth;
            
                                    float max_rate_x = (texSizeWidth - max_x_width) / texSizeWidth;
            
                                    float borderWidth = max_x_value - min_x_value;
            
                                    float xCha = x - min_x_value;
            
                                    float rate = xCha / borderWidth;
            
                                    UVOut.x = (max_rate_x - min_rate_x) * rate + min_rate_x;
            
                                }
            
            
            
                                if (y <= min_y_value)
            
                                {
            
                                    UVOut.y *= finalHeight / texSizeHeight;
            
                                }
            
                                else if (y >= max_y_value)
            
                                {
            
                                    UVOut.y = 1 - ((1 - UVOut.y) * (finalHeight / texSizeHeight));
            
                                }
            
                                else
            
                                {
            
                                    float min_rate_y = min_y_value / texSizeHeight;
            
                                    float max_rate_y = (texSizeHeight - max_y_height) / texSizeHeight;
            
                                    float border_height = max_y_value - min_y_value;
            
                                    float y_cha = y - min_y_value;
            
                                    float rate = y_cha / border_height;
            
                                    UVOut.y = (max_rate_y - min_rate_y) * rate + min_rate_y;
            
                                }
            
                            }
        }
        
        void GetUv_float(float4 _UvRect, float2 uvTemp, out float2 _out){
            _out=_UvRect.xy;
            
            _out.x=uvTemp.x * (_UvRect.z - _UvRect.x) + _UvRect.x;
            _out.y=uvTemp.y * (_UvRect.w - _UvRect.y) + _UvRect.y;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float4 _Property_2c211408dc3b437ab6f31899b8953b97_Out_0_Vector4 = _MeshWH;
            float4 _Property_1434c3f966ff459a960d8365ca5b6e33_Out_0_Vector4 = _PivotAndSize;
            float2 _Property_c6a9a778594b42d3a377e98c496d93c1_Out_0_Vector2 = _WidthAndHeight;
            float _Property_00c5f1e862f04770a75337e4dfb72e8d_Out_0_Float = _DrawType;
            float3 _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3;
            GetPosition_float(IN.ObjectSpacePosition, _Property_2c211408dc3b437ab6f31899b8953b97_Out_0_Vector4, _Property_1434c3f966ff459a960d8365ca5b6e33_Out_0_Vector4, _Property_c6a9a778594b42d3a377e98c496d93c1_Out_0_Vector2, _Property_00c5f1e862f04770a75337e4dfb72e8d_Out_0_Float, _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3);
            description.Position = _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_3056f453a9074d778c4583019576b46f_Out_0_Vector4 = _Color;
            UnityTexture2D _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _Property_691fe2672c4e427e81bf1480bdd91a73_Out_0_Vector4 = _UvRect;
            float _Property_bae20385e6f845c4b611e48bc7744935_Out_0_Float = _DrawType;
            float4 _UV_9fa10a2b0f354fdf8a75654d82e2e719_Out_0_Vector4 = IN.uv0;
            float4 _Property_874c47cfc09e4c7bad1707edba3cf783_Out_0_Vector4 = _PivotAndSize;
            float2 _Property_528dc8a2cbca45a9b6ec87f95cbf90b8_Out_0_Vector2 = _WidthAndHeight;
            float4 _Property_bb379e706808487f9c2e7c8358feca98_Out_0_Vector4 = _Border;
            float4 _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4 = _MeshWH;
            float _Split_f4276b026ecb4c69866ab3d1840e320d_R_1_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[0];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_G_2_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[1];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_B_3_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[2];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_A_4_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[3];
            float4 _DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4;
            DrawTypeUV_float(_Property_bae20385e6f845c4b611e48bc7744935_Out_0_Float, _UV_9fa10a2b0f354fdf8a75654d82e2e719_Out_0_Vector4, _Property_874c47cfc09e4c7bad1707edba3cf783_Out_0_Vector4, _Property_528dc8a2cbca45a9b6ec87f95cbf90b8_Out_0_Vector2, _Property_bb379e706808487f9c2e7c8358feca98_Out_0_Vector4, _Split_f4276b026ecb4c69866ab3d1840e320d_B_3_Float, _DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4);
            float2 _GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2;
            GetUv_float(_Property_691fe2672c4e427e81bf1480bdd91a73_Out_0_Vector4, (_DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4.xy), _GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2);
            float4 _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.tex, _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.samplerstate, _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.GetTransformedUV(_GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2) );
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_R_4_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.r;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_G_5_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.g;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_B_6_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.b;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_A_7_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.a;
            float4 _Multiply_8baa08899cee4bc8b97bf35d9e397bb4_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_3056f453a9074d778c4583019576b46f_Out_0_Vector4, _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4, _Multiply_8baa08899cee4bc8b97bf35d9e397bb4_Out_2_Vector4);
            surface.BaseColor = (_Multiply_8baa08899cee4bc8b97bf35d9e397bb4_Out_2_Vector4.xyz);
            surface.Alpha = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_A_7_Float;
            surface.AlphaClipThreshold = _Split_f4276b026ecb4c69866ab3d1840e320d_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _MainTex_TexelSize;
        float4 _UvRect;
        float4 _PivotAndSize;
        float4 _MeshWH;
        float4 _Border;
        float _DrawType;
        float2 _WidthAndHeight;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void GetPosition_float(float3 positionOS, float4 MeshWH, float4 PivotAndSize, float2 WidthAndHeight, float DrawType, out float3 outPosition){
            outPosition=positionOS;
            if(abs(DrawType-0)<=0.01)
            {
            	outPosition.x=positionOS.x+0.5*MeshWH.x;
            	outPosition.y=positionOS.y+0.5*MeshWH.y;
            	outPosition.x-=PivotAndSize.x*MeshWH.x;
            	outPosition.y-=PivotAndSize.y*MeshWH.y;
            	outPosition.x*=PivotAndSize.z;
            	outPosition.y*=PivotAndSize.w;
            }
            else if(abs(DrawType-1)<=0.01)
            {
            	outPosition.x=positionOS.x+0.5*MeshWH.x;
            	outPosition.y=positionOS.y+0.5*MeshWH.y;
            	outPosition.x-=PivotAndSize.x*MeshWH.x;
            	outPosition.y-=PivotAndSize.y*MeshWH.y;
            	outPosition.x*=WidthAndHeight.x;
            	outPosition.y*=WidthAndHeight.y;
            }
        }
        
        void DrawTypeUV_float(float DrawType, float4 InputUV, float4 PivotAndSize, float2 WidthAndHeight, float4 Border, float PixelsPerUnit, out float4 UVOut){
            UVOut = InputUV;
            
                            if (abs(DrawType - 0) < 0.01)return;
            
                            if (abs(DrawType - 1) < 0.01)
            
                            {
            
                                float finalWidth = WidthAndHeight.x * PixelsPerUnit; //最终宽度(实际宽度)
            
                                float finalHeight = WidthAndHeight.y * PixelsPerUnit; //最终高度(实际高度)
            
                                float texSizeWidth = PivotAndSize.z * PixelsPerUnit; //贴图宽度
            
                                float texSizeHeight = PivotAndSize.w * PixelsPerUnit; //贴图高度
            
            
            
                                float min_x_width = Border.x; //9宫格左边的x轴宽度
            
                                float min_x_value = min_x_width; //9宫格左边的x轴值
            
                                float max_x_width = Border.z; //9宫格右边线到最后的x轴宽度
            
                                float max_x_value = finalWidth - max_x_width; //9宫格右边线的x轴值
            
            
            
                                float min_y_height = Border.y; //9宫格下边的y轴高度--bottom
            
                                float min_y_value = min_y_height; //9宫格下边的y轴值
            
                                float max_y_height = Border.w; //9宫格上边的y轴高度--top
            
                                float max_y_value = finalHeight - max_y_height; //9宫格上边的y轴值(最下边到这条线的高度)
            
                                if (min_x_width + max_x_width > finalWidth)
            
                                {
            
                                    float sum = min_x_width + max_x_width;
            
                                    min_x_width = min_x_width / sum * finalWidth;
            
                                    min_x_value = min_x_width;
            
                                    max_x_width = finalWidth - min_x_width;
            
                                    max_x_value = finalWidth - max_x_width;
            
                                }
            
            
            
                                if (min_y_height + max_y_height > finalHeight)
            
                                {
            
                                    float sum = min_y_height + max_y_height;
            
                                    min_y_height = min_y_height / sum * finalHeight;
            
                                    min_y_value = min_y_height;
            
                                    max_y_height = finalHeight - min_y_height;
            
                                    max_y_value = finalHeight - max_y_height;
            
                                }
            
                                float x = InputUV.x * finalWidth;
            
                                float y = InputUV.y * finalHeight;
            
                                if (x <= min_x_value)
            
                                {
            
                                    UVOut.x *= finalWidth / texSizeWidth;
            
                                }
            
                                else if (x >= max_x_value)
            
                                {
            
                                    UVOut.x = 1 - ((1 - UVOut.x) * (finalWidth / texSizeWidth));
            
                                }
            
                                else
            
                                {
            
                                    float min_rate_x = min_x_value / texSizeWidth;
            
                                    float max_rate_x = (texSizeWidth - max_x_width) / texSizeWidth;
            
                                    float borderWidth = max_x_value - min_x_value;
            
                                    float xCha = x - min_x_value;
            
                                    float rate = xCha / borderWidth;
            
                                    UVOut.x = (max_rate_x - min_rate_x) * rate + min_rate_x;
            
                                }
            
            
            
                                if (y <= min_y_value)
            
                                {
            
                                    UVOut.y *= finalHeight / texSizeHeight;
            
                                }
            
                                else if (y >= max_y_value)
            
                                {
            
                                    UVOut.y = 1 - ((1 - UVOut.y) * (finalHeight / texSizeHeight));
            
                                }
            
                                else
            
                                {
            
                                    float min_rate_y = min_y_value / texSizeHeight;
            
                                    float max_rate_y = (texSizeHeight - max_y_height) / texSizeHeight;
            
                                    float border_height = max_y_value - min_y_value;
            
                                    float y_cha = y - min_y_value;
            
                                    float rate = y_cha / border_height;
            
                                    UVOut.y = (max_rate_y - min_rate_y) * rate + min_rate_y;
            
                                }
            
                            }
        }
        
        void GetUv_float(float4 _UvRect, float2 uvTemp, out float2 _out){
            _out=_UvRect.xy;
            
            _out.x=uvTemp.x * (_UvRect.z - _UvRect.x) + _UvRect.x;
            _out.y=uvTemp.y * (_UvRect.w - _UvRect.y) + _UvRect.y;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float4 _Property_2c211408dc3b437ab6f31899b8953b97_Out_0_Vector4 = _MeshWH;
            float4 _Property_1434c3f966ff459a960d8365ca5b6e33_Out_0_Vector4 = _PivotAndSize;
            float2 _Property_c6a9a778594b42d3a377e98c496d93c1_Out_0_Vector2 = _WidthAndHeight;
            float _Property_00c5f1e862f04770a75337e4dfb72e8d_Out_0_Float = _DrawType;
            float3 _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3;
            GetPosition_float(IN.ObjectSpacePosition, _Property_2c211408dc3b437ab6f31899b8953b97_Out_0_Vector4, _Property_1434c3f966ff459a960d8365ca5b6e33_Out_0_Vector4, _Property_c6a9a778594b42d3a377e98c496d93c1_Out_0_Vector2, _Property_00c5f1e862f04770a75337e4dfb72e8d_Out_0_Float, _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3);
            description.Position = _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _Property_691fe2672c4e427e81bf1480bdd91a73_Out_0_Vector4 = _UvRect;
            float _Property_bae20385e6f845c4b611e48bc7744935_Out_0_Float = _DrawType;
            float4 _UV_9fa10a2b0f354fdf8a75654d82e2e719_Out_0_Vector4 = IN.uv0;
            float4 _Property_874c47cfc09e4c7bad1707edba3cf783_Out_0_Vector4 = _PivotAndSize;
            float2 _Property_528dc8a2cbca45a9b6ec87f95cbf90b8_Out_0_Vector2 = _WidthAndHeight;
            float4 _Property_bb379e706808487f9c2e7c8358feca98_Out_0_Vector4 = _Border;
            float4 _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4 = _MeshWH;
            float _Split_f4276b026ecb4c69866ab3d1840e320d_R_1_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[0];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_G_2_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[1];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_B_3_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[2];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_A_4_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[3];
            float4 _DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4;
            DrawTypeUV_float(_Property_bae20385e6f845c4b611e48bc7744935_Out_0_Float, _UV_9fa10a2b0f354fdf8a75654d82e2e719_Out_0_Vector4, _Property_874c47cfc09e4c7bad1707edba3cf783_Out_0_Vector4, _Property_528dc8a2cbca45a9b6ec87f95cbf90b8_Out_0_Vector2, _Property_bb379e706808487f9c2e7c8358feca98_Out_0_Vector4, _Split_f4276b026ecb4c69866ab3d1840e320d_B_3_Float, _DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4);
            float2 _GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2;
            GetUv_float(_Property_691fe2672c4e427e81bf1480bdd91a73_Out_0_Vector4, (_DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4.xy), _GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2);
            float4 _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.tex, _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.samplerstate, _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.GetTransformedUV(_GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2) );
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_R_4_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.r;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_G_5_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.g;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_B_6_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.b;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_A_7_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.a;
            surface.Alpha = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_A_7_Float;
            surface.AlphaClipThreshold = _Split_f4276b026ecb4c69866ab3d1840e320d_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull [_Cull]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _MainTex_TexelSize;
        float4 _UvRect;
        float4 _PivotAndSize;
        float4 _MeshWH;
        float4 _Border;
        float _DrawType;
        float2 _WidthAndHeight;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void GetPosition_float(float3 positionOS, float4 MeshWH, float4 PivotAndSize, float2 WidthAndHeight, float DrawType, out float3 outPosition){
            outPosition=positionOS;
            if(abs(DrawType-0)<=0.01)
            {
            	outPosition.x=positionOS.x+0.5*MeshWH.x;
            	outPosition.y=positionOS.y+0.5*MeshWH.y;
            	outPosition.x-=PivotAndSize.x*MeshWH.x;
            	outPosition.y-=PivotAndSize.y*MeshWH.y;
            	outPosition.x*=PivotAndSize.z;
            	outPosition.y*=PivotAndSize.w;
            }
            else if(abs(DrawType-1)<=0.01)
            {
            	outPosition.x=positionOS.x+0.5*MeshWH.x;
            	outPosition.y=positionOS.y+0.5*MeshWH.y;
            	outPosition.x-=PivotAndSize.x*MeshWH.x;
            	outPosition.y-=PivotAndSize.y*MeshWH.y;
            	outPosition.x*=WidthAndHeight.x;
            	outPosition.y*=WidthAndHeight.y;
            }
        }
        
        void DrawTypeUV_float(float DrawType, float4 InputUV, float4 PivotAndSize, float2 WidthAndHeight, float4 Border, float PixelsPerUnit, out float4 UVOut){
            UVOut = InputUV;
            
                            if (abs(DrawType - 0) < 0.01)return;
            
                            if (abs(DrawType - 1) < 0.01)
            
                            {
            
                                float finalWidth = WidthAndHeight.x * PixelsPerUnit; //最终宽度(实际宽度)
            
                                float finalHeight = WidthAndHeight.y * PixelsPerUnit; //最终高度(实际高度)
            
                                float texSizeWidth = PivotAndSize.z * PixelsPerUnit; //贴图宽度
            
                                float texSizeHeight = PivotAndSize.w * PixelsPerUnit; //贴图高度
            
            
            
                                float min_x_width = Border.x; //9宫格左边的x轴宽度
            
                                float min_x_value = min_x_width; //9宫格左边的x轴值
            
                                float max_x_width = Border.z; //9宫格右边线到最后的x轴宽度
            
                                float max_x_value = finalWidth - max_x_width; //9宫格右边线的x轴值
            
            
            
                                float min_y_height = Border.y; //9宫格下边的y轴高度--bottom
            
                                float min_y_value = min_y_height; //9宫格下边的y轴值
            
                                float max_y_height = Border.w; //9宫格上边的y轴高度--top
            
                                float max_y_value = finalHeight - max_y_height; //9宫格上边的y轴值(最下边到这条线的高度)
            
                                if (min_x_width + max_x_width > finalWidth)
            
                                {
            
                                    float sum = min_x_width + max_x_width;
            
                                    min_x_width = min_x_width / sum * finalWidth;
            
                                    min_x_value = min_x_width;
            
                                    max_x_width = finalWidth - min_x_width;
            
                                    max_x_value = finalWidth - max_x_width;
            
                                }
            
            
            
                                if (min_y_height + max_y_height > finalHeight)
            
                                {
            
                                    float sum = min_y_height + max_y_height;
            
                                    min_y_height = min_y_height / sum * finalHeight;
            
                                    min_y_value = min_y_height;
            
                                    max_y_height = finalHeight - min_y_height;
            
                                    max_y_value = finalHeight - max_y_height;
            
                                }
            
                                float x = InputUV.x * finalWidth;
            
                                float y = InputUV.y * finalHeight;
            
                                if (x <= min_x_value)
            
                                {
            
                                    UVOut.x *= finalWidth / texSizeWidth;
            
                                }
            
                                else if (x >= max_x_value)
            
                                {
            
                                    UVOut.x = 1 - ((1 - UVOut.x) * (finalWidth / texSizeWidth));
            
                                }
            
                                else
            
                                {
            
                                    float min_rate_x = min_x_value / texSizeWidth;
            
                                    float max_rate_x = (texSizeWidth - max_x_width) / texSizeWidth;
            
                                    float borderWidth = max_x_value - min_x_value;
            
                                    float xCha = x - min_x_value;
            
                                    float rate = xCha / borderWidth;
            
                                    UVOut.x = (max_rate_x - min_rate_x) * rate + min_rate_x;
            
                                }
            
            
            
                                if (y <= min_y_value)
            
                                {
            
                                    UVOut.y *= finalHeight / texSizeHeight;
            
                                }
            
                                else if (y >= max_y_value)
            
                                {
            
                                    UVOut.y = 1 - ((1 - UVOut.y) * (finalHeight / texSizeHeight));
            
                                }
            
                                else
            
                                {
            
                                    float min_rate_y = min_y_value / texSizeHeight;
            
                                    float max_rate_y = (texSizeHeight - max_y_height) / texSizeHeight;
            
                                    float border_height = max_y_value - min_y_value;
            
                                    float y_cha = y - min_y_value;
            
                                    float rate = y_cha / border_height;
            
                                    UVOut.y = (max_rate_y - min_rate_y) * rate + min_rate_y;
            
                                }
            
                            }
        }
        
        void GetUv_float(float4 _UvRect, float2 uvTemp, out float2 _out){
            _out=_UvRect.xy;
            
            _out.x=uvTemp.x * (_UvRect.z - _UvRect.x) + _UvRect.x;
            _out.y=uvTemp.y * (_UvRect.w - _UvRect.y) + _UvRect.y;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float4 _Property_2c211408dc3b437ab6f31899b8953b97_Out_0_Vector4 = _MeshWH;
            float4 _Property_1434c3f966ff459a960d8365ca5b6e33_Out_0_Vector4 = _PivotAndSize;
            float2 _Property_c6a9a778594b42d3a377e98c496d93c1_Out_0_Vector2 = _WidthAndHeight;
            float _Property_00c5f1e862f04770a75337e4dfb72e8d_Out_0_Float = _DrawType;
            float3 _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3;
            GetPosition_float(IN.ObjectSpacePosition, _Property_2c211408dc3b437ab6f31899b8953b97_Out_0_Vector4, _Property_1434c3f966ff459a960d8365ca5b6e33_Out_0_Vector4, _Property_c6a9a778594b42d3a377e98c496d93c1_Out_0_Vector2, _Property_00c5f1e862f04770a75337e4dfb72e8d_Out_0_Float, _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3);
            description.Position = _GetPositionCustomFunction_f377b077379847389a07ce6f6e228d0f_outPosition_3_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _Property_691fe2672c4e427e81bf1480bdd91a73_Out_0_Vector4 = _UvRect;
            float _Property_bae20385e6f845c4b611e48bc7744935_Out_0_Float = _DrawType;
            float4 _UV_9fa10a2b0f354fdf8a75654d82e2e719_Out_0_Vector4 = IN.uv0;
            float4 _Property_874c47cfc09e4c7bad1707edba3cf783_Out_0_Vector4 = _PivotAndSize;
            float2 _Property_528dc8a2cbca45a9b6ec87f95cbf90b8_Out_0_Vector2 = _WidthAndHeight;
            float4 _Property_bb379e706808487f9c2e7c8358feca98_Out_0_Vector4 = _Border;
            float4 _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4 = _MeshWH;
            float _Split_f4276b026ecb4c69866ab3d1840e320d_R_1_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[0];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_G_2_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[1];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_B_3_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[2];
            float _Split_f4276b026ecb4c69866ab3d1840e320d_A_4_Float = _Property_14e05098f034486eb8297f7148d9cd2d_Out_0_Vector4[3];
            float4 _DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4;
            DrawTypeUV_float(_Property_bae20385e6f845c4b611e48bc7744935_Out_0_Float, _UV_9fa10a2b0f354fdf8a75654d82e2e719_Out_0_Vector4, _Property_874c47cfc09e4c7bad1707edba3cf783_Out_0_Vector4, _Property_528dc8a2cbca45a9b6ec87f95cbf90b8_Out_0_Vector2, _Property_bb379e706808487f9c2e7c8358feca98_Out_0_Vector4, _Split_f4276b026ecb4c69866ab3d1840e320d_B_3_Float, _DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4);
            float2 _GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2;
            GetUv_float(_Property_691fe2672c4e427e81bf1480bdd91a73_Out_0_Vector4, (_DrawTypeUVCustomFunction_2b1464ae8b2e43ffa00e106cd605f6ee_UVOut_1_Vector4.xy), _GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2);
            float4 _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.tex, _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.samplerstate, _Property_be4f70504cbb4e6b83a752ed03e332fd_Out_0_Texture2D.GetTransformedUV(_GetUvCustomFunction_da8af0068fab4631832b8984d62a8bdf_out_2_Vector2) );
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_R_4_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.r;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_G_5_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.g;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_B_6_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.b;
            float _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_A_7_Float = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_RGBA_0_Vector4.a;
            surface.Alpha = _SampleTexture2D_d5c67b501ecf4876ba494f13d481d2ac_A_7_Float;
            surface.AlphaClipThreshold = _Split_f4276b026ecb4c69866ab3d1840e320d_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphUnlitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}