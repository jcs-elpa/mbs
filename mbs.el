;;; mbs.el --- Minibuffer Stats  -*- lexical-binding: t; -*-

;; Copyright (C) 2022-2024  Shen, Jen-Chieh
;; Created date 2022-04-19 21:01:22

;; Author: Shen, Jen-Chieh <jcs090218@gmail.com>
;; URL: https://github.com/jcs-elpa/mbs
;; Version: 0.1.0
;; Package-Requires: ((emacs "26.1") (s "1.12.0"))
;; Keywords: convenience minibuffer stats

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Minibuffer Stats
;;

;;; Code:

(require 's)

(defgroup mbs nil
  "Minibuffer Stats."
  :prefix "mbs-"
  :group 'convenience
  :group 'tools
  :link '(url-link :tag "Repository" "https://github.com/jcs-elpa/mbs"))

;;
;;; Externals

(defvar vertico--candidates)

;;
;;; Util

;;;###autoload
(defmacro mbs-with-minibuffer-env (&rest body)
  "Execute BODY with minibuffer variables."
  (declare (indent 0) (debug t))
  `(let ((prompt (minibuffer-prompt))
         (contents (minibuffer-contents)))
     ,@body))

;;
;;; Plugins

(defun mbs--vertico-read-file-p ()
  "Return non-nil when vertico is reading file name."
  (when-let (((bound-and-true-p vertico-mode))
             (name (car vertico--candidates)))
    (or (file-exists-p name)
        (file-exists-p (expand-file-name name)))))

;;
;;; Core

;;;###autoload
(defun mbs-M-x-p ()
  "Return non-nil if current minibuffer `M-x'."
  (mbs-with-minibuffer-env
    (string-prefix-p "M-x" prompt)))

;;;###autoload
(defun mbs-reading-file-name-p ()
  "Return non-nil if current minibuffer finding file."
  (mbs-with-minibuffer-env
    (or (mbs--vertico-read-file-p)
        (and (not (mbs-M-x-p))
             (not (string-empty-p contents))
             (ignore-errors (expand-file-name contents))))))

;;;###autoload
(defalias 'mbs-finding-file-p #'mbs-reading-file-name-p)

;;;###autoload
(defun mbs-renaming-p ()
  "Return non-nil if current minibuffer renaming."
  (mbs-with-minibuffer-env
    (string-prefix-p "New name:" prompt)))

;;;###autoload
(defun mbs-tramp-p ()
  "Return non-nil if current minibuffer connect over tramp."
  (mbs-with-minibuffer-env
    (and (mbs-finding-file-p)
         (s-contains-p ":" contents)
         (string-prefix-p "/" contents))))

(provide 'mbs)
;;; mbs.el ends here
