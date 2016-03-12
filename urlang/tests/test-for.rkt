#lang racket
(require urlang        ; Urlang
         urlang/for    ; for-loop extesion
         rackunit)     ; tests library

;;;
;;; TEST
;;;

;;; Note: No output means all tests ran successfully.
;;;       (Set current-urlang-echo? to #f if you don't want
;;;        to the generated JavaScript).

;;; Note: You need to install  node  in order to run these tests.
;;;            https://nodejs.org/en/

;;; Running these tests will for each module produce
;;; both a JavaScript file and a file containing names of exports.

;;; Then node (a command line version of the JavaScript engine
;;; used in Chrome) is invoked on the JavaScript file, and the
;;; output is compared with the expected output.


(current-urlang-run?                           #t) ; run using Node?
(current-urlang-echo?                          #t) ; print generated JavaScript?
(current-urlang-console.log-module-level-expr? #t) ; print top-level expression?

(define (rs s) (read (open-input-string s)))

; test for with single clause and in-range
(check-equal? (rs (urlang
                   (urmodule test-for
                     (define sum 0)
                     (for ([x in-range 1 101])
                       (+= sum x))
                     sum)))
              5050)

; test in-array
(check-equal? (rs (urlang
                   (urmodule test-for
                     (define sum 0)
                     (for ([x in-array (array 1 2 3 4 5)])
                       (+= sum x))
                     sum)))
              15)

; test for with two parallel clauses
(check-equal? (rs (urlang
                   (urmodule test-for
                     (define sum 0)
                     (for ([x in-array (array 1 2 3 4 5)]
                           [y in-range 100 200])
                       (+= sum (+ x y)))
                     sum)))
              525)

; test in-naturals and #:break <guard>
(check-equal? (rs (urlang
                   (urmodule test-for
                     (define sum 0)
                     (define stop? #f)
                     (for ([x in-naturals 1])
                       (+= sum x)
                       #:break (= x 5))
                     sum)))
              15)

; test in-naturals works from varying starting points
(check-equal? (rs (urlang
                   (urmodule test-for
                     (define sum 0)
                     (define stop? #f)
                     (for ([x in-naturals 3])
                       (+= sum x)
                       #:break (= x 5))
                     sum)))
              12)

; test in-string
(check-equal? (urlang (urmodule test-in-string
                        (for/array ([x in-string "foobar"]) x)))
              (urlang (urmodule test-in-string2
                        (array "f" "o" "o" "b" "a" "r"))))


;;; for/sum
(check-equal? (rs (urlang (urmodule test-in-string
                            (for/sum ([x in-range 1 6]) x))))
              15)

;;; for/product
(check-equal? (rs (urlang (urmodule test-in-string
                            (for/product ([x in-range 1 6]) x))))
              120)

;;; for/and
(check-equal? (rs (urlang (urmodule test-in-string
                            (for/and ([x in-range 1 5]) x))))
              4)
(check-equal? (rs (urlang (urmodule test-in-string
                            (for/and ([x in-range 1 5]) (= x 3)))))
              'false)

(check-equal? (rs (urlang (urmodule test-in-string
                            (for/and () 3))))
              3)

;;; for/or
(check-equal? (rs (urlang (urmodule test-in-string
                            (for/or ([x in-range 1 5]) x))))
              1)
(check-equal? (rs (urlang (urmodule test-in-string
                            (for/or ([x in-range 1 5]) (= x 3)))))
              'true)

(check-equal? (rs (urlang (urmodule test-in-string
                            (for/or () 3))))
              3)

;;; Multiple clauses in for*
(check-equal? (rs (urlang
                   (urmodule test-for
                     (define sum 0)
                     (for* ([y in-range 1 11]
                            [x in-array (array 1 2 3 4 5)])
                       (+= sum x))
                     sum)))
              150)

(check-equal? (rs (urlang
                   (urmodule test-for
                     (define sum 0)
                     (for* ([y in-range 1 11]
                            [x in-array (array 1 2 3 4 5)])
                       #:break (= y 5)
                       (+= sum x))
                     sum)))
              (* 4 15))

;;; Parallel clauses stop when one of the clauses are exhausted.
(check-equal? (rs (urlang
                   (urmodule test-for
                     (define i 0)
                     (for ([y in-range 1 11]
                           [x in-range 1 5])
                       (:= i (+ (* 10 y) x)))
                     i)))
              44)

(check-equal? (urlang (urmodule test-for (for/array ([x in-range 3 7]) x)))
              (urlang (urmodule test-for2 (array 3 4 5 6))))

(check-equal? (urlang (urmodule test-for (for/array #:length 4 ([x in-range 3 7]) x)))
              (urlang (urmodule test-for2 (array 3 4 5 6))))

(check-equal? (urlang (urmodule test-for  (array 42 (for/array #:length 4 ([x in-range 3 7]) x))))
              (urlang (urmodule test-for2 (array 42 (array 3 4 5 6)))))


;;; check for in expression context
(check-equal? (rs (urlang (urmodule test-for (+ 0 (for/sum ([x in-range 1 6]) x)))))
              15)
