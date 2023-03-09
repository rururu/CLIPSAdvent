(deffunction sort-string (?s1 ?s2)
   (> (str-compare ?s1 ?s2) 0))

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
