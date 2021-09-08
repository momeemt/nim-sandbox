import nimgl/[glfw, opengl], glm

proc keyProc(window: GLFWWindow, key: int32, scancode: int32,
             action: int32, mods: int32): void {.cdecl.} =
  if key == GLFWKey.ESCAPE and action == GLFWPress:
    window.setWindowShouldClose(true)

proc createProgram (): GLuint =
  const
    vertexShaderConst = staticRead("shader.vert")
    #vertexShader = vertexShaderFile.cstring
    fragmentShaderConst = staticRead("shader.frag")
    #fragmentShader = fragmentShaderFile.readAll.cstring
  var
    vertexShader = vertexShaderConst.cstring
    fragmentShader = fragmentShaderConst.cstring
    program = glCreateProgram()
    status = GL_FALSE.GLint
    infoLogLength: GLsizei
    vertexShaderObj = glCreateShader(GL_VERTEX_SHADER)
    fragmentShaderObj = glCreateShader(GL_FRAGMENT_SHADER)
  
  glShaderSource(vertexShaderObj, 1, vertexShader.addr, nil)
  glCompileShader(vertexShaderObj)
  glAttachShader(program, vertexShaderObj)

  glGetShaderiv(vertexShaderObj, GL_COMPILE_STATUS, status.addr)
  glGetShaderiv(vertexShaderObj, GL_INFO_LOG_LENGTH, infoLogLength.addr)

  glDeleteShader(vertexShaderObj)

  glShaderSource(fragmentShaderObj, 1, fragmentShader.addr, nil)
  glCompileShader(fragmentShaderObj)
  glAttachShader(program, fragmentShaderObj)

  glGetShaderiv(fragmentShaderObj, GL_COMPILE_STATUS, status.addr)
  glGetShaderiv(fragmentShaderObj, GL_INFO_LOG_LENGTH, infoLogLength.addr)
  glDeleteShader(fragmentShaderObj)

  glLinkProgram(program)
  glGetProgramiv(program, GL_LINK_STATUS, status.addr)
  glGetProgramiv(program, GL_INFO_LOG_LENGTH, infoLogLength.addr)
  result = program

proc main() =
  assert glfwInit()

  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);
  glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE.int32);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

  let w: GLFWWindow = glfwCreateWindow(800, 600, "NimGL")
  if w == nil:
    quit(-1)

  discard w.setKeyCallback(keyProc)
  w.makeContextCurrent()

  assert glInit()

  var program = createProgram()

  var
    vertices = @[
      vec3(0.0f, 0.5f, 0.0f),
      vec3(-0.5f, -0.5f, 0.0f),
      vec3(0.5f, -0.5f, 0.0f)
    ]

    colors = @[
      vec3(1.0f, 0.0f, 0.0f),
      vec3(0.0f, 1.0f, 0.0f),
      vec3(0.0f, 0.0f, 1.0f)
    ]

  var vao: GLuint
  glGenVertexArrays(1, vao.addr)
  glBindVertexArray(vao)

  var verticesVbo: GLuint
  glGenBuffers(1, verticesVbo.addr)
  glBindBuffer(GL_ARRAY_BUFFER, verticesVbo)
  glBufferData(GL_ARRAY_BUFFER, vertices.len * sizeof(vec3), vertices[0].addr, GL_STATIC_DRAW)
  glEnableVertexAttribArray(0)
  glVertexAttribPointer(0, 3, 0x1406.GLenum, GL_FALSE.GLBoolean, 0.GLsizei, cast[pointer](0))

  var colorsVbo: GLuint
  glGenBuffers(1, colorsVbo.addr)
  glBindBuffer(GL_ARRAY_BUFFER, colorsVbo)
  glBufferData(GL_ARRAY_BUFFER, colors.len * sizeof(vec3), colors[0].addr, GL_STATIC_DRAW)
  glEnableVertexAttribArray(1)
  glVertexAttribPointer(1, 3, 0x1406.GLenum, GL_FALSE.GLBoolean, 0, cast[pointer](0))

  while not w.windowShouldClose:
    glClear(GL_COLOR_BUFFER_BIT)

    glUseProgram(program)
    glBindVertexArray(vao)
    glDrawArrays(GL_TRIANGLES, 0, vertices.len.GLsizei)

    w.swapBuffers()
    glfwPollEvents()

  w.destroyWindow()
  glfwTerminate()

main()

# テクスチャを貼る（課題）
# FFMpegのピクセルデータからテクスチャを構成できるので.