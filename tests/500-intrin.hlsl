
// `fxc can treat intermediate intrinsic results as double while optimizing the code..`
// `..or reorder commutative ops, which is why some values are explicitly assigned to variables`

// `abs`
source `
float2x3 MTX;
float4 main( float4 p : POSITION ) : POSITION
{
	return abs( true ) + abs( 0 ) + abs( 0.0 ) + abs( p ) + abs( MTX )._11_12_13_22;
}`
compile_hlsl_before_after ``
compile_glsl ``
source_replace `float2x3=>float3x3`
compile_glsl_es100 ``

// `acos`
source `
float2x3 MTX;
float4 main( float4 p : POSITION ) : POSITION
{
	return acos( 0 ) + acos( true ) + acos( 0.5 ) + acos( p ) + acos( MTX )._11_12_13_22;
}`
compile_hlsl_before_after ``
compile_glsl ``
source_replace `float2x3=>float3x3`
compile_glsl_es100 ``

// `all`
source `
float2x3 MTX;
float4 main( float4 p : POSITION ) : POSITION
{
	return all( true ) + all( 1 ) + all( 0.5 ) + all( p ) + all( MTX );
}`
compile_hlsl_before_after ``

// `any`
source `
float2x3 MTX;
float4 main( float4 p : POSITION ) : POSITION
{
	return any( true ) + any( 1 ) + any( 0.5 ) + any( p ) + any( MTX );
}`
compile_hlsl_before_after ``

// `asin`
source `
float2x3 MTX;
float4 main( float4 p : POSITION ) : POSITION
{
	return asin( true ) + asin( 0 ) + asin( 0.5 ) + asin( p ) + asin( MTX )._11_12_13_22;
}`
compile_hlsl_before_after ``
compile_glsl ``
source_replace `float2x3=>float3x3`
compile_glsl_es100 ``

// `atan`
source `
float2x3 MTX;
float4 main( float4 p : POSITION ) : POSITION
{
	float b = atan( 0.5 );
	return atan( 0 ) + atan( true ) + b + atan( p ) + atan( MTX )._11_12_13_22;
}`
compile_hlsl_before_after ``
compile_glsl ``
source_replace `float2x3=>float3x3`
compile_glsl_es100 ``

// `atan2`
source `
float2x3 MTX;
float4 main( float4 p : POSITION ) : POSITION
{
	float q = atan2( 0, true );
	float a = atan2( true, 1 );
	float b = atan2( 0.5, -0.5 );
	float4 c = atan2( p, 0.5 );
	return q + a + b + c
		+ atan2( MTX, 1.5 )._11_12_13_22;
}`
compile_hlsl_before_after ``
compile_glsl ``
source_replace `float2x3=>float3x3`
compile_glsl_es100 ``

// `clip`
source `
float2x3 MTX;
float4 main( float4 p : COLOR ) : COLOR
{
	clip( 1 );
	clip( true );
	clip( 0.5 );
	clip( p );
	return p;
}`
compile_hlsl_before_after `/T ps_3_0`
compile_glsl `-S frag`
in_shader `discard`
compile_glsl_es100 `-S frag`
in_shader `discard`

// `cross`
source `
float4 main( float3 p : POSITION ) : POSITION
{
	return ( cross( 4, 5 ) + cross( true, false ) + cross( 0.5, 0.6 ) + cross( p, p ) ).xyzz;
}`
compile_hlsl_before_after ``
compile_glsl ``
compile_glsl_es100 ``

// `ddx`
source `
float4 main(float4 p : TEXCOORD) : COLOR
{
	return ddx(p.x) + ddx(p.xy).xyxy + ddx(p.xyz).xyzx + ddx(p);
}`
compile_hlsl_before_after `/T ps_3_0`
compile_glsl `-S frag`
in_shader `dFdx`
compile_glsl_es100 `-S frag`
in_shader `dFdx`

// `ddy`
source `
float4 main(float4 p : TEXCOORD) : COLOR
{
	return ddy(p.x) + ddy(p.xy).xyxy + ddy(p.xyz).xyzx + ddy(p);
}`
compile_hlsl_before_after `/T ps_3_0`
compile_glsl `-S frag`
in_shader `dFdy`
compile_glsl_es100 `-S frag`
in_shader `dFdy`

// `distance`
source `
float4 main( float3 p : POSITION ) : POSITION
{
	return distance( 4, 5 ) + distance( true, false ) + distance( 0.5, 0.6 ) + distance( p, p );
}`
compile_hlsl_before_after ``
compile_glsl ``
compile_glsl_es100 ``

// `dot`
source `
float4 main( float3 p : POSITION ) : POSITION
{
	return dot( 4, 5 ) + dot( true, false ) + dot( 0.5, 0.6 ) + dot( p, p );
}`
compile_hlsl_before_after ``
compile_glsl ``
compile_glsl_es100 ``

// `fwidth`
source `
float4 main(float4 p : TEXCOORD) : COLOR
{
	return fwidth(p.x) + fwidth(p.xy).xyxy + fwidth(p.xyz).xyzx + fwidth(p);
}`
compile_hlsl_before_after `/T ps_3_0`
compile_glsl `-S frag`
compile_glsl_es100 `-S frag`

// `matrixCompMult (GLSL)`
source `
float2x3 MTX1;
float2x3 MTX2;
float4 main(float4 p : POSITION) : POSITION
{
	return p * (MTX1 * MTX2)._11_12_13_22;
}`
compile_hlsl_before_after ``
compile_glsl ``
in_shader `matrixCompMult`
source_replace `float2x3=>float3x3`
compile_glsl_es100 ``
in_shader `matrixCompMult`

// `mod (GLSL)`
source `
float2x3 MTX1;
float2x3 MTX2;
float4 main(float4 p : POSITION) : POSITION
{
	return (p % float4(1,2,3,4)) * (MTX1 % MTX2)._11_12_13_22;
}`
compile_hlsl_before_after ``
compile_glsl ``
in_shader `mod`
source_replace `float2x3=>float3x3`
compile_glsl_es100 ``
in_shader `mod`

// `normalize`
source `
float4 main( float4 p : POSITION ) : POSITION
{
	return normalize( 4 ) + normalize( true ) + normalize( 0.5 ) + normalize( p );
}`
compile_hlsl_before_after ``
compile_glsl ``
compile_glsl_es100 ``

// `rsqrt`
source `
float4 main( float4 p : POSITION ) : POSITION
{
	return rsqrt( 4 ) + rsqrt( true ) + rsqrt( 0.5 ) + rsqrt( p );
}`
compile_hlsl_before_after ``
compile_glsl ``
compile_glsl_es100 ``

// `sqrt`
source `
float4 main( float4 p : POSITION ) : POSITION
{
	return sqrt( 4 ) + sqrt( true ) + sqrt( 0.5 ) + sqrt( p );
}`
compile_hlsl_before_after ``
compile_glsl ``
compile_glsl_es100 ``

// `tex2Dgrad`
source `
sampler2D Sampler;
float4 main( float2 p : TEXCOORD ) : COLOR
{
	return tex2Dgrad( Sampler, 4, 5, 6 ) + tex2Dgrad( Sampler, true, false, true )
		+ tex2Dgrad( Sampler, 0.5, 0.6, 0.7 ) + tex2Dgrad( Sampler, p, p, p );
}`
compile_hlsl_before_after `/T ps_3_0`

// `tex2Dlod`
source `
sampler2D Sampler : register(s2);
float4 main( float4 p : POSITION ) : POSITION
{
	return tex2Dlod( Sampler, 4 ) + tex2Dlod( Sampler, true )
		+ tex2Dlod( Sampler, 0.5 ) + tex2Dlod( Sampler, p );
}`
compile_hlsl_before_after ``
