;;; ***************
;;; Adventure Start
;;; ***************

(defrule exposition
   (declare (salience 10))
   =>
   (println-buf "Captured by goblins, you've been")
   (println-buf "tossed in a pit at their lair.")
   (println-buf ""))

;;; ********
;;; Deffacts
;;; ********

(deffacts player
   (thing (id adventurer)
          (category actor)
          (location pit_north)))

(deffacts places
   (thing (id pit_north)
          (category place)
          (definite "the pit's north end")
          (description
             "A giant mushroom is here. The"
             "ground is littered with the"
             "bodies of dead adventurers."
             "image \"img/AinRBP1.jpg\""))
   (thing (id pit_south)
          (category place)
          (definite "the pit's south end")
          (description
             "A large pile of rubble has"
             "collapsed from the wall above."
             "image \"img/south.jpg\""
             "audio \"audio/Tadamm.mp3\"")
          (attributes hard_ground)))

(deffacts paths
   (path (direction south)
         (from pit_north)
         (to pit_south))
   (path (direction north)
         (from pit_south)
         (to pit_north))
   (path (direction up)
         (from pit_north pit_south)
         (blocked TRUE)
         (blocked_message
            "The walls are too slick.crlfimage \"img/slick.jpg\"")))

(deffacts scenery
   (thing (id mushroom)
          (location pit_north)
          (category scenery)
          (definite "the giant mushroom")
          (indefinite "a giant mushroom")
          (prefixes "" "the" "giant" "the giant")
          (description "It's squished. I wouldn't"
                       "try landing on it again."
                       "image \"img/squished.jpg\""))
   (thing (id bodies)
          (location pit_north)
          (category scenery)
          (definite "the bodies")
          (indefinite "bodies")
          (prefixes "" "the")
          (description "Apparently this is what happens"
                       "when you miss the mushroom."
                       "image \"img/dead.jpg\""))
   (thing (id rubble)
          (location pit_south)
          (category scenery)
          (definite "the rubble")
          (indefinite "rubble")
          (prefixes "" "the" "pile of" "the pile of"
                    "large pile of" "the large pile of")))

(deffacts things
   (thing (id goblin)
          (location rubble)
          (category item)
          (prefixes "" "the" "dead" "the dead")
          (definite "the dead goblin")
          (indefinite "a dead goblin"))
   (thing (id beans)
          (location goblin)
          (category item)
          (prefixes "" "the")
          (definite "the beans")
          (indefinite "some beans")
          (description "These are no ordinary beans.")
          (attributes can_be_taken))
   (thing (id stalk)
          (category item)
          (prefixes "" "the" "giant" "the giant")
          (definite "the giant stalk")
          (indefinite "a giant stalk")
          (description "It's sturdy enough to climb.")))

(deffacts command_patterns_adventure
   (command_pattern (text plant <thing>)
                    (action plant)
                    (attributes must_be_held))
   (command_pattern (text climb <thing>)
                    (action climb)))

;;; ************
;;; Search Rules
;;; ************

(defrule search_rubble
   ;; The command is search rubble
   ?c <- (command (action search rubble))
   ;; Retrieve the adventurer's location
   (thing (id adventurer)
          (location ?location))
   ;; The goblin is buried in the rubble 
   ?g <- (thing (id goblin)
                (location rubble))
   =>
   ;; The command has been processed
   (retract ?c)
   ;; The goblin is now at the
   ;; adventurer's location
   (modify ?g (location ?location))
   ;; Display command results
   (println-buf "You find a dead goblin.")
   (println-buf "image \"img/dead_goblin.jpg\"")
   (println-buf "He probably fell from above."))

(defrule search_goblin
   ;; The command is search goblin
   ?c <- (command (action search goblin))
   ;; Retrieve the adventurer's location
   (thing (id adventurer)
          (location ?location))
   ;; The beans are in the goblin's pocket
   ?b <- (thing (id beans)
                (location goblin))
   =>
   ;; The command has been processed
   (retract ?c)
   ;; The beans are now at the
   ;; adventurer's location
   (modify ?b (location ?location))
   ;; Display command results
   (println-buf "image \"img/coffee-beans.jpg\"")
   (println-buf "audio \"audio/Tadamm.mp3\"")
   (println-buf "Some beans are in his pockets."))

;;; *****************
;;; Plant Beans Rules
;;; *****************

(defrule plant_beans_hard_ground
   ;; The command is plant beans
   ?c <- (command (action plant beans))
   ;; The ground at the adventurer's
   ;; location is hard
   (thing (id adventurer)
          (location ?location))
   (thing (id ?location)
          (attributes $?attributes))
   (test (member$ hard_ground ?attributes)) 
   =>
   ;; The command has been processed
   (retract ?c)
   ;; Display command results
   (println-buf "The ground is too hard.")
   (println-buf "image \"img/hard_ground.jpg\""))

(defrule plant_beans_soft_ground
   ;; The command is plant beans
   ?c <- (command (action plant beans))
   ;; The beans are in play
   ?b <- (thing (id beans)
                (location ~nowhere))
   ;; The ground at the adventurer's 
   ;; location is not hard
   (thing (id adventurer)
          (location ?location))
   (thing (id ?location)
          (attributes $?attributes))
   (test (not (member$ hard_ground ?attributes)))
   ;; The stalk has not grown from the beans
   ?s <- (thing (id stalk)
                (location nowhere))
   =>
   ;; The command has been processed
   (retract ?c)
   ;; The beans disappear
   (modify ?b (location nowhere))
   ;; The stalk appears at the
   ;; adventurer's location
   (modify ?s (location ?location))
   ;; Display command results
   (println-buf "Apparently the beans are magical.")
   (println-buf "image \"img/stalk.jpg\"")
   (println-buf "They grow into a giant stalk."))

;;; ****************
;;; Climb Stalk Rule
;;; ****************

(defrule climb_stalk
   ;; The command is climb stalk
   ?c <- (command (action climb stalk))
   ;; The adventurer is at the same
   ;; location as the stalk
   (thing (id adventurer)
          (location ?location))
   (thing (id stalk)
          (location ?location))
   =>
   ;; The command has been processed
   (retract ?c)
   ;; Display command results
   (println-buf "You have escaped!")
   (println-buf "video \"video/climbing_out.mp4\"")
   (println-buf "audio \"audio/Tush.mp3\"")
   ;; Halt the game
   (halt))
