(lang dune 3.17)

(generate_opam_files true)

(name taxi)

(version 2024.0.1)

(maintainers "Ryan M. Moore")

(authors "Ryan M. Moore")

(homepage "https://github.com/mooreryan/taxi")

(source
 (github mooreryan/taxi))

(documentation "https://mooreryan.github.io/taxi/")

(bug_reports "https://github.com/mooreryan/taxi/issues")

(package
 (name taxi)
 (synopsis "Sparkling tools for dealing with the NCBI Taxonomy")
 (depends
  (ocaml
   (= "5.2.1"))
  (cmdliner
   (>= "1.3.0"))
  (core
   (>= "v0.17.0"))
  (core_unix
   (>= "v0.17.0"))
  (logs
   (>= "0.7.0"))
  (fmt
   (>= "0.9.0"))
  (ocamlformat
   (= "0.26.2"))
  (ppx_jane
   (>= "v0.17.0"))
  (re
   (>= "1.12.0"))))
