;; -*- lexical-binding: t; -*-

(use-package java-kit
  :ensure (:host github :repo "LuciusChen/java-kit")
  :hook ((java-mode java-ts-mode) . java-kit-mode)
  :config
  (setopt java-kit-jdtls-jvm-arguments
          '("-Xmx4G" "-XX:+UseStringDeduplication")
          java-kit-jdtls-bundles
          (list (expand-file-name
                 "var/dape/adapters/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-0.53.2.jar"
                 user-emacs-directory))))

(provide 'init-java)
