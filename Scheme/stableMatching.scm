#lang racket
; Comprehensive
;recursive McVitie-Wilson algorithm

;Your solution must include helper functions for your function findStableMatch to be able to take
;as input the names of two files containing the preference of coop employers and students as csv files.

(define M '())
(define employeePreferences '())
(define studentPreferences '())
(define len 0)

(define (read-csv f)
  (map (lambda (line)
         (string-split line (regexp-quote ",") #:trim? #f #:repeat? #t))
       (file->lines f)))

;; p is pair of (e, s), add pair to M
(define (add-pair p)
  (cond
    ((null? M) (set! M (list p)))
    (else
     (set-M (append M (list p))))))

(define (set-M L)
  (set! M L))


;; find the preference list with e in the large preference lists
(define (find-pair-by-e e L)
  (cond
    ((null? L) '())
    ((equal? (caar L) e) (car L))
    (else
     (find-pair-by-e e (cdr L)))
    ))

;find by s only search in M, list of pair
(define (find-pair-by-s s L)
  (cond
    ((null? L) '())
    ((equal? (cadar L) s ) (car L))
    ;(display "find s !!!  bengin!!! \n")(display L)(display (cadar L)) (display s) (display "end!! \n")
    (else (find-pair-by-s s (cdr L)))
    ))

; l is preference list of some employee
; find the most preferred student that not in M
(define (find-best-student l)
  (cond
    ((null? l ) '())
    ;if a student not matched yet, retrun the first unmatched student
    (else  (car l)))
  )

; p is pair of (e s)
(define (evaluate p)
  (set! employeePreferences (remove-s (cadr p) (car p) employeePreferences))
  
  (cond
    ((null? (find-pair-by-s (cadr p) M))
     (add-pair p))
    (else (update-match p))))

; remove a student, return new entire employeePreferences
(define (remove-s s e Le )
  (cond
    ((null? Le) '())
    ((equal? e (caar Le))
     (cons (remove s (find-pair-by-e e employeePreferences))
           (remove-s s e (cdr Le) )))
    (else
     (cons (car Le)
           (remove-s s e (cdr Le))))
    ))


;s prefers e to employer eʹ of current match (e’, s), Replace the match M → (e′, s) with (e, s) → M
(define (update-match p)
  (cond ((>
          ;current e' in M
          (index-of (find-pair-by-e (cadr p) studentPreferences)
                    (car (find-pair-by-s (cadr p) M)))
          ; e to update
          (index-of (find-pair-by-e (cadr p) studentPreferences)
                    (car p)))
         ;update with e
       
         (let ((current (find-pair-by-s (cadr p) M)))
           (set-M (remove current M))
           (add-pair p)
           (offer (car current))))
        (else
         ; current e' is better, re-offer e
         (offer (car p)))   
        ))

(define (offer e)
  (cond
    ; if e is unmatched, not found in M, 
    ((null? (find-pair-by-e e M))

     (evaluate (list e
                     (find-best-student (cdr (find-pair-by-e e employeePreferences))))))
    ))

(define (stableMatching Le Ls)
  ;(display "\n stable matching: ") (display (caar Le))
  (cond
    ((null? Le) M)
    (else
     ;(display (cdr Le))
     (offer (caar Le))
     (stableMatching (cdr Le) Ls
                     ))
    ))

(define (findStableMatch Fe Fs)
  (set! employeePreferences (read-csv Fe))
  (set! studentPreferences (read-csv Fs))
  (set! len (length employeePreferences))
  (stableMatching employeePreferences studentPreferences)
  (proc-out-file
   (string-append "matches_scheme_" (number->string len) "x" (number->string len) ".csv")
   write-csv)
)
(define write-csv
  (lambda (p)
    (let ((list-to-be-printed M))
    (let f ((l list-to-be-printed))
      (if (not (null? l))
          (begin
            (write (car l) p)
            (newline p)
            (f (cdr l)))
          null)))))


;data is 2D list
(define proc-out-file
  (lambda (filename proc)
    (let ((p (open-output-file filename #:exists 'replace)))
      (let ((v (proc p)))
        (close-output-port p)
        v))))

;(findStableMatch "coop_e_3x3.txt" "coop_s_3x3.txt" )
;(findStableMatch "coop_e_10x10.csv" "coop_s_10x10.csv")



