
#version 450 core
#extension GL_ARB_separate_shader_objects : enable
#extension GL_EXT_gpu_shader4 : enable
layout(location = 0) in vec3 position;
out vec4 color;

void main()
{
	gl_Position =  vec4(position.xy,1.0f, 1.0f);
	color = vec4(1.0f,1.0f,1.0f,0.0f);

}