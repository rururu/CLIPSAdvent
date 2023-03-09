;; User commands definitions

(deffunction collect-user-commands (?cc)
   (do-for-all-facts ((?cp command_pattern)) TRUE
      (bind ?h (str-cat (nth$ 1 ?cp:text)))
      (if (not (member$ ?h ?cc))
         then
         (bind ?cc (create$ ?cc ?h))))
   ?cc)

(defglobal ?*user-commands* = (create$))

(deffunction map$ (?f ?mf)
   (bind ?r (create$))
   (foreach ?e ?mf
      (bind ?r (create$ ?r (funcall ?f ?e))))
   ?r)

(deffunction str-first (?s)
   (bind ?fsp (str-index " " ?s))
   (if ?fsp then (sub-string 1 (- ?fsp 1) ?s) else ?s))

(deffunction exec-user-command ()
   (assert (user-command (readline-ext)))
   (run))

(defrule user-command-execution
   (declare (salience -100))
   ?c <- (user-command ?usin)
   =>
   (retract ?c)
   (if (<= (length$ ?*user-commands*) 0)
      then
      (bind ?*user-commands* (collect-user-commands (create$ "error")))
      (println "User commands: " ?*user-commands*))
   (if (member$ (str-first ?usin) ?*user-commands*)
      then
      (bind ?cmd (explode$ ?usin))
      (bind ?cmd (map$ sym-cat ?cmd))
      (assert (command (text ?cmd)))
      else
      (if (neq ?usin "")
         then
         (println-buf (str-cat "Wrong command \"" ?usin "\"!")))))

;; Command execution rules

(defrule user-generated-error
   ?c <- (command (text error))
   =>
   (retract ?c)
   (print-buf (str-cat "Err: User generated error!")))




