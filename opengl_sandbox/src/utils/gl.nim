import nimgl/opengl
import glm


template printOpenGLVersion* =
  echo "OpenGL Version: " & $glVersionMajor & "." & $glVersionMinor


proc toRGB*(vec: Vec3[float32]): Vec3[float32] =
  vec3(vec.x / 255, vec.y / 255, vec.z / 255)


template clearColorRGB*(rgb: Vec3[float32], alpha: float32) =
  glClearColor(rgb.r, rgb.b, rgb.b, alpha)


template genVertexArrays*(n: GLsizei): var uint32 =
  var vao: uint32
  glGenVertexArrays(n, vao.addr)
  vao


template genBuffers*(n: GLsizei): var uint32 =
  var vbo: uint32
  glGenBuffers(n, vbo.addr)
  vbo


template checkResult*(id: uint32, checkType: untyped, checkExeType: GLenum) =
  var compileResult: int32
  `glGet checkType iv`(id, checkExeType, compileResult.addr)
  if compileResult != GL_TRUE.ord:
    var infoLogLength: int32
    `glGet checkType iv`(id, GL_INFO_LOG_LENGTH, infoLogLength.addr)
    if infoLogLength > 0:
      var message: cstring = newString(infoLogLength)
      `glGet checkType InfoLog`(id, infoLogLength, nil, message[0].addr)
      if message[0] != '\0':
        echo "<" & astToStr(checkType InfoLog) & ">"
        echo message
        quit()


template compileShaderAux(shaderType: GLenum, shaderCode: string): uint32 =
  var id = glCreateShader(shaderType)
  var code: cstring = shaderCode
  glShaderSource(id, 1'i32, code.addr, nil)
  glCompileShader(id)
  id.checkResult(Shader, GL_COMPILE_STATUS)
  id


template compileShader*(shaderType: GLenum, path: static string): uint32 =
  compileShaderAux(shaderType, static staticRead(path))


template compileShader*(shaderType: GLenum, path: string): uint32 =
  compileShaderAux(shaderType, readFile(path))


template linkProgram*(shaders: varargs[uint32]): uint32 =
  var programID: uint32 = glCreateProgram()
  for shader in shaders:
    glAttachShader(programID, shader);
  glLinkProgram(programID);
  programID.checkResult(Program, GL_LINK_STATUS)
  
  # detach and delete shader
  for shader in shaders:
    glDetachShader(programID, shader);
    glDeleteShader(shader)
  
  programID
