;;; mbs.el --- Minibuffer Stats  -*- lexical-binding: t; -*-

;; Copyright (C) 2022-2025  Shen, Jen-Chieh
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

(defconst mbs-read-file-name-commands
  `(,(or read-file-name-function #'read-file-name-default))
  "List of command to  detect find file action.")

(defvar mbs-reading-file-name-p nil
  "Return non-nil if reading file name.")

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
;;; Entry

(defun mbs-mode--adv-around (fnc &rest args)
  "Advice bind FNC and ARGS."
  (let ((mbs-reading-file-name-p t)) (apply fnc args)))

(defun mbs-mode--enable ()
  "Enable function `recentf-excl-mode'."
  (dolist (command mbs-read-file-name-commands)
    (advice-add command :around #'mbs-mode--adv-around)))

(defun mbs-mode--disable ()
  "Disable function `recentf-excl-mode'."
  (dolist (command mbs-read-file-name-commands)
    (advice-remove command #'mbs-mode--adv-around)))

;;;###autoload
(define-minor-mode mbs-mode
  "Minor mode `mbs-mode'."
  :global t
  :require 'mbs-mode
  :group 'mbs
  (if mbs-mode (mbs-mode--enable) (mbs-mode--disable)))

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
    (or mbs-reading-file-name-p
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
