;;;; C and Makefiles  -*- lexical-binding: t; -*-

(setq
 c-default-style '((java-mode . "java") (awk-mode . "awk") (other . "k&r")))

(add-hook 'makefile-mode-hook (lambda () (setq indent-tabs-mode t)))

(provide 'init-c)
