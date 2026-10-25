;; -*- lexical-binding: t; -*-

(use-package flyspell
  :ensure nil
  :hook ((text-mode . flyspell-mode)
         (prog-mode . flyspell-prog-mode))
  :diminish flyspell-mode)

(provide 'init-spelling)
