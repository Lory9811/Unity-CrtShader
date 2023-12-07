Shader "Hidden/Bloom" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Blurred ("Blur", 2D) = "white" {}
    }
    SubShader {
        Pass {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _Blurred;

            float4 frag(v2f_img i) : COLOR {
                return 0.85 * (0.7 * tex2D(_MainTex, i.uv) + 0.5 * tex2D(_Blurred, i.uv));
            }
            ENDCG
        }
    }
}
