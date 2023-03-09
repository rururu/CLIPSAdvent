(deffacts initial_state
   (command (text look)))

(deffacts command_patterns_core
   (command_pattern (text quit)
                    (action quit))
   (command_pattern (text get <thing>)
                    (action take))
   (command_pattern (text take <thing>)
                    (action take))
   (command_pattern (text grab <thing>)
                    (action take))
   (command_pattern (text drop <thing>)
                    (action drop))
   (command_pattern (text inventory)
                    (action inventory))
   (command_pattern (text help)
                    (action help)))

(deffacts command_patterns_go
   (command_pattern (text south)
                    (action go south))
   (command_pattern (text go south)
                    (action go south))
   (command_pattern (text north)
                    (action go north))
   (command_pattern (text go north)
                    (action go north))
   (command_pattern (text east)
                    (action go east))
   (command_pattern (text go east)
                    (action go east))
   (command_pattern (text west)
                    (action go west))
   (command_pattern (text go west)
                    (action go west))
   (command_pattern (text up)
                    (action go up))
   (command_pattern (text go up)
                    (action go up))
   (command_pattern (text climb up)
                    (action go up))
   (command_pattern (text down)
                    (action go down))
   (command_pattern (text go down)
                    (action go down))
   (command_pattern (text climb down)
                    (action go down)))

(deffacts command_patterns_look
   (command_pattern (text look around)
                    (action look))
   (command_pattern (text look)
                    (action look))
   (command_pattern (text look at <thing>)
                    (action look at))
   (command_pattern (text examine <thing>)
                    (action look at))
   (command_pattern (text search <thing>)
                    (action search)))
