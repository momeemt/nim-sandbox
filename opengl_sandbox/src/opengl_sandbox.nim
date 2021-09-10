import glm
import nimgl/glfw
import nimgl/opengl
import utils
import utils/gl

proc keyProc(window: GLFWWindow, key: int32, scancode: int32, action: int32, mods: int32): void {.cdecl.} =
  if key == GLFWKey.Escape and action == GLFWPress:
    window.setWindowShouldClose(true)

proc triangle* (vpositions: array[3, Vec3f], vcolors: array[3, Vec4f], sizei: GLsizei): tuple[vao, vbo: uint32] =
  glGenVertexArrays(sizei, result.vao.addr)
  glGenBuffers(sizei, result.vbo.addr)
  var vertices = [
    vpositions[0][0], vpositions[0][1], vpositions[0][2],
    vcolors[0][0], vcolors[0][1], vcolors[0][2], vcolors[0][3],
    vpositions[1][0], vpositions[1][1], vpositions[1][2],
    vcolors[1][0], vcolors[1][1], vcolors[1][2], vcolors[1][3],
    vpositions[2][0], vpositions[2][1], vpositions[2][2],
    vcolors[2][0], vcolors[2][1], vcolors[2][2], vcolors[2][3],
  ]
  glBindVertexArray(result.vao)
  glBindBuffer(GL_ARRAY_BUFFER, result.vbo)
  glBufferData(GL_ARRAY_BUFFER, cint(sizeof(cfloat) * vertices.len), vertices[0].addr, GL_STATIC_DRAW)


proc main* =
  # init GLFW
  doAssert glfwInit()

  # GLFW settings
  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE) # To make MacOS happy
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE) # We don't want the old OpenGL
  glfwWindowHint(GLFWResizable, GLFW_FALSE) # disable window resize

  # create window
  let w: GLFWWindow = glfwCreateWindow(800, 600, "NimGL", nil, nil)
  doAssert w != nil

  discard w.setKeyCallback(keyProc)
  w.makeContextCurrent()

  # init OpenGL
  doAssert glInit()
  gl.printOpenGLVersion()

  # my first triangle!
  let vpositions1 = [
    vec3f(-0.3, -0.3, 0.0),
    vec3f( 0.3, -0.3, 0.0),
    vec3f( 0.3,  0.3, 0.0)
  ]
  let vcolors1 = [
    vec4f(1, 0, 0, 0),
    vec4f(1, 0, 0, 0),
    vec4f(1, 0, 0, 0)
  ]

  let vpositions2 = [
    vec3f(-0.6, -0.6, 0.0),
    vec3f(-0.2, -0.6, 0.0),
    vec3f(-0.2, -0.2, 0.0)
  ]
  let vcolors2 = [
    vec4f(0, 1, 0, 0),
    vec4f(0, 1, 0, 0),
    vec4f(0, 1, 0, 0)
  ]

  var
    (vao1, vbo1) = triangle(vpositions1, vcolors1, 0)
    (vao2, vbo2) = triangle(vpositions2, vcolors2, 1)
  # var vertices = ...(
  #   vpositions[0], vcolors[0],
  #   vpositions[1], vcolors[1],
  #   vpositions[2], vcolors[2],
  #   vpositions[3], vcolors[3]
  # ) # インターリブ配列 メモリアクセスを効率化してる

  # create vao
  # 頂点バッファ　バッファの配列 GPUの方にメモリを確保
  # var vao = gl.genVertexArrays(1)
  # vaoを指定している
  # glBindVertexArray(vao)
  
  # create vbo
  # バッファ vboはvaoに結びつく
  # var vbo = gl.genBuffers(1)
  # glBindBuffer(GL_ARRAY_BUFFER, vbo)
  # glBufferData(GL_ARRAY_BUFFER, cint(sizeof(cfloat) * vertices.len), vertices[0].addr, GL_STATIC_DRAW)

  # set vertex positions
  # 引数レジスタ　0番目を使う宣言 （最初は空いてない）
  glEnableVertexAttribArray(0)
  # index: 頂点シェーダーの location=index の変数と紐づけてる
  # offset: nil -> 0として扱われていそう
  glVertexAttribPointer(0, 3, EGL_FLOAT, false, 7 * sizeof(cfloat), nil)
  # stride 7 * sizeof(cfloat) は次の変数がどれだけメモリが空いているか
  
  # set vertex colors
  glEnableVertexAttribArray(1)
  glVertexAttribPointer(1, 4, EGL_FLOAT, false, 7 * sizeof(cfloat), cast[pointer](3 * sizeof(cfloat)))
  
  # deselect vbo, vao
  glBindBuffer(GL_ARRAY_BUFFER, 0)
  glBindVertexArray(0)

  # texture
  var texture_id: GLuint
  # glGenTextures(0, texture_id.addr)
  # https://nn-hokuson.hatenablog.com/entry/2017/02/24/171230
  # テクスチャはかなり容易に実装できそう
  # Nimでは手軽に画像を読み込めないのでダメだった
  
  # compile shaders
  let programID = linkProgram(
    compileShader(GL_VERTEX_SHADER, ~"shaders/triangle/vertex_shader.glsl"),
    compileShader(GL_FRAGMENT_SHADER, ~"shaders/triangle/fragment_shader.glsl")
  )
  # program: シェーダーを複数組み合わせたものを言う
  # vertex_shader, fragment_shaderをそれぞれコンパイルしてリンクする

  # app main loop
  while not w.windowShouldClose:
    # clear background
    gl.clearColorRGB(vec3f(33, 33, 33).toRGB, 1f) #クリアの方法を規定してる, 毎回呼ぶ必要はない
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
    
    # use shader
    glUseProgram(programID)

    # select vao
    glBindVertexArray(vao1)
    glBindVertexArray(vao2)
    glDrawArrays(GL_TRIANGLE_FAN, 0, 3) # draw triangle

    # deselect vao
    glBindVertexArray(0)

    
    # swap buffers
    w.swapBuffers()

    # poll events
    glfwPollEvents()
    
  # app exit
  w.destroyWindow()
  glfwTerminate()

  glDeleteVertexArrays(1, vao1.addr)
  glDeleteVertexArrays(1, vao2.addr)

main()