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
  ;; :custom
  ;; (vterm-shell (executable-find "bash"))
  ;; (vterm-tramp-shells '(("sudo" "/run/current-system/sw/bin/bash")
  ;;                       ("ssh"  "/run/current-system/sw/bin/bash")))
  :config
  (define-key vterm-mode-map (kbd "C-q") nil)
  (add-to-list 'vterm-keymap-exceptions "C-q")
  (add-to-list 'vterm-keymap-exceptions "C-c"))

(defun my/vterm-buffer-name ()
  (let ((dir-name (file-name-nondirectory (directory-file-name default-directory))))
    (format "*vterm: %s*" dir-name)))

(defun my/get-or-create-vterm ()
  "Get existing vterm buffer for current dir, or create it without
disturbing the current window layout."
  (let ((buf-name (my/vterm-buffer-name)))
    (or (get-buffer buf-name)
        (progn
          (save-window-excursion (vterm buf-name))
          (get-buffer buf-name)))))

(defun my/find-vterm-window ()
  (catch 'found
    (walk-windows
     (lambda (w)
       (with-current-buffer (window-buffer w)
         (when (derived-mode-p 'vterm-mode)
           (throw 'found w))))
     nil
     'visible)))

(defun my/vterm-display-buffer (buf &optional direction)
  "Toggle-display BUF in a vterm window.
DIRECTION is `below' (default) or `right'."
  (let ((vterm-win (my/find-vterm-window))
        (direction (or direction 'below)))
    (cond
     ;; already open and focused -> close it
     ((and vterm-win (eq vterm-win (selected-window)))
      (delete-window vterm-win))
     ;; already open but not focused -> jump to it and switch buffer
     (vterm-win
      (select-window vterm-win)
      (switch-to-buffer buf))
     ;; not open -> split and open
     (t
      (let* ((size (if (eq direction 'below)
                       (floor (* (frame-height) 0.45))
                     (floor (* (frame-width) 0.45))))
             (new-window (split-window (frame-root-window) (- size) direction)))
        (select-window new-window)
        (switch-to-buffer buf))))))

(defun my/open-vterm-bottom ()
  (interactive)
  (my/vterm-display-buffer (my/get-or-create-vterm) 'below))
(global-set-key (kbd "C-c k") #'my/open-vterm-bottom)

(defun my/open-vterm-right ()
  (interactive)
  (my/vterm-display-buffer (my/get-or-create-vterm) 'right))
(global-set-key (kbd "C-c v k") #'my/open-vterm-right)

(defun my/switch-vterm-buffer ()
  (interactive)
  (let* ((vterm-buffers
          (seq-filter
           (lambda (buf)
             (with-current-buffer buf
               (derived-mode-p 'vterm-mode)))
           (buffer-list)))
         (buffer-names (mapcar #'buffer-name vterm-buffers)))
    (if buffer-names
        (my/vterm-display-buffer
         (get-buffer (completing-read "Switch to vterm: " buffer-names nil t))
         'below)
      (message "No vterm buffers opened"))))
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
