#!/usr/bin/env gxi
(import :std/build-script :std/make)

(def libs "x11 glib-2.0 gdk-3.0 atk gcr-3 webkit2gtk-4.0 webkit2gtk-web-extension-4.0 gio-2.0")

(def dir (path-directory (this-source-file)))

(def bootstrap (path-expand "bootstrap/" dir))
(def gerbil-path (getenv "GERBIL_PATH" "~/.gerbil"))
(def libpath (path-expand "lib/drewc/gurf/" gerbil-path))
(def staticpath (path-expand "lib/static" gerbil-path))

(def surf-clean (string-append "rm -rv " (path-expand "drewc/gurf/surf*.*" bootstrap)))

(def surf-pull-bootstrap (string-append "mv " (path-expand "drewc/gurf/surf*.*" bootstrap) " " libpath))
(def surf-pull-static (string-append "mv " (path-expand "static/*.*" bootstrap)
                                     " " staticpath))



(def (surf-build)
  (shell-command surf-clean)
  (shell-command (string-append "mkdir -p " libpath))
  (let bs ()
    (defbuild-script
      `((gxc: "surf"
              "-cc-options"
              ,(string-append
                "-DGCR_API_SUBJECT_TO_CHANGE -DVERSION=\\\"2.2\\\" -DWEBEXTDIR=\\\"usr/local/lib/surf\\\" "
                (pkg-config-cflags libs))
              "-ld-options"
              ,(pkg-config-libs libs)))
      libdir: bootstrap
      verbose: 1)
    (main))
  (shell-command surf-pull-bootstrap)
  (shell-command surf-pull-static))


(def (main . args) (surf-build))
