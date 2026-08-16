;;; mod-crux.el --- Ridiculously useful editing commands -*- lexical-binding: t; -*-

;; Two crux commands are intentionally left unbound here - see notes below.

(use-package crux
  :bind (([remap move-beginning-of-line] . crux-move-beginning-of-line)
         ([remap kill-whole-line]        . crux-kill-whole-line)
         ("S-<return>"                   . crux-smart-open-line)
         ("C-S-<return>"                 . crux-smart-open-line-above)
         ("C-c d"                        . crux-duplicate-current-line-or-region)
         ("C-c D"                        . crux-delete-file-and-buffer)
         ("C-c R"                        . crux-rename-file-and-buffer) ; capital R: lowercase C-c r is core's recentf
         ("C-c u"                        . crux-view-url)
         ("C-c e"                        . crux-eval-and-replace)))

;; Not bound by default:
;;   crux-open-with        - C-c o already belongs to mod-olivetti's toggle
;;   crux-smart-kill-line   - C-k already belongs to mod-nav's next-line
;; Both are still reachable via M-x, or bind them yourself on a free key.

(provide 'mod-crux)
;;; mod-crux.el ends here
