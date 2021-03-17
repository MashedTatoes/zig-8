
#version 450 core
#extension GL_ARB_separate_shader_objects : enable
out vec4 fragColor;
uniform vec4 u_color;
in vec4 color;
void main()
{
	fragColor = vec4(1.0,1.0,1.0,1.0);
}