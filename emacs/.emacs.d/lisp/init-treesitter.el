;; -*- lexical-binding: t; -*-

(setq treesit-language-source-alist
      '(
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
        (json "https://github.com/tree-sitter/tree-sitter-json")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
        (jsdoc      "https://github.com/tree-sitter/tree-sitter-jsdoc"      "master" "src")
        ))

(defun my/treesit-setup ()
  (interactive)
  (mapc #'treesit-install-language-grammar (mapcar #'car treesit-language-source-alist)))

(provide 'init-treesitter)
