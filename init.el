;;; init.el --- Emacs Configuration -*- lexical-binding: t; -*-

;;; Code:

;; package manager
(defvar bootstrap-version)
(let ((bootstrap-file
	   (expand-file-name
	    "straight/repos/straight.el/bootstrap.el"
	    (or (bound-and-true-p straight-base-dir)
	        user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
	     "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
	     'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

;; startup
(setq inhibit-startup-screen t
      initial-scratch-message nil)

;; base ui
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)

;; line numbers
(global-display-line-numbers-mode 1)
(column-number-mode 1)
(global-hl-line-mode 1)
(blink-cursor-mode -1)
(setq display-line-numbers-width 3)

;; editing behavior
(setq-default indent-tabs-mode nil
	          tab-width 4)
(delete-selection-mode 1)
(electric-pair-mode 1)
(show-paren-mode 1)
(setq show-paren-delay 0)
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)

;; scrolling
(setq scroll-margin 3
      scroll-conservatively 101
      mouse-wheel-scroll-amount '(2)
      mouse-wheel-progressive-speed nil)

;; files and bak
(setq make-backup-files nil
      auto-save-default nil
      create-lockfiles nil)

;; misc
(setq ring-bell-function 'ignore
      use-short-answers t
      confirm-kill-emacs 'y-or-n-p)

;; encoding
(set-charset-priority 'unicode)
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; recent files
(recentf-mode 1)
(setq recentf-max-saved-items 50)

;; cursor pos
(save-place-mode 1)

;; minibuf history
(savehist-mode 1)

;; theming
(use-package modus-themes
  :custom 
  (modus-themes-italic-constructs t)
  (modus-themes-bold-constructs t)
  (modus-themes-mixed-fonts t)
  (modus-themes-org-blocks 'gray-background)
  (modus-themes-completions '((matches . (extrabold underline))
					          (selection . (semibold italic))))
  (modus-themes-headings
   '((1 . (variable-pitch 1.4))
	 (2 . (1.2))
	 (3 . (1.1))
	 (t . (1.0))))
  :config
  (load-theme 'modus-vivendi :no-confirm))

;; fonts
(defun amra/set-fonts()
  "Set default and variable-pitch fonts."
  (set-face-attribute 'default nil
		              :family "JetBrains Mono"
		              :height 120
		              :weight 'regular)
  (set-face-attribute 'fixed-pitch nil
		              :family "JetBrains Mono"
		              :height 1.0)
  (set-face-attribute 'variable-pitch nil
		              :family "JetBrains Mono"
		              :height 1.0))

(if (daemonp)
    (add-hook 'after-make-frame-functions
	          (lambda (frame)
	            (with-selected-frame frame (amra/set-fonts))))
  (amra/set-fonts))

;; JB Mono ligature
(use-package ligature
  :config
  (ligature-set-ligatures 'prog-mode
				          '("==" "!=" ">=" "<=" "&&" "||"
				            "->" "=>" "::" "..." ".."
				            "/*" "*/" "//" "/**"
				            "++" "--" "<<" ">>"
				            "!!" "??" "%%"  "##"))
  (global-ligature-mode t))

;; nerd icons
(use-package nerd-icons)

;; bindings
(use-package which-key
  :custom
  (which-key-idle-delay 0.3)
  (which-key-min-display-lines 6)
  :config
  (which-key-mode))

(use-package evil
  :custom
  (evil-want-integration t)
  (evil-want-keybinding nil)
  (evil-want-C-u-scroll t)
  (evil-want-C-i-jump t)
  (evil-undo-system 'undo-redo)
  (evil-respect-visual-line-mode t)
  (evil-split-window-below t)
  (evil-vsplit-window-right t)
  :config
  (evil-mode 1))

(use-package exec-path-from-shell
  :config
  (exec-path-from-shell-initialize))

(use-package tuareg
  :demand t
  :mode ("\\.ml\\'" "\\.mli\\'" "\\.mly\\'" "\\.mll\\'")
  :config
  (defalias 'tuareg 'tuareg-mode))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

(use-package general
  :after evil
  :config
  (general-create-definer amra/leader
    :states '(normal  visual emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC")

  (amra/leader
    ""    '(nil :wk "leader")
    "TAB" '(dired-jump :wk "dired")

    ;; files
    "f"   '(:ignore t :wk "files")
    "ff"  '(find-file :wk "find file")
    "fr"  '(recentf-open-files :wk "recent files")
    "fs"  '(save-buffer :wk "save file")

    ;; buffer
    "b"   '(:ignore t :wk "buffer")
    "bb"  '(switch-to-buffer :wk "switch buffer")
    "bc"  '(kill-current-buffer :wk "close current buffer")
    "bn"  '(next-buffer :wk "next buffer")
    "bp"  '(previous-buffer :wk "previous buffer")
    "bi"  '(ibuffer :wk "ibuffer")

    ;; window
    "w"   '(:ignore t :wk "window")
    "wv"  '(evil-window-vsplit :wk "vertical split")
    "ws"  '(evil-window-split :wk "vertical horizontally")
    "wc"  '(evil-window-delete :wk "close window")
    "wh"  '(evil-window-left :wk "go left")
    "wj"  '(evil-window-down :wk "go down")
    "wk"  '(evil-window-up :wk "go up")
    "wl"  '(evil-window-right :wk "go right")
    "w="  '(balance-windows :wk "balance")
    "ww"  '(evil-window-next :Wk "next window")

    ;; help
    "h"   '(:ignore t :wk "help")
    "hf"  '(describe-function :wk "describe function")
    "hv"  '(describe-variable :wk "describe variable")
    "hk"  '(describe-key :wk "describe key")
    "hm"  '(describe-mode :wk "describe mode")

    ;; toggle
    "t"   '(:ignore t :wk "toggle")
    "tl"  '(display-line-numbers-mode :wk "line numbers")
    "tw"  '(visual-line-mode :wk "word wrap")
    "tt"  '(modus-themes-toggle :wk "theme toggle")

    "a"   '(:ignore t :wk "align")
    "aa"  '(align :wk "align")
    "ar"  '(align-regexp :wk "align regexp")
    "ac"  '(align-current :wk "align current")
    ))

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; completion ui
(use-package vertico
  :custom
  (vertico-count 12)
  (vertico-cycle t)
  (vertico-resize nil)
  :config
  (vertico-mode))

;; flexible matching
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides
   '((file (styles basic partial-completion)))))

;; annotations
(use-package marginalia
  :config
  (marginalia-mode))

;; search and navigation
(use-package consult
  :custom
  (consult-narrow-key "<")
  (consult-preview-key "M-.")
  :config
  (setq consult-ripgrep-args
        "rg --null --line-buffered --color=never --max-columns=1000 --path-separator / --smart-case --no-heading --with-filename --line-number --search-zip"))

;; context actions on mbuf candidates
(use-package embark
  :general
  ("C-." 'embark-act
   "C-;" 'embark-dwim
   "C-h B" 'embark-bindings)
  :custom
  (prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; in-buffer comp
(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.2)
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  (corfu-quit-no-match 'separator)
  (corfu-popupinfo-delay 0)
  :config
  (global-corfu-mode)
  (corfu-popupinfo-mode))

;; backends for corfu
(use-package cape
  :init
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-dabbrev))

;; treesitter
(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  (treesit-auto-langs '(ocaml typst))
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; evil textobj for treesitter
(use-package evil-textobj-tree-sitter
  :after evil
  :config
  (define-key evil-outer-text-objects-map "f"
              (evil-textobj-tree-sitter-get-textobj "function.outer"))
  (define-key evil-inner-text-objects-map "f"
              (evil-textobj-tree-sitter-get-textobj "function.inner"))
  (define-key evil-outer-text-objects-map "c"
              (evil-textobj-tree-sitter-get-textobj "class.outer"))
  (define-key evil-inner-text-objects-map "c"
              (evil-textobj-tree-sitter-get-textobj "class.inner")))

(use-package eglot
  :straight (:type built-in)
  :custom
  (eglot-autoshutdown t)                  
  (eglot-events-buffer-size 0)            
  (eglot-send-changes-idle-time 0.5)      
  :config
  (fset 'jsonrpc--log-event #'ignore)

  (add-to-list 'eglot-server-programs '(ocaml-mode . ("ocamllsp")))
  (add-to-list 'eglot-server-programs '(tuareg-mode . ("ocamllsp")))
  (add-to-list 'eglot-server-programs '(typst-ts-mode . ("tinymist")))
  :hook
  ((tuareg-mode . eglot-ensure)
   (typst-ts-mode . eglot-ensure)))

(use-package cape
  :after eglot
  :config
  (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster))

;; hover docs
(use-package eldoc
  :straight (:type built-in)
  :custom
  (eldoc-echo-area-use-multiline-p nil)
  (eldoc-idle-delay 0.3))

;; flymake diagnosics
(use-package flymake
  :straight (:type built-in)
  :hook (prog-mode . flymake-mode)
  :general
  (amra/leader
    "e"   '(:ignore t :wk "errors")
    "en"  '(flymake-goto-next-error :wk "next error")
    "ep"  '(flymake-goto-prev-error :wk "prev error")
    "el"  '(flymake-show-buffer-diagnostics :wk "list errors")))

;; Code actions & LSP leader bindings
(amra/leader
  "c"  '(:ignore t :wk "code")
  "ca" '(eglot-code-actions :wk "code actions")
  "cr" '(eglot-rename :wk "rename symbol")
  "cf" '(eglot-format :wk "format buffer")
  "cd" '(xref-find-definitions :wk "go to definition")
  "cD" '(xref-find-references :wk "find references")
  "ci" '(eglot-find-implementation :wk "find implementation")
  "ck" '(eldoc-doc-buffer :wk "show docs")
  "cc" '(compile :wk "compile")
  "cR" '(recompile :wk "recompile")  
  )

;; ocaml
(use-package dune
  :mode ("dune\\'" "dune-project\\'"))

(use-package utop
  :hook (tuareg-mode . utop-minor-mode)
  :custom
  (utop-command "opam exec -- utop"))

;; typst
(use-package typst-ts-mode
  :straight (:type git :host sourcehut :repo "meow_king/typst-ts-mode")
  :mode "\\.typ\\'"
  :custom
  (typst-ts-mode-watch-options "--open"))

;; magit
(use-package magit
  :general
  (amra/leader
    "g" '(:ignore t :wk "git")
    "gs" '(magit-status :wk "status")
    "gb" '(magit-blame-date :wk "blame")
    "gl" '(magit-log-current :wk "log")
    "gd" '(magit-diff-dwim :wk "diff")
    "gf" '(magit-file-dispatch :wk "file actions")))

(use-package magit-todos
  :after magit
  :config
  (magit-todos-mode 1))

(use-package diff-hl
  :hook ((magit-post-refresh . diff-hl-magit-post-refresh)
         (magit-pre-refresh . diff-hl-magit-pre-refresh))
  :config
  (global-diff-hl-mode))

(use-package dired-git-info
  :after dired
  :general
  (amra/leader
    "tg" '(dired-git-info-mode :wk "dired git info"))
  :hook (dired-after-readin . dired-git-info-auto-enable))

;; discord rp
(use-package elcord
  :custom
  (elcord-display-buffer-details t)       
  (elcord-display-elapsed t)              
  (elcord-editor-icon "emacs_icon")       
  (elcord-quiet t)                        
  :config
  (elcord-mode))

;; c/c++
(add-hook 'c-mode-hook #'eglot-ensure)
(add-hook 'c++-mode-hook #'eglot-ensure)

;; snippets
(use-package yasnippet
  :hook (prog-mode . yas-minor-mode))

(use-package yasnippet-snippets
  :after yasnippet)

;;; init.el ends here
