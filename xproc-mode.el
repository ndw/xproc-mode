;;; xproc-mode.el --- XProc mode     -*- lexical-binding: t; -*-

;; Copyright © 2020 Norm Tovey-Walsh, ndw@nwalsh.com

;; Keywords: literate programming, reproducible research, xproc

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Commentary:

;; Provides a primitive XProc mode which is nothing more than a copy
;; of XML mode. Adds Org-Babel support for evaluating XProc pipelines.
;;
;; This is a primitive implementation created by hacking ob-ledger.

;;; Code:

(require 'nxml-mode)
(require 'ob)

;; Define a variant of nxml-mode so that we can associated org-babel
;; with it.
(define-derived-mode xproc-mode nxml-mode
  (nxml-mode))

;; Define a processor. This must be a shell script that will process
;; an XProc pipeline. See https://github.com/ndw/xmlcalabash2/
(defvar xproc-processor "calabash")

(defvar org-babel-default-header-args:xproc
  '((:results . "output") (:cmdline . ""))
  "Default arguments to use when evaluating an XProc pipeline.")

(defun org-babel-execute:xproc (body params)
  "Execute a block of XProc with org-babel.
This function is called by `org-babel-execute-src-block'."
  (message "executing XProc source code block")
  (let ((cmdline (cdr (assq :cmdline params)))
        (in-file (org-babel-temp-file "xproc-"))
	(out-file (org-babel-temp-file "xproc-output-")))
    (with-temp-file in-file (insert body))
    (message "%s" (concat "/Users/ndw/bin/meerschaum"
			  " " cmdline
			  " " (org-babel-process-file-name in-file)))
    (with-output-to-string
      (shell-command (concat "/Users/ndw/bin/meerschaum"
			     " " cmdline
			     " " (org-babel-process-file-name in-file)
			     " > " (org-babel-process-file-name out-file))))
    (with-temp-buffer (insert-file-contents out-file) (buffer-string))))

(defun org-babel-prep-session:xproc (_session _params)
  (error "XProc does not support sessions"))

(provide 'xproc-mode)

;;; xproc-mode.el ends here
