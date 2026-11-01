;;; -*- lexical-binding: t; -*-

(use-package compile
  :ensure nil
  :config
  (setq compilation-always-kill t
      compilation-ask-about-save nil
      compilation-max-output-line-length nil
      compilation-scroll-output 'first-error))

(provide 'init-compile)
