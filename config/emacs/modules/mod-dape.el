;;; mod-dape.el --- -*- lexical-binding: t; -*-

(use-package dape
  :ensure t
  :config
  (setq dape-buffer-window-arrangement 'left)

  (setf (alist-get 'jdtls dape-configs)
        `( modes (java-mode java-ts-mode)
           ensure (lambda (config)
                    (let ((file (dape-config-get config :filePath)))
                      (unless (and (stringp file) (file-exists-p file))
                        (user-error "Unable to locate :filePath `%s'" file))
                      (with-current-buffer (find-file-noselect file)
                        (unless (lsp-workspaces)
                          (user-error "No lsp-mode instance active in buffer %s" (current-buffer)))
                        (unless (lsp-can-execute-command? "vscode.java.resolveClasspath")
                          (user-error "Jdtls instance does not bundle java-debug-server, please install")))))
           fn (lambda (config)
                (with-current-buffer
                    (find-file-noselect (dape-config-get config :filePath))
                  (if (lsp-workspaces)
                      (pcase-let ((`(,module-paths ,class-paths)
                                   (lsp-send-execute-command
                                    "vscode.java.resolveClasspath"
                                    (vector
                                     (plist-get config :mainClass)
                                     (plist-get config :projectName))))
                                  (port
                                   (lsp-send-execute-command
                                    "vscode.java.startDebugSession")))
                        (thread-first config
                                      (plist-put 'port port)
                                      (plist-put :modulePaths module-paths)
                                      (plist-put :classPaths class-paths)))
                    config)))
           ,@(cl-flet ((resolve-main-class (key)
                         (ignore-errors
                           (let* ((main-classes
                                   (lsp-send-execute-command
                                    "vscode.java.resolveMainClass"
                                    (file-name-nondirectory
                                     (directory-file-name (dape-cwd)))))
                                  (main-class
                                   (or (seq-find (lambda (val)
                                                   (equal (plist-get val :filePath)
                                                          (buffer-file-name)))
                                                 main-classes)
                                       (aref main-classes 0))))
                             (plist-get main-class key)))))
               `(:filePath
                 ,(lambda ()
                    (or (resolve-main-class :filePath)
                        (expand-file-name (dape-buffer-default) (dape-cwd))))
                 :mainClass
                 ,(lambda () (resolve-main-class :mainClass))
                 :projectName
                 ,(lambda () (resolve-main-class :projectName))))
           :args ""
           :stopOnEntry nil
           :type "java"
           :request "launch"
           :vmArgs " -XX:+ShowCodeDetailsInExceptionMessages"
           :console "integratedConsole"
           :internalConsoleOptions "neverOpen")))

(use-package dape-toolbar
  :straight (:host github :repo "zsxh/dape-toolbar")
  :after dape
  :config
  (dape-toolbar-mode 1))

(use-package emacs
  :custom
  (window-sides-vertical t))

;; (use-package repeat
;;   :custom
;;   (repeat-mode +1))

(provide 'mod-dape)
