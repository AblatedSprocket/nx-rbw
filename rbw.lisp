(in-package :nx-rbw)

(define-class rbw-interface (password-interface)
  ((executable (namestring (resolve-executable "rbw")))
	 (password-length
		12
		:type alexandria:non-negative-real
		:documentation "The length to use for generated passwords.")
	 (constraint
		nil
		:type symbol
		:documentation "This can be set to 'no-symbols', 'only-numbers', 'nonconfusables', or 'diceware' to constrain how a password is generated."))
  (:export-class-name-p t)
  (:export-accessor-names-p t))

(push 'rbw-interface *interfaces*)

(defmethod rbw-locked-p ((password-interface rbw-interface))
	(handler-case
			(uiop:run-program (list "rbw" "unlocked"))
		(error (c)
			(declare (ignore c))
			t)))

(defmethod unlock ((password-interface rbw-interface))
	(handler-case
			(execute password-interface
							 (list "unlock"))
		(error (c)
			(nyxt:echo-warning "login failed: " c))))

(defmethod list-passwords ((password-interface rbw-interface))
	(when (rbw-locked-p password-interface)
		(unlock password-interface))
  (mapcar #'(lambda (x)
							(let ((items (str:split (string #\tab)
																			x)))
								(concatenate 'string
														 (first items)
														 " ("
														 (second items)
														 ")")))
					(str:split (string #\newline)
										 (execute password-interface
															(list "list"
																		"--fields"
																		"name,folder")
															:output '(:string :stripped t)))))

(defmethod clip-password ((password-interface rbw-interface) &key password-name service)
	(declare (ignore service))
  (let* ((name-folder (str:split " ("
																 (subseq password-name 0 (- (length password-name) 1))))
				 (password (execute password-interface
														(list "get"
																	"--folder"
																	(second name-folder)
																	(first name-folder))
														:output '(:string :stripped t))))
		(trivial-clipboard:text password)
		password))

(defmethod clip-username ((password-interface rbw-interface) &key password-name service)
  (declare (ignore service))
  (let* ((name-folder (str:split " ("
																 (subseq password-name 0 (- (length password-name) 1))))
				 (username (execute password-interface
														(list "get"
																	"--folder"
																	(second name-folder)
																	"--field"
																	"username"
																	(first name-folder))
														:output '(:string :stripped t))))
		(trivial-clipboard:text username)
		username))

(defmethod save-password ((password-interface rbw-interface)
                          &key password-name username password service)
  (declare (ignore service))
	(when (rbw-locked-p password-interface)
		(unlock password-interface))
	(let ((constraint (when (str:emptyp password)
											(first (nyxt:prompt :prompt "Password constraint"
																					:sources (make-instance 'prompter:source
																																	:name "Contraint"
																																	:constructor '("None"
																																								 "No Symbols"
																																								 "Only Numbers"
																																								 "Nonconfusables"
																																								 "Diceware"))))))
				(uri (first (nyxt:prompt :prompt "Enter URL"
																 :sources (make-instance 'prompter:raw-source))))
				(folder (first (nyxt:prompt :prompt "Enter folder"
																		:sources (make-instance 'prompter:raw-source)))))
		(if (str:emptyp password)
				(with-slots (password-length) password-interface
					(execute password-interface
									 (append (list "generate")
													 (when (not (str:emptyp uri))
														 (list "--uri"
																	 uri))
													 (when (not (str:emptyp folder))
														 (list "--folder"
																	 folder))
													 (alexandria:switch (constraint :test 'equal)
																							("No Symbols" (list "--no-symbols"))
																							("Only Numbers" (list "--only-numbers"))
																							("Nonconfusables" (list "--nonconfusables"))
																							("Diceware" (list "--diceware"))
																							(t nil))
													 (list (write-to-string password-length)
																 password-name
																 username))))
				(with-input-from-string (st password)
					(execute password-interface
									 (append (list "add")
													 (when uri
														 (list "--uri"
																	 uri))
													 (when folder
														 (list "--folder"
																	 folder))
													 (list password-name
																 username))
									 :input st)))))

(defmethod password-correct-p ((password-interface rbw-interface))
  t)
