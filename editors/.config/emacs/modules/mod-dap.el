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
        `((,dap-ui--locals-buffer      . ((side . left)   (slot . 1) (window-width . 0.25)))
          (,dap-ui--expressions-buffer . ((side . left)   (slot . 2) (window-width . 0.25)))
          (,dap-ui--sessions-buffer    . ((side . left)   (slot . 3) (window-width . 0.25)))
          (,dap-ui--breakpoints-buffer . ((side . left)   (slot . 4) (window-width . 0.25)))
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

(provide 'mod-dap)
