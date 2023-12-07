Shader "Hidden/CrtEffect" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _ScreenWidth("Screen Width", Integer) = 1
        _ScreenHeight("Screen Height", Integer) = 1
    }
    SubShader {
        Pass {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            int _ScreenWidth;
            int _ScreenHeight;

            float rand(float2 x, float phase) {
                return frac(4231 * sin(_ScreenHeight * x.x + _ScreenWidth * x.y + phase));
            }

            float4 frag(v2f_img i) : COLOR {
                float4 black = float4(0.0, 0.0, 0.0, 0.0);
                
                uint2 pixelPos = uint2(i.uv.x * _ScreenWidth, i.uv.y * _ScreenHeight);
                uint offsety = 0;
                if ((pixelPos.x / 4u) % 2 == 0) {
                    offsety = 2;
                }
                
                float2 gridUv = float2(
                    floor(pixelPos.x / 4u) / (_ScreenWidth / 4u),
                    floor((pixelPos.y + offsety) / 4u) / (_ScreenHeight / 4u)
                );

                if ((pixelPos.y + offsety) % 4 == 0) {
                    return black;
                }
                
                float noise = rand(gridUv, _Time.x);
                float4 color = tex2D(_MainTex, gridUv) + 
                    float4(0.12 * float3(noise, noise, noise), 1.0);
                uint index = (pixelPos.x % 4);

                if (index == 1) {
                    return float4(color.r, 0.0, 0.0, 1.0);
                } else if (index == 2) {
                    return float4(0.0, color.g, 0.0, 1.0);
                } else if (index == 3) {
                    return float4(0.0, 0.0, color.b, 1.0);
                }

                return black;
            }
            ENDCG
        }
    }
}
