;;;; JS/TS  -*- lexical-binding: t; -*-

(setq js-indent-level 2
      typescript-ts-mode-indent-offset 2
      json-ts-mode-indent-offset 2)

(add-to-list 'auto-mode-alist '("\\.jsx\\'" . js-jsx-mode))

;; Pick up eslint, prettier, tsc, ... from the project's node_modules/.bin.
(use-package add-node-modules-path
  :hook ((js-mode js-jsx-mode js-ts-mode
                  typescript-ts-mode tsx-ts-mode
                  json-ts-mode) . add-node-modules-path))

;; mason + dape
(with-eval-after-load 'dape
  (let ((link (expand-file-name "js-debug" dape-adapter-dir))
        (target (expand-file-name "packages/js-debug-adapter/js-debug"
                                  my/mason-dir)))
    (unless (or (file-exists-p link) (file-symlink-p link))
      (make-directory (file-name-directory link) t)
      (make-symbolic-link target link t)))

  (dolist (config
           '((node
              modes (js-mode js-ts-mode typescript-mode typescript-ts-mode
                             tsx-ts-mode)
              command "js-debug-adapter" command-args (:autoport) port :autoport
              :type "pwa-node" :request "launch"
              :name "Node: launch current file"
              :cwd dape-cwd :program dape-buffer-default
              :sourceMaps t :console "internalConsole")
             (node-tsx
              modes (typescript-ts-mode tsx-ts-mode)
              command "js-debug-adapter" command-args (:autoport) port :autoport
              :type "pwa-node" :request "launch"
              :name "Node: launch TS file with tsx"
              :cwd dape-cwd :program dape-buffer-default
              :runtimeArgs ["--import" "tsx"]
              :sourceMaps t :console "internalConsole")
             (node-attach
              modes (js-mode js-ts-mode typescript-mode typescript-ts-mode
                             tsx-ts-mode)
              command "js-debug-adapter" command-args (:autoport) port :autoport
              :type "pwa-node" :request "attach"
              :name "Node: attach :9229"
              :port 9229 :cwd dape-cwd :sourceMaps t)
             (chrome
              modes (js-mode js-ts-mode typescript-mode typescript-ts-mode
                             tsx-ts-mode html-mode html-ts-mode)
              command "js-debug-adapter" command-args (:autoport) port :autoport
              :type "pwa-chrome" :request "launch"
              :name "Chrome: localhost:5173"
              :url "http://localhost:5173" :webRoot dape-cwd :sourceMaps t)))
    (add-to-list 'dape-configs config)))

(provide 'javascript)
