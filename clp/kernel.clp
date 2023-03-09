
(defrule MAIN::start
   =>
   (if (open "clp/game.fct" game)
      then
      (close game)
      (retract *)
      (bload-facts "clp/game.fct")
      (assert (command (text look)))
      (focus COMMAND)
      else
      (focus INITIAL COMMAND)))

;;; ###########
;;; CORE Module
;;; ###########

(defmodule CORE (import MAIN ?ALL))

;;; **************
;;; Location Rules
;;; **************

(defrule print_place

   ;; The command is look

   ?c <- (command (action look))

   ;; The adventurer is at a location

   (thing (id adventurer)
          (location ?location))

   ;; Retrieve the description of the location

   (thing (id ?location) 
          (category place)
          (definite ?definite)
          (description $?text))

   =>

   ;; The command has been processed

   (retract ?c)

   ;; Display command results
   (println-buf (str-cat "You're at " ?definite "."))
   (foreach ?line ?text
      (println-buf ?line))
   (println-buf "")
   (do-for-all-facts ((?t thing))
                     (and (eq ?t:location ?location)
                          (eq ?t:category item))   
      (println-buf (str-cat "You can see " ?t:indefinite "."))))

;;; **************
;;; Movement Rules
;;; **************

(defrule go_valid_path

   ;; The command is go <direction>

   ?c <- (command (action go ?direction))

   ;; The adventurer is at a location

   ?p <- (thing (id adventurer)
                (location ?location))

   ;; There is an unblocked path from the
   ;; adventurer's location to a new 
   ;; location in the specified direction

   (path (direction $? ?direction $?)
         (from $? ?location $?)
         (to ?new_location)
         (blocked FALSE))

   =>

   ;; The command has been processed

   (retract ?c)

   ;; The adventurer moves to the new location

   (modify ?p (location ?new_location))

   ;; Create a look command to describe
   ;; the new location

   (assert (command (action look))))

(defrule go_invalid_path

   ;; The command is go <direction>

   ?c <- (command (action go ?direction))

   ;; The adventurer is at a location

   ?p <- (thing (id adventurer)
                (location ?location))

   ;; There is no path from the adventurer's
   ;; location to a new location in the
   ;; specified direction

   (not (path (direction $? ?direction $?)
              (from $? ?location $?)))

   =>

   ;; The command has been processed

   (retract ?c)

   ;; Display command results

   (println-buf "You can't go there."))

(defrule go_valid_path_blocked

   ;; The command is go <direction>

   ?c <- (command (action go ?direction))

   ;; The adventurer is at a location

   ?p <- (thing (id adventurer)
                (location ?location))

   ;; There is a blocked path from the
   ;; adventurer's location to a new 
   ;; location in the specified direction

   (path (direction $? ?direction $?)
         (from $? ?location $?)
         (to ?new_location)
         (blocked TRUE)
         (blocked_message ?text))

   =>

   ;; The command has been processed

   (retract ?c)

   ;; Display command results

   (println-buf ?text))

;;; **********
;;; Look Rules
;;; **********

(defrule look_description

   ;; The command is look at <thing>

   ?c <- (command (action look at ?id))

   ;; The adventurer is at a location

   (thing (id adventurer)
          (location ?location))

   ;; The thing is at the same location 
   ;; as or held by the adventurer

   (thing (id ?id)
          (location ?location | adventurer)
          (description $?text))

   ;; The thing has a description

   (test (> (length$ ?text) 0))

   =>

   ;; The command has been processed

   (retract ?c)

   ;; Display command output

   (foreach ?line ?text
      (println-buf ?line)))

(defrule look_no_description

   ;; The command is look at <thing>

   ?c <- (command (action look at ?id))

   ;; The adventurer is at a location

   (thing (id adventurer)
          (location ?location))

   ;; The thing is at the same location 
   ;; as or held by the adventurer and
   ;; it has no description

   (thing (id ?id)
          (location ?location | adventurer)
          (description))

   =>

   ;; The command has been processed

   (retract ?c)

   ;; Display command results

   (println-buf "You see nothing special."))

(defrule search_nothing_found

   ;; The command is search <thing>
   
   ?c <- (command (action search ?id))
   
   =>
   
   ;; The command has been processed
   
   (retract ?c)
   
   ;; Display command results
   
   (println-buf "You find nothing of interest."))

;;; *********
;;; Quit Rule
;;; *********

(defrule quit
   ?c <- (command (action quit))
   =>
   (retract ?c)
   (bsave-facts "clp/game.fct" visible)
   (halt))

;;; *********
;;; Help Rule
;;; *********

(defrule help

   ;; The command is help

   ?c <- (command (action help))

   =>

   ;; The command has been processed

   (retract ?c)

   ;; Create an empty list
   
   (bind ?list (create$))
   
   ;; Convert each command pattern to
   ;; a string and add it to the list
   
   (do-for-all-facts ((?f command_pattern)) TRUE
      (bind ?text (implode$ ?f:text))
      (bind ?list (create$ ?list ?text)))
      
   ;; Sort the list
   
   (bind ?list (sort sort-string ?list))
   
   ;; Display command results
   
   (println-buf "Commands I understand are:")
   (foreach ?item ?list
      (println-buf (str-cat "   " ?item))))
      
;;; ***************
;;; Take/Drop Rules
;;; ***************

(defrule take_valid_thing
   ;; The command is take <thing>
   ?c <- (command (action take ?id))
   ;; The thing can be taken
   ?t <- (thing (id ?id)
                (attributes $? can_be_taken $?)
                (location ?location)
                (definite ?text))
   ;; The adventurer is at the same
   ;; location as the thing
   (thing (id adventurer)
          (location ?location))
   =>
   ;; The command has been processed
   (retract ?c)
   ;; The thing is not held by the adventurer
   (modify ?t (location adventurer))
   ;; Display command results
   (println-buf (str-cat "You take " ?text ".")))

(defrule take_invalid_thing
   ;; The command is take <thing>
   ?c <- (command (action take ?id))
   ;; The thing can not be taken
   (thing (id ?id)
          (attributes $?attributes)
          (location ?location)
          (definite ?text))
   (test (not (member$ can_be_taken ?attributes)))
   ;; The adventurer is at the same
   ;; location as the thing
   (thing (id adventurer)
          (location ?location))
   =>
   ;; The command has been processed
   (retract ?c)
   ;; Display command results
   (println-buf (str-cat "You can't take " ?text ".")))

(defrule take_carried_thing
   ;; The command is take <thing>
   ?c <- (command (action take ?id))
   ;; The thing is held by the adventurer
   (thing (id ?id)
          (location adventurer)
          (definite ?text))
   =>
   ;; The command has been processed
   (retract ?c)
   ;; Display command results
   (println-buf (str-cat "You already have " ?text ".")))

(defrule drop_valid_thing
   ;; The command is drop <thing>
   ?c <- (command (action drop ?id))
   ;; The thing is held by the adventurer
   ?t <- (thing (id ?id)
                (location adventurer)
                (definite ?text))
   ;; Retrieve the adventurer's location
   (thing (id adventurer)
          (location ?location))
   =>
   ;; The command has been processed
   (retract ?c)
   ;; The thing is now at the adventurer's location
   (modify ?t (location ?location))
   ;; Display command results
   (println-buf (str-cat "You drop " ?text ".")))

(defrule drop_invalid_thing
   ;; The command is drop <thing>
   ?c <- (command (action drop ?id))
   ;; The thing is not held by the adventurer
   (thing (id ?id)
          (location ~adventurer)
          (definite ?text))
   =>
   ;; The command has been processed
   (retract ?c)
   ;; Display command results
   (println-buf (str-cat "You don't have " ?text ".")))

;;; ***************
;;; Inventory Rules
;;; ***************

(defrule inventory_empty
   ;; The command is inventory
   ?c <- (command (action inventory))
   ;; There are no things held by the adventurer
   (not (thing (category item)
               (location adventurer)))
   =>
   ;; The command has been processed
   (retract ?c)
   ;; Display command results
   (println-buf "You are not carrying anything."))

(defrule inventory_not_empty
   ;; The command is inventory
   ?c <- (command (action inventory))
   ;; There is at least one thing
   ;; held by the adventurer
   (exists (thing (category item)
                  (location adventurer)))
   =>
   ;; The command has been processed
   (retract ?c)
   ;; Display command results
   (println-buf "You are carrying:")
   (do-for-all-facts ((?t thing))
                     (and (eq ?t:category item)
                          (eq ?t:location adventurer))
      (println-buf  (str-cat "   " ?t:indefinite))))

;;; ************
;;; Restart Rule
;;; ************

(defrule restart
   ?c <- (command (action restart))
   =>
   (retract ?c)
   (if (eq (yes-or-no-p "Restart game? ") yes)
      then
      (remove "clp/game.fct")
      (reset)))

;;; ##############
;;; COMMAND Module
;;; ##############

(defmodule COMMAND (import MAIN ?ALL))

(defrule bad_command
   (declare (salience ?*low*))
   ?c <- (command)
   =>
   (println-buf "I don't understand your command.")
   (retract ?c))

(defrule get_command
   
   ;; There is no command to process
   
   (not (command))
   
   =>
   
   ;; Print the prompt for a command
   
   (println "")
   (print "> ")
   
   ;; Retrieve the player's command 
   ;; and convert it to lower case 
   
   (bind ?rsp (explode$ (lowcase (readline-ext))))
   
   ;; Split the player's command into multiple
   ;; symbols and store in a command fact
   
   (assert (command (text ?rsp))))

(defrule focus_translate
   (command (text ? $?) (action))
   =>
   (focus TRANSLATE))

;;; ################
;;; TRANSLATE Module
;;; ################
   
(defmodule TRANSLATE (import MAIN ?ALL))

(defrule translate

   ;; There is a command with no action assigned
   
   ?c <- (command (text $?text) (action))
   
   ;; The command does not reference a <thing>
   
   (test (not (member$ <thing> ?text)))
   
   ;; There is a command pattern mapping 
   ;; the command to an action
   
   (command_pattern (text $?text) (action $?action))
   
   =>
   
   ;; Assign the action to the command
   
   (modify ?c (action ?action)))

(defrule translate_one_thing_match

   ;; There is a command with no action assigned

   ?c <- (command (text $?before $?prefix ?id) (action))

   ;; There is a command pattern mapping the command
   ;; to an action where the <thing> placeholder 
   ;; maps to the thing id found in the command
   
   (command_pattern (text $?before <thing>) (action $?action))
   
   ;; The adventurer is at a location
   
   (thing (id adventurer)
          (location ?location))
          
   ;; The thing referenced by the command is either at
   ;; the same location as or held by the adventurer
   
   (thing (id ?id)
          (prefixes $? =(implode$ ?prefix) $?)
          (location ?location | adventurer))
   
   ;; There is no other command pattern that
   ;; maps exactly to the command without the
   ;; use of the <thing> placeholder
          
   (not (command_pattern (text $?before $?prefix ?id)))

   =>
   
   ;; Assign the action to the command adding the
   ;; word assigned to the <thing> placeholder
   
   (modify ?c (action ?action ?id)))

(defrule translate_one_thing_no_match
   
   ;; Allow other translation rules 
   ;; to execute before this one 

   (declare (salience ?*low*))
   
   ;; There is a command with no action assigned
   
   ?c <- (command (text $?before $?prefix ?id) (action))
   
   ;; There is a command pattern mapping the command
   ;; to an action where the <thing> placeholder 
   ;; maps to the thing id found in the command

   (command_pattern (text $?before <thing>))
   
   =>
   
   ;; The command has been processed
   
   (retract ?c)
   
   ;; Display command results

   (println-buf "You can't see any such thing."))

(defrule process_action

   ;; An action has been assigned
   
   (command (action ? $?))
   
   =>
   
   ;; Focus on the modules to process the action
   
   (focus GAME CORE))

(defrule thing_must_be_held

   ;; Apply this rule before
   ;; other translation rules

   (declare (salience ?*high*))
   
   ;; There is a command pattern referencing
   ;; a thing that must be held
   
   (command_pattern (text $?action <thing>)
                    (attributes $? must_be_held $?))
                    
   ;; There is a command for that pattern
   
   ?c <- (command (action $?action ?thing))
   
   ;; The adventurer is not holding the thing
   
   (thing (id ?thing)
          (location ~adventurer)
          (definite ?definite))
          
   =>
   
   ;; The command has been processed
   
   (retract ?c)
   
   ;; Display command results
   
   (println-buf (str-cat "You're not holding " ?definite ".")))

(defrule unrecognized_word

   ;; There is a word contained in a command 
   
   ?c <- (command (text $? ?word $?))
   
   ;; There is no command pattern containing the word
   
   (not (command_pattern (text $? ?word&~<thing> $?)))
   
   ;; The word is not associated with scenery or 
   ;; items that the adventurer can interact with 
   
   (not (thing (id ?word) (category scenery | item)))
   
   ;; The word is not a prefix for a thing
   
   (not (and (thing (prefixes $? ?str $?))
             (test (member$ ?word (explode$ ?str)))))
   =>
   
   ;; The command has been processed
   
   (retract ?c)
   
   ;; Display command results
   
   (println-buf (str-cat "I don't know the word '" ?word "'.")))

;;; ##############
;;; INITIAL Module 
;;; ##############

(defmodule INITIAL (import MAIN ?ALL))
