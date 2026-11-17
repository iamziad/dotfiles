;;; init-pdf.el --- PDF and EPUB reading -*- lexical-binding: t; -*-

(use-package pdf-tools
  :ensure t
  :mode "\\.pdf\\'"
  :config
  (pdf-tools-install :no-query)

  ;; `pdf-view-mode-map' is created by PDF Tools, so bind after loading.
  (keymap-set pdf-view-mode-map "j" #'pdf-view-next-line-or-next-page)
  (keymap-set pdf-view-mode-map "k" #'pdf-view-previous-line-or-previous-page)
  (keymap-set pdf-view-mode-map "C-c p d" #'pdf-view-midnight-minor-mode)
  (keymap-set pdf-view-mode-map "=" #'pdf-view-enlarge)
  (keymap-set pdf-view-mode-map "-" #'pdf-view-shrink)

  (setq pdf-view-use-scaling t
        pdf-view-midnight-colors '("#ebdbb2" . "#282828")))

(defun my/pdf-tmp-url (url)
  "Download PDF at URL into the temporary directory and visit it."
  (interactive "sPDF URL: ")
  (let ((file (expand-file-name (file-name-nondirectory url)
                                temporary-file-directory)))
    (url-copy-file url file t)
    (find-file file)))

(defun my/pdf-url (url directory)
  "Download the PDF at URL into DIRECTORY and visit it."
  (interactive (list (read-string "PDF URL: ")
                     (read-directory-name "Download to: ")))
  (let* ((filename (file-name-nondirectory
                    (url-filename (url-generic-parse-url url))))
         (file (expand-file-name filename directory)))
    (url-copy-file url file t)
    (find-file file)))

(use-package nov
  :ensure t
  :mode ("\\.epub\\'" . nov-mode))

(provide 'init-pdf)
;;; init-pdf.el ends here
