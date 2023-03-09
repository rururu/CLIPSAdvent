;; Communication with CLIPS through files

(defglobal ?*commout-buf* = "")

;; Communication functions

(deffunction pause (?delay)
   (bind ?start (time))
   (while (< (time) (+ ?start ?delay)) do))

(deffunction clear-file (?path)
   (open ?path commin "w")
   (printout commin "")
   (close commin))

(deffunction commin ()
  (open "data/commin.txt" coin "r")
  (bind ?rl (readline coin))
  (close coin)
  (if (neq ?rl EOF)
    then
    (clear-file "data/commin.txt")
    (return ?rl))
  "")

(deffunction print-buf (?text)
   (bind ?*commout-buf* (str-cat ?*commout-buf* ?text)))

(deffunction println-buf (?text)
   (bind ?*commout-buf* (str-cat ?*commout-buf* ?text crlf)))

(deffunction get-buf ()
   (bind ?buf ?*commout-buf*)
   (bind ?*commout-buf* "")
   ?buf)

(deffunction readline-ext ()
   (bind ?rle "")
   (while (eq (bind ?rle (commin)) "")
      (pause 1))
   ?rle)




