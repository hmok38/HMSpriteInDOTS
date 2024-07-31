Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }

            void Test(float DrawType, float4 InputUV, float4 PivotAndSize, float2 WidthAndHeight, float4 Border,
                      float PixelsPerUnit, float4 UVOut)
            {
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
            ENDCG
        }
    }
}