(require 'test-simple)
(setq trepan-core "../realgud/debugger/trepan/core.el")
(load-file "../realgud/common/core.el")

;; We use a specific langues to test core. Here we use trepan.
(load-file "../realgud/debugger/trepan/core.el")

(test-simple-start)

(lexical-let ((opt-two-args '("0" "C" "e" "E" "F" "i")))
  (assert-equal '(("-0" "a") nil)
		(realgud-parse-command-arg '("-0" "a") '() opt-two-args)
		  "Two args found, none remain afterwards though.")

  (assert-equal
   '(("-5") ("a" "-0"))
   (realgud-parse-command-arg '("-5" "a" "-0") '()
				    opt-two-args)
   "One arg not found.")

  (assert-equal
   '((nil) nil)
   (realgud-parse-command-arg '() '() opt-two-args)
   "Degenerate case - no args"
   )

  (assert-equal
   '(("--port" "123") ("bar"))
   (realgud-parse-command-arg
    '("--port" "123" "bar") '("-port") '())
   "two mandatory args"
   )

  (assert-equal
   '(("/usr/bin/ruby1.9" "-W") ("trepan") ("foo") nil)
   (trepan-parse-cmd-args
    '("/usr/bin/ruby1.9" "-W" "trepan" "foo"))
     "Separate Ruby with its arg from debugger and its arg.")

  (assert-equal
   '(("ruby1.9" "-T3") ("trepan" "--port" "123") ("bar") nil)
   (trepan-parse-cmd-args
    '("ruby1.9" "-T3" "trepan" "--port" "123" "bar"))
   "Ruby with two args and trepan with two args")

  (assert-equal
   '(nil ("trepan" "--port" "1" "--annotate=3")
	 ("foo" "a") t)
   (trepan-parse-cmd-args
    '("trepan" "--port" "1" "--annotate=3" "foo" "a"))
  "trepan with annotate args")

  (assert-equal
   '(nil ("trepan" "--port" "123")
	 ("foo" "--emacs" "a") nil)
   (trepan-parse-cmd-args
    '("trepan" "--port" "123" "foo" "--emacs" "a"))
   "trepan with --emacs in the wrong place")

  (assert-equal
   '(("ruby" "-I/usr/lib/ruby")
     ("trepan" "-h" "foo" "--emacs")
     ("baz") t)
   (trepan-parse-cmd-args
    '("ruby" "-I/usr/lib/ruby" "trepan" "-h" "foo"
      "--emacs" "baz"))
     "trepan with emacs")
  )

(end-tests)
