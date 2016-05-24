#!/usr/bin/env ocaml
#directory "pkg";;
#use "topkg.ml";;

let () =
  Pkg.describe "bourso" ~builder:`OCamlbuild [
    (* Pkg.lib "pkg/META"; *)
    Pkg.bin ~auto:true "src/bourso"
    (* Pkg.doc "README.md"; *)
    (* Pkg.doc "CHANGES.md"; *)
  ]
