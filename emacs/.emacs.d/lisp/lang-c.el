;;;; C and Makefiles  -*- lexical-binding: t; -*-

(setq c-ts-mode-indent-offset 4
      c-ts-mode-indent-style 'k&r
      c-default-style '((java-mode . "java") (awk-mode . "awk") (other . "k&r")))

(add-hook 'makefile-mode-hook (lambda () (setq indent-tabs-mode t)))

(provide 'lang-c)
