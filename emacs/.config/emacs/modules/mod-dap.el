;; ;; -*- lexical-binding: t; -*-
;; (use-package dap-mode
;;   :straight nil
;;   :config
;;   (require 'dap-java)
;;   (require 'dap-node)
;;   (require 'dap-ui)
;;   (dap-tooltip-mode 1)
;;   (dap-auto-configure-mode)

;;   (setq dap-ui-buffer-configurations
;;         `((,dap-ui--locals-buffer      . ((side . right)   (slot . 1) (window-width . 0.25)))
;;           (,dap-ui--expressions-buffer . ((side . right)   (slot . 2) (window-width . 0.25)))
;;           (,dap-ui--sessions-buffer    . ((side . right)   (slot . 3) (window-width . 0.25)))
;;           (,dap-ui--breakpoints-buffer . ((side . right)   (slot . 4) (window-width . 0.25)))
;;           (,dap-ui--debug-window-buffer . ((side . bottom) (slot . 3) (window-width . 0.20)))
;;           (,dap-ui--repl-buffer        . ((side . bottom) (slot . 1) (window-height . 0.45))))))

;; (defun my/dap-node-debug ()
;;   (interactive)
;;   (dap-debug
;;    (list :type "node"
;;          :request "launch"
;;          :name "Node::Run"
;;          :program (expand-file-name (buffer-file-name))
;;          :cwd (expand-file-name default-directory))))

;; (provide 'mod-dap)

;; -*- lexical-binding: t; -*-
(use-package dap-mode
  :straight nil
  :config
  (require 'dap-java)
  (require 'dap-node)
  (require 'dap-ui)
  (dap-tooltip-mode 1)
  (dap-auto-configure-mode)

  (setq dap-ui-buffer-configurations
        `((,dap-ui--locals-buffer     . ((side . right)   (slot . 1) (window-width . 0.25)))
          (,dap-ui--expressions-buffer . ((side . right)   (slot . 2) (window-width . 0.25)))
          (,dap-ui--sessions-buffer    . ((side . right)   (slot . 3) (window-width . 0.25)))
          (,dap-ui--breakpoints-buffer . ((side . right)   (slot . 4) (window-width . 0.25)))
          (,dap-ui--debug-window-buffer . ((side . bottom) (slot . 3) (window-width . 0.20)))
          (,dap-ui--repl-buffer        . ((side . bottom) (slot . 1) (window-height . 0.45))))))

(defun my/dap-node-debug ()
  (interactive)
  (dap-debug
   (list :type "node"
         :request "launch"
         :name "Node::Run"
         :program (expand-file-name (buffer-file-name))
         :cwd (expand-file-name default-directory))))

;; إعداد Hydra للتحكم السريع في dap-mode
(use-package hydra
  :defer t
  :config
  (defhydra hydra-dap (:color pink :hint nil)
    "
^Control^          ^Breakpoints^          ^Evaluate^         ^Debugging^
--------------------------------------------------------------------------------
[_n_] next         [_b_] toggle breakpoint [_e_] eval region  [_c_] continue
[_i_] step in      [_d_] delete breakpoint [_r_] eval repl    [_q_] disconnect
[_o_] step out     [_l_] list breakpoints  [_h_] eval thing   [_x_] restart
[_s_] start/run    [_K_] delete all                           [_Q_] quit hydra
"
    ("c" dap-continue "continue" :exit t)
    ("n" dap-next "next")
    ("i" dap-step-in "step in")
    ("o" dap-step-out "step out")
    ("s" dap-debug "start" :exit t)
    ("b" dap-breakpoint-toggle "toggle breakpoint")
    ("d" dap-breakpoint-delete "delete breakpoint")
    ("l" dap-ui-breakpoints "list breakpoints")
    ("K" dap-breakpoint-delete-all "delete all breakpoints")
    ("e" dap-eval "eval region")
    ("r" dap-ui-repl "eval repl")
    ("h" dap-eval-thing-at-point "eval thing")
    ("q" dap-disconnect "disconnect" :exit t)
    ("x" dap-restart "restart" :exit t)
    ("Q" nil "quit" :exit t)))

;; ربط الـ Hydra باختصار مناسب (مثلاً C-c d)
(global-set-key (kbd "C-c d") #'hydra-dap/body)

(provide 'mod-dap)
