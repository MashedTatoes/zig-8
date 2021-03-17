
#version 450 core
#extension GL_ARB_separate_shader_objects : enable
#extension GL_EXT_gpu_shader4 : enable
layout(location = 0) in vec4 position;
out vec4 color;
uniform mat4 u_mvp;
uniform vec2 pixelScreenSize;
uniform vec2 pixelSize;
out vec2 pixelPos;
void main()
{
	float pixelX = position.z;
	float pixelY = position.w;
	pixelPos = vec2(pixelX,pixelY);

	gl_Position =  u_mvp * vec4( (pixelX * pixelSize.x) + position.x ,(pixelY * pixelSize.y) + position.y  ,0.0f, 1.0f);
	color = vec4(1.0f,1.0f,1.0f,0.0f);

}