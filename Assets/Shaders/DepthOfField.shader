// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/DepthOfField"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DepthFocus("Depth focus", Range(0,1)) = 0.5
		_LensFocus("Depth focus", Range(0,1)) = 0.1
		_DisplayDepth("Depth buffer displayed", Float) = 1
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : POSITION;
				//float4 scrPos : TEXCOORD1;
				half2 taps[4] : TEXCOORD2; 
			};

			fixed _DisplayDepth;
			sampler2D _MainTex;
			fixed _DepthFocus;
			fixed _LensFocus;
			float4 _MainTex_ST;
			half4 _MainTex_TexelSize;
			uniform sampler2D _CameraDepthTexture;
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;//TRANSFORM_TEX(v.texcoord, _MainTex);
				//o.scrPos = ComputeScreenPos(o.pos);

				fixed2 offset = fixed2(1.3,1.3);
				o.taps[0] = o.uv + _MainTex_TexelSize * offset.xy;
				o.taps[1] = o.uv - _MainTex_TexelSize * offset.xy;
				o.taps[2] = o.uv + _MainTex_TexelSize * offset.xy * half2(1,-1);
				o.taps[3] = o.uv - _MainTex_TexelSize * offset.xy * half2(1,-1);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float depthValue = Linear01Depth(tex2D(_CameraDepthTexture, i.uv));
				// To display the depth buffer
				if(_DisplayDepth == 0)  {

					if(depthValue > _DepthFocus - _LensFocus && depthValue < _DepthFocus + _LensFocus) {
						// in focus
						// sample the texture
						fixed4 col = tex2D(_MainTex, i.uv);
						return col;
					} else {
						// do blur
						fixed4 glowCol = tex2D(_MainTex, i.uv);
						glowCol += tex2D(_MainTex, i.taps[1]);
						glowCol += tex2D(_MainTex, i.taps[2]);
						glowCol += tex2D(_MainTex, i.taps[3]);
						glowCol /= 4;
						return glowCol;
					}
				} else {
					return depthValue.xxxx;
				}

			}
			ENDCG
		}
	}
}
