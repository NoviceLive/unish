#!/usr/bin/env bash


#
# Copyright 2016 Gu Zhengxiong <rectigu@gmail.com>
#


set -e


CONF="$(realpath "${1:-${HOME}/.emacs.d}")"
INIT="${CONF}/init.el"


rm -rf "${CONF}/*"

git init "${CONF}" && cd "${CONF}"


cat >> "${INIT}" <<EOF
;;
;; Copyright 2015-2016 Gu Zhengxiong <rectigu@gmail.com>
;;


(setq inhibit-startup-screen t)

(setq make-backup-files nil)
(setq-default indent-tabs-mode nil)
(setq-default mode-line-format nil)
(setq-default frame-title-format nil)
(setq-default tab-width 4)

(add-hook 'before-save-hook 'delete-trailing-whitespace)
(add-hook 'window-setup-hook 'toggle-frame-maximized t)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(global-linum-mode 1)
(global-hl-line-mode 1)
(global-whitespace-mode 1)
(global-auto-revert-mode 1)
(show-paren-mode 1)
(setq show-paren-style 'expression)

(savehist-mode 1)

(add-to-list 'default-frame-alist '(cursor-color . "#ff0000"))
EOF


git submodule add --depth 1 \
    https://github.com/company-mode/company-mode.git \
    vendor/company-mode

cat >> "${INIT}" <<EOF


(add-to-list 'load-path
             "${CONF}/vendor/company-mode")
(require 'company)
(add-hook 'after-init-hook 'global-company-mode)
EOF


git submodule add --depth 1 \
    https://github.com/haskell/haskell-mode.git \
    vendor/haskell-mode

#
# after save hook · Issue #395 · haskell/haskell-mode
# https://github.com/haskell/haskell-mode/issues/395
#
cat >> "${INIT}" <<EOF


(add-to-list 'load-path
             "${CONF}/vendor/haskell-mode/")
(require 'haskell)
(add-to-list 'Info-default-directory-list
             "${CONF}/vendor/haskell-mode/")
EOF


git submodule add --depth 1 \
    https://github.com/jorgenschaefer/elpy.git vendor/elpy

git submodule add --depth 1 \
    https://github.com/jorgenschaefer/pyvenv.git vendor/pyvenv

git submodule add --depth 1 \
    https://github.com/antonj/Highlight-Indentation-for-Emacs.git \
    vendor/highlight-indentation

git submodule add --depth 1 \
    https://github.com/capitaomorte/yasnippet.git vendor/yasnippet

cat >> "${INIT}" <<EOF


(add-to-list 'load-path "${CONF}/vendor/pyvenv/")

(add-to-list 'load-path "${CONF}/vendor/highlight-indentation/")

(add-to-list 'load-path "${CONF}/vendor/yasnippet/")
(require 'yasnippet)
(yas-global-mode)

(add-to-list 'load-path "${CONF}/vendor/elpy/")
(require 'elpy)
(elpy-enable)
EOF


git submodule add --depth 1 \
    https://github.com/wwwjfy/emacs-fish.git vendor/emacs-fish
cat >> "${INIT}" <<EOF


(add-to-list 'load-path "~/.emacs.d/vendor/emacs-fish/")
(require 'fish-mode)
EOF



git submodule add --depth 1 \
    https://github.com/jrblevin/markdown-mode.git \
    vendor/markdown-mode
cat >> "${INIT}" <<EOF


(add-to-list 'load-path "~/.emacs.d/vendor/markdown-mode/")
(autoload 'markdown-mode "markdown-mode"
   "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
EOF


git submodule add --depth 1 \
    https://github.com/Fanael/rainbow-delimiters.git \
    vendor/rainbow-delimiters
cat >> "${INIT}" <<EOF


(add-to-list 'load-path "~/.emacs.d/vendor/rainbow-delimiters/")
(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
EOF


git submodule add --depth 1 \
    https://github.com/bbatsov/solarized-emacs.git \
    vendor/solarized-emacs
git submodule add --depth 1 \
    https://github.com/magnars/dash.el.git vendor/dash.el
cat >> "${INIT}" <<EOF


(add-to-list 'load-path "~/.emacs.d/vendor/dash.el/")
(add-to-list 'load-path "~/.emacs.d/vendor/solarized-emacs/")
(add-to-list 'custom-theme-load-path
             "~/.emacs.d/vendor/solarized-emacs/")
(load-theme 'solarized-dark t)
EOF


git submodule add --depth 1 \
    https://github.com/dacap/keyfreq.git vendor/keyfreq
cat >> "${INIT}" <<EOF


(add-to-list 'load-path "~/.emacs.d/vendor/keyfreq/")
(require 'keyfreq)
(keyfreq-mode 1)
(keyfreq-autosave-mode 1)
EOF
