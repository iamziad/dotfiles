;;; mod-project.el --- Project management -*- lexical-binding: t; -*-

;; Built-in project.el; no projectile dependency needed for a fresh setup.
(require 'project)
(setq project-vc-extra-root-markers '(".git" "Makefile" "compile_commands.json"))

;; Recognize Maven (pom.xml) and Node (package.json) roots as their own
;; project boundary, even nested inside a larger VC repo - handy in
;; monorepos where project.el's plain VC-root guess is too broad.
(defun my/project-try-local-root (dir)
  (let ((root (or (locate-dominating-file dir "pom.xml")
                  (locate-dominating-file dir "package.json"))))
    (and root (cons 'transient root))))
(with-eval-after-load 'project
  (add-to-list 'project-find-functions #'my/project-try-local-root))

(provide 'mod-project)
;;; mod-project.el ends here
