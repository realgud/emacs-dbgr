;;; Copyright (C) 2010, 2012 Rocky Bernstein <rocky@gnu.org>
;;; Ruby "rdebug" Debugger tracking a comint or eshell buffer.

(eval-when-compile (require 'cl))
(require 'load-relative)
(require-relative-list '(
			 "../../common/cmds"
			 "../../common/menu"
			 "../../common/track"
			 "../../common/track-mode"
			 )
		       "realgud-")
(require-relative-list '("core" "init") "realgud-rdebug-")
(require-relative-list '("../../lang/ruby") "realgud-lang-")

(realgud-track-mode-vars "rdebug")

(declare-function realgud-track-mode(bool))

(realgud-ruby-populate-command-keys rdebug-track-mode-map)

(defun rdebug-track-mode-hook()
  (if rdebug-track-mode
      (progn
	(use-local-map rdebug-track-mode-map)
	(message "using rdebug mode map")
	)
    (message "rdebug track-mode-hook disable called"))
)

(define-minor-mode rdebug-track-mode
  "Minor mode for tracking ruby debugging inside a process shell."
  :init-value nil
  ;; :lighter " rdebug"   ;; mode-line indicator from realgud-track is sufficient.
  ;; The minor mode bindings.
  :global nil
  :group 'rdebug
  :keymap rdebug-track-mode-map
  (rdebug-track-mode-internal rdebug-track-mode)
)

;; Broken out as a function for debugging
(defun rdebug-track-mode-internal (&optional arg)
  (realgud-track-set-debugger "rdebug")
  (if rdebug-track-mode
      (progn
	(setq realgud-track-mode 't)
	(realgud-track-mode-setup 't)
	(rdebug-track-mode-hook))
    (progn
      (setq realgud-track-mode nil)
      ))
)

(provide-me "realgud-rdebug-")
