
Shader "Custom/LowPolyWater"
{
	Properties
	{
		_Color("Color", Color) = (1, 1, 1, .5)
		_MainTex("Main Texture", 2D) = "white" {}
		_SecondTex("Second Texture", 2D) = "white" {}
		_NoiseTex("Extra Wave Noise", 2D) = "white" {}
		_Speed("Wave Speed", Range(0,1)) = 0.5
		_Amount("Wave Amount", Range(0,1)) = 0.5
		_Height("Wave Height", Range(0,1)) = 0.5
		_Foam("Foamline Thickness", Range(0,3)) = 0.5

	}
		SubShader
		{
			Tags{ "RenderType" = "Opaque"  "Queue" = "Transparent" }
			LOD 100
			Blend SrcAlpha OneMinusSrcAlpha

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
			float4 scrPos : TEXCOORD3;
		};

		float4 _Color;
		uniform sampler2D _CameraDepthTexture; //Depth Texture
		sampler2D _MainTex;
		sampler2D _NoiseTex;//
		float4 _MainTex_ST;
		float _Speed;
		float _Amount;
		float _Height;
		float _Foam;// 

		v2f vert(appdata v)
		{
			v2f o;
			float4 tex = tex2Dlod(_NoiseTex, float4(v.uv.xy, 0, 0));//extra noise tex
			v.vertex.y += sin(_Time.z * _Speed + (v.vertex.x * v.vertex.z * _Amount * tex)) * _Height;//movement
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			o.scrPos = ComputeScreenPos(o.vertex); // grab position on screen
			UNITY_TRANSFER_FOG(o,o.vertex);

			return o;
		}

		fixed4 frag(v2f IN) : SV_Target
		{
			// sample the texture

			half4 col = tex2D(_MainTex, IN.uv + (_Time.y / 50)) * _Color;// texture times tint;
			half depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(IN.scrPos))); // depth
			half4 foamLine = 1 - saturate(_Foam * (depth - IN.scrPos.w));// foam line by comparing depth and screenposition
			col += foamLine * _Color; // add the foam line and tint to the texture
			return col;
		}
			ENDCG
		}
		}
}