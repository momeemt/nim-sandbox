#version 330 core
layout(location = 0) in vec3 vertexPosition_modelspace;
layout(location = 1) in vec4 vertexColor;

out vec4 color;
// 重心座標系で値が計算されて渡される

void main() {
  gl_Position.xyz = vertexPosition_modelspace;
  gl_Position.w = 1.0;
  color = vertexColor;
}

//画面上のどこに移すかを計算する