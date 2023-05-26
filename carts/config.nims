--os:linux
--cpu:wasm32
--cc:clang
--listCmd
--mm:orc
--exceptions:goto
--define:noSignalHandler
--noMain:on
--threads:off
--define:release

--clang.exe:emcc
--clang.linkerexe:emcc
--clang.cpp.exe:emcc
--clang.cpp.linkerexe:emcc

switch("import", "./null0")

switch("passL", "--no-entry -sSTANDALONE_WASM=1 -sERROR_ON_UNDEFINED_SYMBOLS=0")
switch("passL", "-o " & projectName() & ".wasm")