;;; mod-treesitter.el --- Tree-sitter grammars & major modes -*- lexical-binding: t; -*-

;; (use-package treesit-auto
;;   :straight t
;;   :demand t
;;   :custom
;;   (treesit-auto-install 'prompt)
;;   :config
;;   (add-to-list 'auto-mode-alist '("\\.mjs\\'" . typescript-ts-mode))
;;   (global-treesit-auto-mode))

(provide 'mod-treesitter)
;;; mod-treesitter.el ends here

(use-package treesit
  :straight nil
  :mode (("\\.mjs\\'"           . typescript-ts-mode)
         ("\\.ts\\'"            . typescript-ts-mode)
         ("\\.tsx?\\'"          . tsx-ts-mode)
         ("\\.jsx?\\'"          . tsx-ts-mode)
         ("\\.json\\'"          . json-ts-mode)
         ("CMakeLists\\.txt\\'" . cmake-ts-mode)
         ("\\.cmake\\'"         . cmake-ts-mode)
         ("\\.dockerfile\\'"    . dockerfile-ts-mode)
         ("Dockerfile\\'"       . dockerfile-ts-mode)
         ("\\.go\\'"            . go-ts-mode)
         ("/go\\.mod\\'"        . go-mod-ts-mode)
         ("\\.ya?ml\\'"         . yaml-ts-mode))
  :preface
  (defun my/setup-install-grammars ()
    (interactive)
    (dolist (grammar
             '((c "https://github.com/tree-sitter/tree-sitter-c" "v0.24.1")
               (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
               (python "https://github.com/tree-sitter/tree-sitter-python")
               (java "https://github.com/tree-sitter/tree-sitter-java")
               (javascript "https://github.com/tree-sitter/tree-sitter-javascript")
               (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
               (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
               (json "https://github.com/tree-sitter/tree-sitter-json")
               (html "https://github.com/tree-sitter/tree-sitter-html")
               (bash "https://github.com/tree-sitter/tree-sitter-bash")
               (go "https://github.com/tree-sitter/tree-sitter-go")
               (gomod "https://github.com/camdencheek/tree-sitter-go-mod")
               (yaml "https://github.com/ikatyang/tree-sitter-yaml")
               (cmake "https://github.com/uyha/tree-sitter-cmake")
               (make "https://github.com/tree-sitter-grammars/tree-sitter-make")
               (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile")
               (css "https://github.com/tree-sitter/tree-sitter-css")
               (markdown "https://github.com/tree-sitter-grammars/tree-sitter-markdown" "split_parser" "tree-sitter-markdown/src")
               (markdown-inline "https://github.com/tree-sitter-grammars/tree-sitter-markdown" "split_parser" "tree-sitter-markdown-inline/src")))
      (add-to-list 'treesit-language-source-alist grammar)
      (unless (treesit-language-available-p (car grammar))
        (treesit-install-language-grammar (car grammar)))))
  (dolist (mapping
           '((c-mode          . c-ts-mode)
             (c++-mode        . c++-ts-mode)
             (c-or-c++-mode   . c-or-c++-ts-mode)
             (python-mode     . python-ts-mode)
             (java-mode       . java-ts-mode)
             (js-mode         . typescript-ts-mode)
             (sh-mode         . bash-ts-mode)
             (html-mode       . html-ts-mode)
             (mhtml-mode      . html-ts-mode)
             (css-mode        . css-ts-mode)
             (makefile-mode   . makefile-ts-mode)))
    (add-to-list 'major-mode-remap-alist mapping))
  :config
  (my/setup-install-grammars))

(provide 'mod-treesitter)
;;; mod-treesitter.el ends here
