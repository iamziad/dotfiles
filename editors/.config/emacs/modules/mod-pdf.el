;;; mod-pdf.el

(use-package pdf-tools
  :ensure t
  :mode "\\.pdf\\'"
  :bind (:map pdf-view-mode-map
              ("j"       . pdf-view-next-line-or-next-page)
              ("k"       . pdf-view-previous-line-or-previous-page)
              ("C-c p d" . pdf-view-midnight-minor-mode)
              ("="       . pdf-view-enlarge)
              ("-"       . pdf-view-shrink))
  :hook (pdf-tools-install)
  :config
  (setq pdf-view-use-scaling t
        pdf-view-midnight-colors '("#ebdbb2" . "#282828")))

(defun my/pdf-tmp-url (url)
  (interactive "sPDF URL: ")
  (let ((file (concat "/tmp/" (file-name-nondirectory url))))
    (url-copy-file url file t)
    (find-file file)))

(defun my/pdf-url (url directory)
  (interactive (list (read-string "PDF URL: ") (read-directory-name "Download to: ")))
  (let* ((filename (file-name-nondirectory (url-filename (url-generic-parse-url url))))
         (file (expand-file-name filename directory)))
    (url-copy-file url file t)
    (find-file file)))

(provide 'mod-pdf)

;;; mod-pdf.el ends here
