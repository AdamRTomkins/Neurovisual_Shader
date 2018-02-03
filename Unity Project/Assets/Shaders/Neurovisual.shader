// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Neurovisual"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Size("Size of Hexagon", Float) = 10
		_Gray("Grayscale", Int) = 1

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
			#pragma target 4.0
			
			#include "UnityCG.cginc"
			#include "Hexagons.cginc"
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
			float _Size;
			float _Gray;
			
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
				// Calculate your hexagon number
				float2 hex = pixel_to_hex(c.x,c.y, _Size);
				// Calculate the center of the hexgon
				int2 center_pixel = hex_to_pixel(hex.x, hex.y, _Size);

				// Calculate the average
				int count = 0;
				float4 count_colour = 0;
				//if (c.x == center_pixel.x && c.y == center_pixel.y) { // Remove  If, acts correctly, but ineffecient. 
					[loop] // Force loop unrolling
					for (int ci = -_Size; ci < _Size; ci++) {
						[loop]
						for (int cj = -_Size; cj < _Size; cj++) {
							float2 offset_hex = pixel_to_hex(c.x + ci, c.y + cj, _Size);
							if (offset_hex.x == hex.x && offset_hex.y == hex.y) {
								// add color and increment
								count_colour = count_colour + tex2D(_MainTex, float2((center_pixel.x + ci) / _ScreenParams.x, (center_pixel.y + cj) / _ScreenParams.y));
								count = count + 1;
							}
						}
					}

					// calculate average
					count_colour = count_colour / count;
					count_colour[3] = 1;
		
					if (_Gray == 0) {
						return count_colour;
					}
					else {
						float g1 = (0.21 * count_colour[0] + 0.72 * count_colour[1] + 0.07*count_colour[2]);
						float4 g2 = float4(g1, g1, g1, 1.0);
						return g2; //count_colour;
					}
					 return col;
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
			#include "Hexagons.cginc"

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
			float _Size;

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
				// using screen position	
#ifdef USE_SCREEN_POSITION
				int c = int2(i.screenPos.x * _ScreenParams.x, i.screenPos.y * _ScreenParams.y);
#else	
				// using uv's
				int2 c = int2(i.grabUVs.x * _ScreenParams.x, i.grabUVs.y * _ScreenParams.y);

#endif
				// Calculate your hexagon number
				float2 hex = pixel_to_hex(c.x,c.y, _Size);
				// Calculate the center of the hexgon
				int2 center_pixel = hex_to_pixel(hex.x, hex.y, _Size);

				return tex2D(_GrabTexture, float2(center_pixel.x / _ScreenParams.x, center_pixel.y / _ScreenParams.y));
			
			}
				ENDCG
		}
	}
}
