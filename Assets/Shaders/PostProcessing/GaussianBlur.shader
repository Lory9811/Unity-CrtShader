Shader "Hidden/GaussianBlur" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _TextureSizeX ("Texture Width", Integer) = 1
        _TextureSizeY ("Texture Height", Integer) = 1
    }
    SubShader {
        Pass {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;

            int _TextureSizeX;        

            float4 frag(v2f_img i) : COLOR {
                const float blurSize = 1.0 / _TextureSizeX;

                float4 acc = 6 * tex2D(_MainTex, i.uv);
                acc += 4 * tex2D(_MainTex, i.uv + float2(blurSize, 0.0));
                acc += 4 * tex2D(_MainTex, i.uv + float2(-blurSize, 0.0));

                acc += tex2D(_MainTex, i.uv + float2(2 * blurSize, 0.0));
                acc += tex2D(_MainTex, i.uv + float2(2 * -blurSize, 0.0));

                return acc / 16;
            }
            ENDCG
        }
        Pass {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;

            int _TextureSizeY;

            float4 frag(v2f_img i) : COLOR {
                const float blurSize = 1.0 / _TextureSizeY;

                float4 acc = 6 * tex2D(_MainTex, i.uv);
                acc += 4 * tex2D(_MainTex, i.uv + float2(0.0, blurSize));
                acc += 4 * tex2D(_MainTex, i.uv + float2(0.0, -blurSize));

                acc += tex2D(_MainTex, i.uv + float2(0.0, 2 * blurSize));
                acc += tex2D(_MainTex, i.uv + float2(0.0, 2 * -blurSize));

                return acc / 16;
            }
            ENDCG
        }
    }
}
