Shader "Custom/RealisticSkin" 
{
    Properties
    {
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _SpecularMap("Specular Map", 2D) = "black" {}
        _SubsurfaceColor("Subsurface Color", Color) = (1, 0.2, 0.2, 1)
        _SubsurfaceStrength("Subsurface Strength", Range(0, 1)) = 0.5
        _SpecularGloss("Specular Gloss", Range(0, 1)) = 0.5
        _FresnelFalloff("Fresnel Falloff", Range(0, 5)) = 1.0
    }

        SubShader
        {
            Tags { "RenderType" = "Opaque" }

            CGPROGRAM
            #pragma surface surf Lambert

            sampler2D _MainTex;
            sampler2D _NormalMap;
            sampler2D _SpecularMap;
            fixed4 _SubsurfaceColor;
            float _SubsurfaceStrength;
            float _SpecularGloss;
            float _FresnelFalloff;

            struct Input 
            {
                float2 uv_MainTex;
                float2 uv_NormalMap;
                float2 uv_SpecularMap;
            };

            void surf(Input IN, inout SurfaceOutput o) 
            {
                fixed4 albedo = tex2D(_MainTex, IN.uv_MainTex);
                fixed3 normal = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));
                fixed3 specular = tex2D(_SpecularMap, IN.uv_SpecularMap).rgb;

                // Diffuse color
                o.Albedo = albedo.rgb;

                // Normal map
                o.Normal = normal.rgb;

                // Specular reflections
                o.Specular = _SpecularGloss * specular;

                // Subsurface scattering (Burley approximation)
                fixed scatterRadius = _SubsurfaceStrength;
                fixed scatterProfile = (1.0 - exp(-scatterRadius * dot(normal, o.Normal))) / (1.0 - exp(-scatterRadius));
                o.Albedo = lerp(o.Albedo, _SubsurfaceColor.rgb, scatterProfile) * albedo.rgb;

                // Fresnel effect
                fixed fresnel = pow(1.0 - saturate(dot(normal, o.Normal)), _FresnelFalloff);
                o.Albedo = lerp(o.Albedo, o.Albedo + fresnel, fresnel);
            }
            ENDCG
        }
            FallBack "Diffuse"
}
