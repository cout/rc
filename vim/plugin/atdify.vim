" TODO: Fix this function to work for non-empty files
" TODO: Fix this to work better with nested namespaces 
function ATDify()
  let filename = bufname("%")
  let namespace = input("Namespace: ")
  echo ""
  let def = namespace == "" ? filename : (namespace . "__" . filename)
  let def = substitute(def, "\.\\(.\\)pp$", "__\\1pp_", "g")
  let def = substitute(def, ":", "_", "g")
  let text =
    \  "#ifndef " . def . "\n"
    \. "#define " . def . "\n"
    \. "\n"
  if namespace != ""
    let text = text
          \. "namespace " . namespace . "\n"
          \. "{\n"
          \. "} // namespace " . namespace . "\n"
  endif
  let text = text
    \. "\n"
    \. "#endif // " . def . "\n"
  $put!=text
  nohlsearch
endfunction

map ,a :call ATDify()<cr>

