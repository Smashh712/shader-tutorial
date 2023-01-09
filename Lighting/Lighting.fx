//**************************************************************//
//  Effect File exported by RenderMonkey 1.6
//
//  - Although many improvements were made to RenderMonkey FX  
//    file export, there are still situations that may cause   
//    compilation problems once the file is exported, such as  
//    occasional naming conflicts for methods, since FX format 
//    does not support any notions of name spaces. You need to 
//    try to create workspaces in such a way as to minimize    
//    potential naming conflicts on export.                    
//    
//  - Note that to minimize resulting name collisions in the FX 
//    file, RenderMonkey will mangle names for passes, shaders  
//    and function names as necessary to reduce name conflicts. 
//**************************************************************//

//--------------------------------------------------------------//
// Lighting
//--------------------------------------------------------------//
//--------------------------------------------------------------//
// Pass 0
//--------------------------------------------------------------//
string Lighting_Pass_0_Model : ModelData = "..\\..\\..\\Program Files (x86)\\AMD\\RenderMonkey 1.82\\Examples\\Media\\Models\\Sphere.3ds";

float4x4 gWorldMatrix : World;
float4x4 gViewMatrix : View;
float4x4 gProjectionMatrix : Projection;

float4 gWorldLightPosition
<
	string UIName = "gWorldLightPosition";
	string UIWidget = "Direction";
	bool UIVisible = false;
	float4 UIMin = float4(-10.00, -10.00, -10.00, -10.00);
	float4 UIMax = float4(10.00, 10.00, 10.00, 10.00);
	bool Normalize = false;
> = float4(500.00, 500.00, -500.00, 1.00);
float4 gWorldCameraPosition
<
	string UIName = "gWorldCameraPosition";
	string UIWidget = "Direction";
	bool UIVisible = false;
	float4 UIMin = float4(-10.00, -10.00, -10.00, -10.00);
	float4 UIMax = float4(10.00, 10.00, 10.00, 10.00);
	bool Normalize = false;
> = float4(0.00, 0.00, 0.00, 1.00);

struct VS_INPUT
{
	float4 mPosition : POSITION;
	float4 mNormal : NORMAL;
	float2 mTexCoord : TEXCOORD0;
};

struct VS_OUTPUT
{
	float4 mPosition : POSITION;
	float4 mDiffuse : TEXCOORD1;
	float3 mViewDir: TEXCOORD2;
	float3 mReflection : TEXCOORD3;
	float3 mTest : TEXCOORD4;
	float2 mTexCoord : TEXCOORD0;

};

VS_OUTPUT Lighting_Pass_0_Vertex_Shader_vs_main(VS_INPUT Input)
{
	VS_OUTPUT Output;
	Output.mPosition = mul(Input.mPosition, gWorldMatrix);

	float3 lightDir = Output.mPosition.xyz - gWorldLightPosition.xyz;
	lightDir = normalize(lightDir);

	float3 viewDir = normalize(Output.mPosition.xyz - gWorldCameraPosition);
	Output.mViewDir = viewDir;

	Output.mPosition = mul(Output.mPosition, gViewMatrix);
	Output.mPosition = mul(Output.mPosition, gProjectionMatrix);

	float3 worldNormal = mul(Input.mNormal, (float3x3) gWorldMatrix);
	worldNormal = normalize(worldNormal);

	Output.mDiffuse = dot(-lightDir, worldNormal);
	Output.mReflection = reflect(lightDir, worldNormal);

	float3 reflection = normalize(Output.mReflection);

	Output.mTest = saturate(dot(Output.mReflection, viewDir));
	Output.mTest = pow(Output.mTest, 30.0f);
	Output.mTexCoord = Input.mTexCoord;
	return Output;
}


struct PS_INPUT
{
	float3 mDiffuse : TEXCOORD1;
	float3 mViewDir: TEXCOORD2;
	float3 mReflection : TEXCOORD3;
	float3 mTest : TEXCOORD4;
	float2 mTexCoord : TEXCOORD0;
};

texture DiffuseMap_Tex
<
	string ResourceName = "";
> ;

sampler2D DiffuseSampler = sampler_state
{
	Texture = (DiffuseMap_Tex);
};

float4 Lighting_Pass_0_Pixel_Shader_ps_main(PS_INPUT Input) : COLOR
{
   float3 diffuse = saturate(Input.mDiffuse);

   float3 reflection = normalize(Input.mReflection);
   float3 viewDir = normalize(Input.mViewDir);

   float3 specular = 0;

   if (diffuse.x > 0)
   {
	  specular = saturate(dot(reflection, viewDir));
	  specular = pow(specular, 20.0f);
   }

   float3 ambient = float3(0.0f,0.0f,0.0f);
   float3 test = Input.mTest;
   float4 albedo = tex2D(DiffuseSampler, Input.mTexCoord);
   return float4(specular + ambient + diffuse, 1) + albedo;
}




//--------------------------------------------------------------//
// Technique Section for Lighting
//--------------------------------------------------------------//
technique Lighting
{
	pass Pass_0
	{
		VertexShader = compile vs_2_0 Lighting_Pass_0_Vertex_Shader_vs_main();
		PixelShader = compile ps_2_0 Lighting_Pass_0_Pixel_Shader_ps_main();
	}

}

