;;; realgud.el --- A modular front-end for interacting with external debuggers

;; Author: Rocky Bernstein
;; Version: 0.1.0
;; URL: http://github.com/rocky/emacs-loc-changes
;; Compatibility: GNU Emacs 24.x

;;  Copyright (C) 2013 Rocky Bernstein <rocky@gnu.org>

;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see
;; <http://www.gnu.org/licenses/>.

;;; Commentary:

;; A modular font-end for interacting with external debuggers.
;;
;; Debuggers we currently support are:

;;   NAME           INVOCATION*  WHAT
;    -----------------------------------
;; * bashdb         bashdb       bash
;; * Devel::Trepan  trepan.pl    Perl5
;; * gdb            realgud-gdb  gdb
;; * kshdb          kshdb        Korn Shell 93u+
;; * pdb            pdb          stock C Python debugger
;; * perldb         perldb       stock Perl5 debugger
;; * pydb           pydb         slighly enhanced pdb for Python 2.x
;; * pydbgr         pydbgr       trepanning debugger for Python 2.x
;; * rb8-trepanning trepan8      MRI Ruby 1.8 and an unpatched YARV 1.9
;; * rbx-trepanning trepanx      trepanning debugger for Rubinius Ruby
;; * remake         remake       GNU Make
;; * ruby-debug     rdebug       Ruby
;; * trepanning     trepan       trepanning debugger for a patched Ruby 1.9
;; * trepan         trepan3k     trepanning debugger for Python 3.x
;; * zshdb          zshdb        Zsh

;; *gdb invication requires the realgud- preface to disambiguate it
;; from the older, preexisting emacs command. The other invocations
;; also accept realgud- prefaces, e.g. realgud-bashdb or realgud-pdb.
;; Alas there is older obsolete Emacs code out there for bashdb,
;; kshdb, and rdebug.

;; The debugger is run out of a comint process buffer, or you can use
;; a “track-mode” inside an existing shell.

;; To install you’ll need a couple of other Emacs packages
;; installed. Should be available via Melpa. See the installation
;; instructions for details.

;;; Code:

(require 'load-relative)

(defgroup realgud nil
  "The Grand Cathedral Debugger rewrite"
  :group 'processes
  :group 'tools
  :version "23.1")

;; FIXME: extend require-relative for "autoload".
(defun realgud-load-features()
  (require-relative-list
   '(
     "./realgud/common/track-mode"
     "./realgud/debugger/bashdb/bashdb"
     "./realgud/debugger/gdb/gdb"
     "./realgud/debugger/kshdb/kshdb"
     "./realgud/debugger/pdb/pdb"
     "./realgud/debugger/perldb/perldb"
     "./realgud/debugger/pydb/pydb"
     "./realgud/debugger/pydbgr/pydbgr"
     "./realgud/debugger/rdebug/rdebug"
     "./realgud/debugger/remake/remake"
     "./realgud/debugger/trepan/trepan"
     "./realgud/debugger/trepan3k/trepan3k"
     "./realgud/debugger/trepan.pl/trepanpl"
     "./realgud/debugger/trepanx/trepanx"
     "./realgud/debugger/trepan8/trepan8"
     "./realgud/debugger/zshdb/zshdb"
     ) "realgud-")
  )

;; Really should be part of GNU Emacs. But until then...
(defmacro realgud-string-starts-with(string prefix)
  "compare-strings on STRING anchored from the beginning and up
  to length(PREFIX)"
  (declare (indent 1) (debug t))
  `(compare-strings ,prefix 0 (length ,prefix)
		    ,string  0 (length ,prefix))
  )

(defun realgud-feature-starts-with(feature prefix)
  "realgud-strings-starts-with on stringified FEATURE and PREFIX."
  (declare (indent 1) (debug t))
  (realgud-string-starts-with (symbol-name feature) prefix)
  )

(defun realgud-loaded-features()
  "Return a list of loaded debugger features. These are the
features that start with 'realgud-' and also include standalone debugger features
like 'pydbgr'."
  (let ((result nil))
    (dolist (feature features result)
      (cond ((eq 't
		 (realgud-feature-starts-with feature "realgud-"))
	     (setq result (cons feature result)))
	    ((eq 't
		 (realgud-feature-starts-with feature "pydbgr"))
	     (setq result (cons feature result)))
	    ((eq 't
		 ;; No trailing '-' to get a plain "trepan".
		 (realgud-feature-starts-with feature "trepan"))
	     (setq result (cons feature result)))
	    ((eq 't
		 ;; No trailing '-' to get a plain "trepanx".
		 (realgud-feature-starts-with feature "trepanx"))
	     (setq result (cons feature result)))
	    ('t nil))
	)
      )
)

(defun realgud-unload-features()
  "Remove all features loaded from this package. Used in
`realgud-reload-features'. See that."
  (interactive "")
  (let ((result (realgud-loaded-features)))
    (dolist (feature result result)
      (unload-feature feature 't)))
  )

(defun realgud-reload-features()
  "Reload all features loaded from this package. Useful if have
changed some code or want to reload another version, say a newer
development version and you already have this package loaded."
  (interactive "")
  (realgud-unload-features)
  (realgud-load-features)
  )

;; Load everything.
(realgud-load-features)

(provide-me)

;;; realgud.el ends here
