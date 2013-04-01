;;; Copyright (C) 2010, 2012 Rocky Bernstein <rocky@gnu.org>
;;; Ruby "trepan" Debugger tracking a comint or eshell buffer.

(eval-when-compile (require 'cl))
(require 'load-relative)
(require-relative-list '(
			 "../../common/cmds"
			 "../../common/menu"
			 "../../common/track"
			 "../../common/track-mode"
			 )
		       "realgud-")
(require-relative-list '("core" "init") "realgud-trepan-")
(require-relative-list '("../../lang/ruby") "realgud-lang-")

(realgud-track-mode-vars "trepan")

(declare-function realgud-track-mode(bool))

(defun realgud-trepan-goto-control-frame-line (pt)
  "Display the location mentioned by a control-frame line
described by PT."
  (interactive "d")
  (realgud-goto-line-for-pt pt "control-frame"))

(defun realgud-trepan-goto-syntax-error-line (pt)
  "Display the location mentioned in a Syntax error line
described by PT."
  (interactive "d")
  (realgud-goto-line-for-pt pt "syntax-error"))

(realgud-ruby-populate-command-keys trepan-track-mode-map)

(define-key trepan-track-mode-map
  (kbd "C-c !c") 'realgud-trepan-goto-control-frame-line)
(define-key trepan-track-mode-map
  (kbd "C-c !s") 'realgud-trepan-goto-syntax-error-line)

(defun trepan-track-mode-hook()
  (if trepan-track-mode
      (progn
	(use-local-map trepan-track-mode-map)
	(message "using trepan mode map")
	)
    (message "trepan track-mode-hook disable called"))
)

(define-minor-mode trepan-track-mode
  "Minor mode for tracking ruby debugging inside a process shell."
  :init-value nil
  ;; :lighter " trepan"   ;; mode-line indicator from realgud-track is sufficient.
  ;; The minor mode bindings.
  :global nil
  :group 'trepan
  :keymap trepan-track-mode-map
  (trepan-track-mode-internal trepan-track-mode)
)

;; Broken out as a function for debugging
(defun trepan-track-mode-internal (&optional arg)
  (realgud-track-set-debugger "trepan")
  (if trepan-track-mode
      (progn
	(setq realgud-track-mode 't)
	(realgud-track-mode-setup 't)
	(trepan-track-mode-hook))
    (progn
      (setq realgud-track-mode nil)
      ))
)

(provide-me "realgud-trepan-")
