;;; -*- lexical-binding: t; -*-

(setq compilation-always-kill t)
(setq compilation-ask-about-save nil)
(setq compilation-max-output-line-length nil)
(setq compilation-scroll-output 'first-error)

(advice-add 'compilation-start :after
            (lambda (&rest _)
              (when-let* ((w (get-buffer-window "*compilation*")))
                (select-window w))))

(provide 'init-compile)
