odin build src/ -out:dist/romper.$1 -collection:lib=./lib -build-mode:dll $2
odin build src/ -out:example/bin/romper.$1 -collection:lib=./lib -build-mode:dll $2
