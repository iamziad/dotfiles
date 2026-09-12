;;------------------------------------------------------------------------------
;; Vterm
;;------------------------------------------------------------------------------

(use-package vterm
  :ensure t
  :demand t
  :bind
  (("C-c k"   . my/vterm-project-toggle)
   ("C-`"     . my/vterm-project-toggle-split)
   ("C-c v n" . my/vterm-project-new)
   ("C-c v d" . my/vterm-project-kill-all)
   ("C-c v D" . my/vterm-project-kill-one)
   ("C-c v l" . my/vterm-project-list))
  :config
  (require 'project)
  (define-key vterm-mode-map (kbd "C-q") nil)
  (add-to-list 'vterm-keymap-exceptions "C-q")
  (add-to-list 'vterm-keymap-exceptions "C-c"))

(defvar-local my/vterm-project-root nil
  "Project root this vterm buffer belongs to.")

(defvar-local my/vterm-project-label nil
  "Optional label distinguishing this vterm buffer from the project's default one.")

(defun my/project-root ()
  "Return the root of the current project, or DEFAULT-DIRECTORY if none."
  (if-let ((proj (project-current)))
      (project-root proj)
    default-directory))

(defun my/vterm-create (root &optional label)
  "Create a new vterm buffer rooted at ROOT, optionally tagged with LABEL."
  (let* ((pname (file-name-nondirectory (directory-file-name root)))
         (bufname (generate-new-buffer-name
                   (if label
                       (format "*vterm:%s:%s*" pname label)
                     (format "*vterm:%s*" pname))))
         (buf (generate-new-buffer bufname)))
    (with-current-buffer buf
      (setq default-directory root)
      (vterm-mode)
      (setq my/vterm-project-root root
            my/vterm-project-label label))
    buf))

(defun my/vterm-buffers-for-project (root)
  "Return all live vterm buffers belonging to project ROOT."
  (seq-filter
   (lambda (buf)
     (with-current-buffer buf
       (and (derived-mode-p 'vterm-mode)
            (equal my/vterm-project-root root))))
   (buffer-list)))

(defun my/vterm-find-main (root)
  "Return the default (unlabeled) vterm buffer for ROOT, if it exists."
  (seq-find (lambda (buf)
              (with-current-buffer buf
                (null my/vterm-project-label)))
            (my/vterm-buffers-for-project root)))

(defvar-local my/vterm-return-buffer nil
  "Buffer to jump back to when leaving this vterm buffer via toggle.")

(defun my/vterm-project-toggle-1 (display-action)
  "Shared logic for toggling the default project vterm.
DISPLAY-ACTION is passed to `pop-to-buffer' when jumping *into*
the vterm buffer. Jumping back out always restores the previous
buffer full-frame, regardless of how you entered."
  (let* ((root (my/project-root))
         (buf (my/vterm-find-main root)))
    (if (eq (current-buffer) buf)
        (if (buffer-live-p my/vterm-return-buffer)
            (pop-to-buffer my/vterm-return-buffer '(display-buffer-full-frame))
          (previous-buffer))
      (let ((return-buf (current-buffer))
            (target (or buf (my/vterm-create root))))
        (unless (derived-mode-p 'vterm-mode)
          (with-current-buffer target
            (setq my/vterm-return-buffer return-buf)))
        (pop-to-buffer target display-action)))))

(defun my/vterm-project-toggle ()
  "Toggle the default project vterm, full-frame.
From anywhere else in the project, jump into it (creating it if
needed), remembering the last non-vterm buffer you came from.
From inside it, jump back to that buffer."
  (interactive)
  (my/vterm-project-toggle-1 '(display-buffer-full-frame)))

(defun my/vterm-project-toggle-split ()
  "Toggle the default project vterm in a horizontal split.
Same as `my/vterm-project-toggle', but shows the vterm buffer in
a split at the bottom of the frame occupying 45% of its height,
instead of taking over the whole frame."
  (interactive)
  (my/vterm-project-toggle-1
   '(display-buffer-at-bottom
     (window-height . 0.45))))

(defun my/vterm-project-new (name)
  "Create a new, named vterm buffer inside the current project."
  (interactive "sTerminal name: ")
  (pop-to-buffer (my/vterm-create (my/project-root) name) '(display-buffer-full-frame)))

(defun my/vterm-all-buffers ()
  "Return every live vterm buffer, across all projects."
  (seq-filter (lambda (buf) (with-current-buffer buf (derived-mode-p 'vterm-mode)))
              (buffer-list)))

(defun my/vterm--group-fn (name transform)
  "Group function for vterm buffer NAME, by its project root."
  (if transform
      name
    (or (buffer-local-value 'my/vterm-project-root (get-buffer name))
        "(no project)")))

(defun my/vterm-completing-read (prompt bufs)
  "Prompt with PROMPT for one of BUFS, grouped by project. Return the chosen buffer."
  (let* ((names (mapcar #'buffer-name bufs))
         (table (lambda (str pred action)
                  (if (eq action 'metadata)
                      `(metadata (group-function . ,#'my/vterm--group-fn)
                                 (category . vterm-buffer))
                    (complete-with-action action names str pred)))))
    (get-buffer (completing-read prompt table nil t))))

(defun my/vterm-project-roots ()
  "Return the distinct project roots that currently have vterm buffers."
  (delete-dups
   (delq nil (mapcar (lambda (buf) (buffer-local-value 'my/vterm-project-root buf))
                     (my/vterm-all-buffers)))))

(defun my/vterm-project-kill-all ()
  "Pick a project by name and kill every vterm buffer belonging to it
— no need to be standing in that project first."
  (interactive)
  (let ((roots (my/vterm-project-roots)))
    (if (null roots)
        (message "No vterm buffers open.")
      (let* ((root (completing-read "Kill all vterm buffers for project: " roots nil t))
             (targets (my/vterm-buffers-for-project root)))
        (mapc #'kill-buffer targets)
        (message "Killed %d vterm buffer(s) for %s." (length targets) root)))))

(defun my/vterm-project-kill-one ()
  "Pick a single vterm buffer, grouped by project, and kill just that one."
  (interactive)
  (let ((bufs (my/vterm-all-buffers)))
    (if (null bufs)
        (message "No vterm buffers open.")
      (let* ((picked (my/vterm-completing-read "Kill vterm buffer: " bufs))
             (name (buffer-name picked)))
        (kill-buffer picked)
        (message "Killed %s." name)))))

(defun my/vterm-project-list ()
  "Switch to any vterm buffer, grouped by project."
  (interactive)
  (let ((bufs (my/vterm-all-buffers)))
    (if (null bufs)
        (message "No vterm buffers open.")
      (pop-to-buffer (my/vterm-completing-read "Vterm buffer: " bufs)
                     '(display-buffer-full-frame)))))

(provide 'mod-vterm)
