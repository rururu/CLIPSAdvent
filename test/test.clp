;; Test example

(deftemplate command
   (multislot text))

(defglobal ?*user-commands* = (create$ "test" "clock" "error"))

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

(defrule test
   ?c <- (command (text test))
   =>
   (println "test rule")
   (retract ?c)
   (println-buf "The test action")
   (println-buf "image \"img/south.jpg\"")
   (println-buf "audio \"audio/Tadamm.mp3\"")
   (println-buf "Second test action"))

(defrule clock
   ?c <- (command (text clock))
   =>
   (println "clock rule")
   (retract ?c)
   (println-buf "video \"video/Clock.mp4\"")
   (println-buf "clock"))

(defrule error
   ?c <- (command (text error ?type))
   =>
   (println "error rule")
   (retract ?c)
   (print-buf (str-cat "Err: " ?type)))




