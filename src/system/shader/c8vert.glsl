
#version 450 core
#extension GL_ARB_separate_shader_objects : enable
#extension GL_EXT_gpu_shader4 : enable
layout(location = 0) in vec2 position;
out vec4 color;
uniform mat4 u_mvp;
void main()
{
	gl_Position = u_mvp * vec4(position,1.0f, 1.0f);
	color = vec4(1.0f,1.0f,1.0f,1.0f);

}