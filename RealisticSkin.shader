Shader "Custom/RealisticSkin"
{
    Properties
    {
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _SubsurfaceColor("Subsurface Color", Color) = (1, 0.9137255, 0.8196079, 1)
        _SubsurfaceStrength("Subsurface Strength", Range(0, 1)) = 0.5
        _SpecularGloss("Specular Gloss", Range(0, 1)) = 0.5
    }

        SubShader
        {
            Tags
            {
                "RenderType" = "Opaque"
            }

            CGPROGRAM
            #pragma surface surf Lambert

            sampler2D _MainTex;
            sampler2D _NormalMap;
            fixed4 _SubsurfaceColor;
            float _SubsurfaceStrength;
            float _SpecularGloss;

            struct Input
            {
                float2 uv_MainTex;
                float2 uv_NormalMap;
            };

            void surf(Input IN, inout SurfaceOutput o)
            {
                fixed4 albedo = tex2D(_MainTex, IN.uv_MainTex);
                fixed3 normal = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));

                // Diffuse color
                o.Albedo = albedo.rgb;

                // Normal map
                o.Normal = normal;

                // Specular reflections (simplified)
                o.Specular = _SpecularGloss;

                // Subsurface scattering (Burley approximation)
                fixed scatterRadius = _SubsurfaceStrength;
                fixed scatterProfile = (1.0 - exp(-scatterRadius * dot(normal, o.Normal))) / (1.0 - exp(-scatterRadius));
                o.Albedo = lerp(o.Albedo, _SubsurfaceColor.rgb, scatterProfile) * albedo.rgb;

                // Fresnel effect for even lighting across angles
                fixed viewAngleCorrection = saturate(1 + dot(o.Normal, normal));
                o.Albedo *= viewAngleCorrection;
            }
            ENDCG
        }

            FallBack "Diffuse"
}
