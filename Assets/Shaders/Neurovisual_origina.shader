// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Neurovisual_original"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Rows ("Number of rows", Float) = 10
		_Columns("Number of cols", Float) = 10
		
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		// FIRST PASS //
		// CALCULATE THE COLOUR FOR THE CENTRE OF THE SHAPE
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			//#define USE_SCREEN_POSITION

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float2 screenPos : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Rows;
			float _Columns;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.screenPos = ComputeScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// using screen position	
#ifdef USE_SCREEN_POSITION
				int c = int2(i.screenPos.x * _ScreenParams.x, i.screenPos.y * _ScreenParams.y);
#else
				// using uv's
				int2 c = int2(i.uv.x * _ScreenParams.x, i.uv.y * _ScreenParams.y); 
#endif
				int rows = _ScreenParams.y / _Rows;
				int cols = _ScreenParams.x / _Columns;
				
				if (c.x % cols == 0 && c.y % rows == 0) {
					// maths to calculate the colour of the centre of the shape
					return fixed4(1, 1, 0, 1);
				}
				else {
					// leave as is
					return col;
				}
					
					
			}
			ENDCG
		}

		GrabPass {
		}
		// SECOND PASS //
		// GET THE COLOUR FROM CENTRE OF SHAPE AND PAINT THE REST //
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 grabUVs : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float2 screenPos : TEXCOORD1;
			};

			sampler2D _GrabTexture;
			float _Rows;
			float _Columns;

			v2f vert(appdata v)
			{
				v2f o;
				float4 hpos = UnityObjectToClipPos(v.vertex);
				o.grabUVs = ComputeGrabScreenPos(hpos);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.screenPos = ComputeScreenPos(o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.grabUVs));
				// using screen position	
#ifdef USE_SCREEN_POSITION
				int c = int2(i.screenPos.x * _ScreenParams.x, i.screenPos.y * _ScreenParams.y);
#else
				// using uv's
				int2 c = int2(i.grabUVs.x * _ScreenParams.x, i.grabUVs.y * _ScreenParams.y);
#endif
				int rows = _ScreenParams.y / _Rows;
				int cols = _ScreenParams.x / _Columns;
				if (c.x % cols == 0 && c.y % rows == 0) {
					// center of the shape, leave as is
					return col;
				}
				else {
					// get colour from centre of the shape
					return col;
				}


			}
				ENDCG
		}
	}
}
