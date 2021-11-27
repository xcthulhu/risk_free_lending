;;; .emacs -- Matthew Doty's emacs configuration -*- mode: emacs-lisp; lexical-binding: t; comment-fill-column: 128; -*-

;;; Commentary:
;;;   This .emacs is intended to download all dependencies if
;;;   ~/.emacs.d is ever deleted.
;;;
;;;   `use-package' is leveraged in order to break code into sections

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;; Package Management ;;;;;;;;;;;;;;;;;;;;;;;;

(eval-and-compile
  (require 'package)
  (setq package-archives
    '(
       ("gnu" . "https://elpa.gnu.org/packages/")
       ("melpa" . "https://melpa.org/packages/")
       ("org" . "https://orgmode.org/elpa/")
       ))
  (package-initialize)
  (unless package-archive-contents
    (package-refresh-contents))
  (unless (package-installed-p 'use-package)
    (package-install 'use-package))
  (require 'use-package)
  (setf use-package-always-ensure t)
  )

;; Python

(use-package python
  :ensure nil

  :demand

  :defines
  python-inferior-mode

  :commands
  mpwd/set-fill-column-88
  mpwd/set-indent-to-4

  :custom
  (python-indent-offset                     4)
  (python-shell-completion-native-enable    nil)
  ;; https://stackoverflow.com/a/36295937
  (python-shell-interpreter                 "python3")
  (python-shell-interpreter-args            "-iq")
  (python-shell-interpreter-interactive-arg "-iq")

  :config

  (defun mpwd/set-fill-column-88 ()
    "Set the `fill-column' to 88, as per the default for `black'. See
URL`https://black.readthedocs.io/en/stable/the_black_code_style/current_style.html#line-length'"
    (setq-local fill-column 88))

  (defun mpwd/set-indent-to-4 ()
    "Sets the indent level of the file to 4."
    (setq-local standard-indent 4))

  :hook
  (python-mode . hs-minor-mode)

  (python-mode . mpwd/set-fill-column-88)
  (python-mode . mpwd/set-indent-to-4)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Direnv ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package direnv
  :disabled

  :commands
  direnv-mode

  :config
  (direnv-mode t)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;; Plant UML diagrams ;;;;;;;;;;;;;;;;;;;;;;;;

(use-package plantuml-mode
  :disabled
  :config
  ;; plantuml must be installed by nix.  The code below extracts the
  ;; jar and path to java so emacs can run it.
  (let* ( (nix-plantuml-path (string-trim-right (shell-command-to-string "command -v plantuml")))
          (nix-plantuml-script (mpwd/get-string-from-file nix-plantuml-path)))
    (setq-default
      plantuml-exec-mode 'jar

      plantuml-jar-path
      ;; nix-plantuml-script
      (progn
        (string-match "-jar.*\\(/nix/store/.*/plantuml.jar\\)" nix-plantuml-script)
        (match-string 1 nix-plantuml-script))

      plantuml-java-command
      (progn
        (string-match "\\(/nix/store/.*/java\\)" nix-plantuml-script)
        (match-string 1 nix-plantuml-script)
        )

      ;; Setup plantuml for `org-mode'
      org-plantuml-jar-path plantuml-jar-path
      ))

  (org-babel-do-load-languages
    'org-babel-load-languages
    '((plantuml . t)))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Org Mode ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package org
  :diminish
  org-indent-mode

  :defines
  org-babel-load-languages

  :commands
  org-align-tags
  org-babel--get-vars
  org-babel-do-load-languages
  org-babel-eval
  org-babel-expand-body:generic
  org-babel-graphical-output-file
  org-babel-result-end
  org-babel-where-is-src-block-result
  org-element-context
  org-element-map
  org-element-parse-buffer
  org-element-property
  org-element-type
  org-in-regexp
  org-insert-structure-template
  org-mode-map
  org-open-at-point
  org-open-at-point-global
  org-redisplay-inline-images
  org-time-stamp-inactive
  ox-extras-activate

  org-mode-format-buffer
  org-remove-link

  mpwd/add-org-mode-format-buffer-on-save-hook
  mpwd/format-ansi-colors-for-babel-output
  mpwd/org-browse-html-file
  mpwd/org-config-flyspell
  mpwd/org-evil-fix-window-nav-keys
  mpwd/org-flyspell-skip-code
  mpwd/org-global-property-value
  mpwd/org-redisplay-inline-images

  :custom-face
  ;; https://zzamboni.org/post/beautifying-org-mode-in-emacs/

  (org-document-title ((t (:inherit variable-pitch :weight bold :underline nil))))
  (org-level-1 ((t (:inherit variable-pitch :weight bold))))
  (org-level-2 ((t (:inherit variable-pitch :weight bold))))
  (org-level-3 ((t (:inherit variable-pitch :weight bold))))
  (org-level-4 ((t (:inherit variable-pitch :weight bold))))

  (org-level-5 ((t (:inherit variable-pitch :weight bold))))
  (org-level-6 ((t (:inherit variable-pitch :weight bold))))
  (org-level-7 ((t (:inherit variable-pitch :weight bold))))
  (org-level-8 ((t (:inherit variable-pitch :weight bold))))

  (org-block ((t (:inherit shadow :extend t :font "Iosevka Terminal"))))
  (org-headline-done ((t (:inherit shadow :strike-through t))))
  (org-code ((t (:inherit shadow :font "Iosevka Terminal"))))
  (org-verbatim ((t (:inherit shadow :font "Iosevka Terminal"))))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Faces with different sizes ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; (org-document-title ((t (:inherit variable-pitch :weight bold :height 2.0 :underline t))))
  ;; (org-level-1 ((t (:inherit variable-pitch :weight bold :height 1.75))))
  ;; (org-level-2 ((t (:inherit variable-pitch :weight bold :height 1.5))))
  ;; (org-level-3 ((t (:inherit variable-pitch :weight bold :height 1.25))))
  ;; (org-level-4 ((t (:inherit variable-pitch :weight bold :height 1.1))))

  :custom
  (org-babel-python-command          "python3 -q")
  ;; https://github.com/rougier/elegant-emacs/blob/1eea4d30e1174512d342ab8c604ab68013c24ac0/elegance.el#L70-L75
  (org-confirm-elisp-link-function   nil)
  (org-display-inline-images         t)
  ;; (org-ellipsis                      " ...")
  (org-hide-emphasis-markers         nil) ; display emphasis markers /=_
  (org-export-backends               '(ascii beamer html latex md))
  (org-export-in-background          nil) ; synchronous export
  (org-file-apps
    '(
       ("\\.x?html?\\'" . mpwd/org-browse-html-file)
       (auto-mode       . emacs)
       ("\\.mm\\'"      . default)
       ("\\.pdf\\'"     . default)
       ))
  (org-format-latex-options
    '(
       :foreground default
       :background default
       :scale 1.5
       :html-foreground "Black"
       :html-background "Transparent"
       :html-scale 1.0
       :matchers ("begin" "$1" "$" "$$" "\\(" "\\[")
       ))
  (org-fontify-done-headline t)
  (org-todo-keywords
    '((sequence "TODO(t)" "WAITING(w)" "|" "DONE(d)" "CANCELED(c@)")))
  (org-todo-keyword-faces '(("CANCELED" . warning)))
  (org-latex-compiler
    "latexmk -shell-escape -pdflatex=xelatex -pdf")
  (org-latex-create-formula-image-program 'dvisvgm)
  (org-latex-listings 'minted)
  ;; (org-latex-listings t)
  (org-latex-packages-alist
    '(
       ;; ("" "listings")

       ("" "minted")

       ;; https://www.overleaf.com/learn/latex/Theorems_and_proofs
       "
\\usepackage{amsthm}
\\theoremstyle{plain}
\\newtheorem{theorem}{Theorem}[subsection]
%\\newtheorem{corollary}{Corollary}[theorem]
\\newtheorem{corollary}[theorem]{Corollary}
\\newtheorem{lemma}[theorem]{Lemma}
\\newtheorem{proposition}[theorem]{Proposition}
\\newtheorem{assumption}[theorem]{Assumption}


\\newtheorem{observation}{Observation}

\\theoremstyle{definition}
\\newtheorem{definition}{Definition}[section]

\\theoremstyle{example}
\\newtheorem{example}{Example}[section]
       "
       ))
  (org-latex-pdf-process
    '(
       ;; "latexmk -bibtex -file-line-error -shell-escape -pdflatex=xelatex -pdf -output-directory=\"%o\" -f \"%f\""
       "latexmk -file-line-error -shell-escape -pdflatex=xelatex -pdf -output-directory=\"%o\" -f \"%f\""
       ))
  ;; Trust svgbob code blocks
  ;; https://emacs.stackexchange.com/a/21128
  (org-confirm-babel-evaluate        #'(lambda (lang _) (not (member lang '("svgbob")))))
  (org-link-frame-setup              '((file . find-file)))
  (org-list-allow-alphabetical       t)
  (org-modules '(
                  ol-bbdb
                  ol-bibtex
                  ol-docview
                  ol-eww
                  ol-gnus
                  ol-info
                  ol-irc
                  ol-mhe
                  ol-rmail
                  ol-w3m
                  org-checklist
                  ox
                  ))
  (org-src-fontify-natively          t)
  (org-src-preserve-indentation      t)
  (org-src-tab-acts-natively         t)
  (org-src-window-setup              'current-window)
  (org-startup-indented              t)
  (org-startup-truncated             nil)
  (org-startup-with-inline-images    "inlineimages")
  (org-support-shift-select          t)
  (org-pretty-entities               nil)
  (org-preview-latex-default-process 'dvisvgm)
  (python-indent-offset              4)


  :init
  ;;;;;;;;;;;;;;;;;;;;;;;;;; Language Support ;;;;;;;;;;;;;;;;;;;;;;;;

  ;; Standard languages



  (org-babel-do-load-languages
    'org-babel-load-languages
    '(
       (calc   . t)
       (ditaa  . t)                     ; https://orgmode.org/worg/org-contrib/babel/languages/ob-doc-ditaa.html#org9f5f1ef
       (maxima . t)                     ; https://orgmode.org/worg/org-contrib/babel/languages/ob-doc-maxima.html
       (python . t)                     ; https://orgmode.org/worg/org-contrib/babel/languages/ob-doc-python.html#org562e3c8
       (shell  . t)
       (sql    . t)                     ; https://orgmode.org/worg/org-contrib/babel/languages/ob-doc-sql.html#org4435975
       (sqlite . t)                     ; https://orgmode.org/worg/org-contrib/babel/languages/ob-doc-sqlite.html#orgd631cba
       ))

  ;; Haskell

  ;; https://www.arcadianvisions.com/blog/2018/org-nix-direnv.html#org93133ce
  (defun org-babel-execute:runhaskell (body params)
    (org-babel-eval "runhaskell"
      (org-babel-expand-body:generic body params)))

  (add-to-list 'org-src-lang-modes '("runhaskell" . haskell))


  :config

  ;;;;;;;;;;;;;;;;;;;;;;;;;; Checklist Format ;;;;;;;;;;;;;;;;;;;;;;;;

  ;; (set-face-attribute 'org-done nil :strike-through t)
  (set-face-attribute 'org-headline-done nil
    :strike-through t
    :foreground "light gray")

  ;;;;;;;;;;;;;;;;;;;; Format an `org-mode' Buffer ;;;;;;;;;;;;;;;;;;;

  (defun org-mode-format-buffer ()
    "Format an `org-mode' buffer.  Runs `org-align-tags'."
    (interactive)
    (when (equal major-mode 'org-mode)
      (org-align-tags)))

  (defun mpwd/add-org-mode-format-buffer-on-save-hook ()
    "Add a hook to format the current buffer with
`org-mode-format-buffer' before saving."
    (add-hook 'before-save-hook 'org-mode-format-buffer nil 'local))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;; Inline Images ;;;;;;;;;;;;;;;;;;;;;;;;;;

  (defun mpwd/org-redisplay-inline-images ()
    "Run `org-redisplay-inline-images' if `org-inline-image-overlays' is set."
    (when org-inline-image-overlays
      (org-redisplay-inline-images)))

  ;; Color output

  ;; https://emacs.stackexchange.com/a/63562
  ;; TODO: 24-bit color mode
  (defun mpwd/format-ansi-colors-for-babel-output ()
    "Display ANSI color output for `org-mode' source blocks."
    (when-let ((beg (org-babel-where-is-src-block-result nil nil)))
      (save-excursion
        (goto-char beg)
        (when (looking-at org-babel-result-regexp)
          (let ((end (org-babel-result-end))
                 (ansi-color-context-region nil))
            (ansi-color-apply-on-region beg end))))))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Org Links ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; Remove a link in org-mode
  ;; https://emacs.stackexchange.com/questions/10707/in-org-mode-how-to-remove-a-link
  (defun org-remove-link ()
    "Replace an org link by its description or if empty its address."
    (interactive)
    (if (org-in-regexp org-link-bracket-re 1)
      (save-excursion
        (let ( (remove (list (match-beginning 0) (match-end 0)))
               (description
                 (if (match-end 2)
                   (match-string-no-properties 2)
                   (match-string-no-properties 1))))
          (apply 'delete-region remove)
          (insert description)))))

  ;; Browse HTML files
  ;; https://emacs.stackexchange.com/a/46670
  (defun mpwd/org-browse-html-file (_ file-path)
    "Browse an `org-link' to an HTML file specified by FILE-PATH."
    ;; TODO: use browse-url and be smart about window-mode
    (let ((file-uri (format "file://%s" file-path)))
      (eww file-uri)
      ))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Flyspell ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; Skip flyspell on source blocks and code snippets
  ;; https://emacs.stackexchange.com/questions/54619/skip-flyspell-checking-of-code-and-verbatim-regions-in-org-mode

  (defun mpwd/org-flyspell-skip-code (b _e _ignored)
    "Returns non-nil if current word is code. This function is
intended for `flyspell-incorrect-hook'."
    (save-excursion
      (goto-char b)
      (memq (org-element-type (org-element-context))
        '(code src-block))))

  (defun mpwd/org-config-flyspell ()
    "Configure flyspell for org-mode."
    (add-hook 'flyspell-incorrect-hook #'mpwd/org-flyspell-skip-code nil t))

  :hook
  (org-babel-after-execute . mpwd/format-ansi-colors-for-babel-output)
  (org-babel-after-execute . mpwd/org-redisplay-inline-images)
  (org-mode . abbrev-mode)
  (org-mode . flyspell-mode)
  (org-mode . git-gutter-mode)
  (org-mode . org-indent-mode)
  (org-mode . visual-line-mode)

  (org-mode . mpwd/add-org-mode-format-buffer-on-save-hook)
  (org-mode . mpwd/org-config-flyspell)

  ;; `org-src-mode' doesn't manage `flycheck-mode' properly
  ;; (org-src-mode . mpwd/disable-flycheck-mode)

  :bind
  (
    :map org-mode-map
    ("C-c C-x -" . #'org-insert-structure-template)
    ([remap xref-find-definitions] . #'org-open-at-point)
    ("C-c i" . #'org-time-stamp-inactive)
    )
  )

(use-package ox-extra
  :ensure org-plus-contrib
  :after org
  :demand

  :commands
  ox-extras-activate

  :config
  ;; Exclude a heading from LaTeX export
  ;; https://emacs.stackexchange.com/a/41685
  (ox-extras-activate '(ignore-headlines))
  )

(use-package ob-svgbob
  :after org
  :demand

  :config
  (add-to-list 'org-src-lang-modes '("svgbob" . artist))
  )

(use-package rustic-babel
  :ensure rustic

  :after org)

(use-package org-ref)

(provide 'init.el)
;;; init.el ends here
