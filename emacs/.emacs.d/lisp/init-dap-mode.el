;; -*- lexical-binding: t; -*-

(use-package dap-mode
  :ensure t
  :after (lsp-mode)
  :functions dap-hydra/nil
  ;; :hook ((dap-mode . dap-ui-mode)
  ;;        (dap-session-created . (lambda (&_rest) (dap-hydra)))
  ;;        (dap-terminated . (lambda (&_rest) (dap-hydra/nil))))
  :config
  (require 'dap-ui)
  (require 'dap-node)
  (dap-tooltip-mode 1)
  (dap-auto-configure-mode)
  (dap-mode 1))

(with-eval-after-load 'dap-ui
  (setq dap-ui-buffer-configurations
        `((,dap-ui--locals-buffer     . ((side . right)   (slot . 1) (window-width . 0.25)))
          (,dap-ui--expressions-buffer . ((side . right)   (slot . 2) (window-width . 0.25)))
          (,dap-ui--sessions-buffer    . ((side . right)   (slot . 3) (window-width . 0.25)))
          (,dap-ui--breakpoints-buffer . ((side . right)   (slot . 4) (window-width . 0.25)))
          (,dap-ui--debug-window-buffer . ((side . bottom) (slot . 3) (window-width . 0.20)))
          (,dap-ui--repl-buffer        . ((side . bottom) (slot . 1) (window-height . 0.45))))))

(defvar-keymap my/debug-map
  :doc "Debugging commands."
  "d" #'dap-debug
  "b" #'dap-breakpoint-toggle
  "B" #'dap-breakpoint-delete-all
  "c" #'dap-continue
  "n" #'dap-next
  "i" #'dap-step-in
  "o" #'dap-step-out
  "r" #'dap-restart-frame
  "q" #'dap-disconnect
  "e" #'dap-eval
  "R" #'dap-ui-repl
  "I" #'dap-ui-inspect
  "l" #'dap-debug-last
  "L" #'dap-breakpoint-log-message
  "x" #'dap-breakpoint-expression)

(keymap-global-set "C-c d" my/debug-map)

;; JS/TS
(with-eval-after-load 'dap-mode
  (require 'project)

  (defun my/dap-node ()
    "Debug a Node.js entry file in the current project."
    (interactive)
    (let* ((project (project-current nil))
           (root (file-name-as-directory
                  (expand-file-name
                   (if project
                       (project-root project)
                     default-directory))))
           (default-directory root)
           (program (expand-file-name
                     (read-file-name "Node entry file: "
                                     root nil t)
                     root)))
      (unless (file-regular-p program)
        (user-error "Node entry file does not exist: %s" program))

      (dap-debug
       (list :type "node"
             :request "launch"
             :name (format "Node: %s"
                           (file-name-nondirectory
                            (directory-file-name root)))
             :program program
             :cwd root)))))

(keymap-global-set "C-c d N" #'my/dap-node)

(provide 'init-dap-mode)
