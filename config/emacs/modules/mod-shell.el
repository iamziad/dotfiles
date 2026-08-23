;;; mod-shell.el

(use-package exec-path-from-shell
  :ensure t
  :config
  (when (or (memq window-system '(x mac))
            (daemonp))
    (exec-path-from-shell-initialize)))

(use-package envrc
  :straight t
  :hook (after-init . envrc-global-mode))

(use-package fish-mode
  :straight t
  :mode (("\\.fish\\'" . fish-mode))
  :hook (fish-mode . (lambda ()
                       (add-hook 'before-save-hook 'fish_indent-before-save))))

;;------------------------------------------------------------------------------
;; Eshell
;;------------------------------------------------------------------------------

(defun my/eshell-git-branch ()
  (when (and (executable-find "git")
             (eq 0 (call-process "git" nil nil nil "rev-parse" "--is-inside-work-tree")))
    (string-trim (shell-command-to-string "git branch --show-current 2>/dev/null"))))

(defun my/eshell-trim-pwd (path)
  (let* ((abbr-path (abbreviate-file-name path))
         (parts (split-string abbr-path "/" t)))
    (if (<= (length parts) 2) abbr-path
      (string-join (last parts 2) "/"))))

(defun my/eshell-prompt ()
  (let* ((branch (my/eshell-git-branch))
         (host   (car (split-string (system-name) "\\."))))
    (concat
     (propertize "["               'face '(:foreground "#d75f5f"))
     (propertize (user-login-name) 'face '(:foreground "#fabd2f"))
     (propertize "@"               'face '(:foreground "#fabd2f"))
     (propertize host              'face '(:foreground "#87afaf"))
     " "
     (propertize (my/eshell-trim-pwd (eshell/pwd)) 'face '(:foreground "#afaf00"))
     (when branch
       (concat
        " "
        (propertize " " 'face '(:foreground "#d75f5f"))
        (propertize branch 'face '(:foreground "#d787af"))))
     (propertize "]" 'face '(:foreground "#d75f5f"))
     (propertize "$ " 'face 'default))))

(setq eshell-prompt-function #'my/eshell-prompt
      eshell-prompt-regexp "\\$ ")

(defun my/toggle-eshell-bottom ()
  (interactive)
  (let* ((eshell-buffer (get-buffer "*eshell*"))
         (desired-height (floor (* (frame-height) 0.45)))
         (new-window (split-window (frame-root-window) (- desired-height) 'below)))
    (select-window new-window)
    (if eshell-buffer (switch-to-buffer eshell-buffer) (eshell))))
(global-set-key (kbd "C-c e") #'my/toggle-eshell-bottom)

(defun my/toggle-eshell-right ()
  (interactive)
  (let* ((eshell-buffer (get-buffer "*eshell*"))
         (desired-width (floor (* (frame-width) 0.45)))
         (new-window (split-window (frame-root-window) (- desired-width) 'right)))
    (select-window new-window)
    (if eshell-buffer (switch-to-buffer eshell-buffer) (eshell))))
(global-set-key (kbd "C-c v e") #'my/toggle-eshell-right)

(defun eshell/clear ()
  (interactive)
  (let ((inhibit-read-only t))
    (erase-buffer)
    (eshell-send-input)))

(add-hook 'eshell-mode-hook (lambda () (local-set-key (kbd "C-n") #'eshell/clear)))

;;------------------------------------------------------------------------------
;; Vterm
;;------------------------------------------------------------------------------

(use-package vterm
  :ensure t
  :config
  (define-key vterm-mode-map (kbd "C-q") nil)
  (add-to-list 'vterm-keymap-exceptions "C-q")
  (add-to-list 'vterm-keymap-exceptions "C-c"))

(use-package multi-vterm
  :ensure t
  :custom
  (multi-vterm-dedicated-window-height-percent 40)
  :bind
  ("C-c t t" . multi-vterm)
  ("C-c t n" . multi-vterm-next)
  ("C-c t p" . multi-vterm-prev)
  ("C-c t r" . multi-vterm-rename)
  ("C-c t T" . my/vterm-new-named))

(defun my/vterm-new-named (name &optional percent)
  (interactive "sTerminal name: ")
  (let* ((percent (or percent 45))
         (height (ceiling (* (frame-height) (/ (float percent) 100)))))
    (select-window (split-window (selected-window) (- height) 'below))
    (multi-vterm)
    (multi-vterm-rename-buffer name)))

(defun my/vterm-project-toggle (&optional side percent)
  (interactive)
  (require 'multi-vterm)
  (let* ((side (or side 'below))
         (percent (or percent 40))
         (name (multi-vterm-project-get-buffer-name))
         (win  (get-buffer-window name)))
    (cond
     (win (if (eq (selected-window) win) (delete-window win) (select-window win)))
     (t
      (let* ((total (if (eq side 'right) (window-width) (window-height)))
             (size (ceiling (* total (/ (float percent) 100)))))
        (select-window (split-window (selected-window) (- size) side)))
      (if (buffer-live-p (get-buffer name))
          (switch-to-buffer name)
        (let ((buf (multi-vterm-get-buffer 'project)))
          (set-buffer buf)
          (multi-vterm-internal)
          (switch-to-buffer buf)))))))

(defun my/vterm-k-dispatch (arg)
  (interactive "P")
  (if arg
      (multi-vterm-dedicated-toggle)
    (my/vterm-project-toggle 'below)))
(global-set-key (kbd "C-c k") #'my/vterm-k-dispatch)

(defun my/vterm-project-toggle-right ()
  (interactive)
  (my/vterm-project-toggle 'right))
(global-set-key (kbd "C-c v k") #'my/vterm-project-toggle-right)

(defun my/switch-vterm-buffer ()
  (interactive)
  (if-let* ((bufs (seq-filter (lambda (b) (with-current-buffer b (derived-mode-p 'vterm-mode)))
                              (buffer-list)))
            (names (mapcar #'buffer-name bufs)))
      (switch-to-buffer (completing-read "Switch to vterm: " names nil t))
    (message "No vterm buffers opened")))
(global-set-key (kbd "C-c b t") #'my/switch-vterm-buffer)

;; Replaced by vterm

;; (defun my/toggle-ansi-term-bottom ()
;;   (interactive)
;;   (let* ((term-buffer (get-buffer "*ansi-term*"))
;;          (desired-height (floor (* (frame-height) 0.45)))
;;          (new-window (split-window (frame-root-window) (- desired-height) 'below)))
;;     (select-window new-window)
;;     (if (buffer-live-p term-buffer)
;;         (switch-to-buffer term-buffer)
;;       (ansi-term my-term-shell))))
;; (global-set-key (kbd "C-c t") #'my/toggle-ansi-term-bottom)

;; (defun my/toggle-ansi-term-right ()
;;   (interactive)
;;   (let* ((term-buffer (get-buffer "*ansi-term*"))
;;          (desired-width (floor (* (frame-width) 0.45)))
;;          (new-window (split-window (frame-root-window) (- desired-width) 'right)))
;;     (select-window new-window)
;;     (if (buffer-live-p term-buffer)
;;         (switch-to-buffer term-buffer)
;;       (ansi-term my-term-shell))))
;; (global-set-key (kbd "C-c v t") #'my/toggle-ansi-term-right)


(provide 'mod-shell)
;;; mod-shell.el ends here
