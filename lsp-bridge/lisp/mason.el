;; -*- lexical-binding: t; -*-
(use-package mason
  :config (mason-setup))

(defconst my/mason-dir
  (file-name-as-directory
   (if (boundp 'mason-dir)
       mason-dir
     (expand-file-name "mason" user-emacs-directory)))
  "Mason's install root (packages live in its \"packages/\" subdirectory).")

(provide 'mason)
