(defmodule MAIN (export ?ALL))

(defglobal ?*high* = 10
           ?*low* = -10)
      
(deffunction sort-string (?s1 ?s2)
   (> (str-compare ?s1 ?s2) 0))

(deffunction ask-question (?question $?values)
   (bind ?answer (void))
   (while (not (member$ ?answer ?values)) do
      (print ?question)
      (bind ?answer (read))
      (if (lexemep ?answer) 
          then (bind ?answer (lowcase ?answer))))
   ?answer)

(deffunction yes-or-no-p (?question)
   (bind ?answer (ask-question ?question yes no y n))
   (if (or (eq ?answer yes) (eq ?answer y))
       then yes 
       else no))

(deftemplate thing
   (slot id)
   (slot category
      (allowed-values place item actor scenery))
   (slot location 
      (default nowhere))
   (multislot description)
   (multislot prefixes (default ""))
   (slot definite (default ""))
   (slot indefinite (default ""))
   (multislot attributes))

(deftemplate command
   (multislot text)
   (multislot action))

(deftemplate path
  (multislot direction)
  (multislot from)
  (slot to (default nowhere))
  (slot blocked (default FALSE))
  (slot blocked_message (default "The way is blocked.")))

(deftemplate command_pattern
   (multislot text)
   (multislot action)
   (multislot attributes))

(deffunction commands-list ()
   (bind ?list (create$))
   (do-for-all-facts ((?f command_pattern)) TRUE
   (bind ?text (implode$ ?f:text))
   (bind ?list (create$ ?list ?text)))
   (implode$ ?list))

;; Redefinition of comm.clp

(deffunction user-command (?uc)
   (bind ?uc (explode$ (lowcase ?uc)))
   (assert (command (text ?uc)))
   (focus COMMAND))
