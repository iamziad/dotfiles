;; -*- lexical-binding: t; -*-

(use-package java-kit
  :ensure (:host github :repo "LuciusChen/java-kit")
  :config
  (setopt java-kit-jdtls-jvm-arguments
          '("-Xmx4G" "-XX:+UseStringDeduplication")
          java-kit-jdtls-bundles
          '("~/.emacs.d/debug-adapters/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-0.53.2.jar"))
  :hook ((java-mode java-ts-mode) . java-kit-mode))

(provide 'init-java)
