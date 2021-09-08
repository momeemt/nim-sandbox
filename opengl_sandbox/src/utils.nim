import std/macros
import glm


# returns reletive path
template `~`*(path: string): string =
  when nimvm:
    getProjectPath() & "/../" & path
  else:
    "/" & path


macro `...`*(args: varargs[typed]): untyped =
  result = newStmtList()
  result.add newNimNode(nnkBracket)
  for node in args[0]:
    # if node.kind != nnkBracketExpr:
      # error("not a vec")
    let sym = node[0]
    let impl = sym.getImpl
    # let ty = impl[2][0][0]
    let idx = node[1][1]
    for i in 0 ..< impl[2][0].len - 1:
      result[0].add quote do:
        `sym`[`idx`].arr[`i`]