#lang racket
;;;
;;; Browser
;;;

;; This module contains various browser related experiments.

(require "urlang.rkt" "urlang-extra.rkt" "for.rkt" syntax/parse)

(current-urlang-run?                           #t)
(current-urlang-echo?                          #t)
(current-urlang-console.log-module-level-expr? #t)

(define-urlang-macro define-html-tags
  (λ (stx)
    (syntax-parse stx
      [(_define-tags [<tag> tag] ...)
       (with-syntax ([(tag ...) (map ~a (map syntax->datum (syntax->list #'(tag ...))))])
         (syntax/loc stx
           (block
            (var [<tag> (λ (t)
                          (var [e (document.createElement tag)])
                          (e.appendChild t)
                          e)]
                 ...))))])))

(display
 (urlang
  (urmodule browser
    ; (import (all-from "runtime.rkt"))
    ; Note: Use <script src="../runtime.js"></script> to load the runtime
    (import string-append str) 
    ;; Available on the browser:
    (import document window prompt alert window.document.body.onload)
    ;; These should move to urlang.rkt
    (import Array Int8Array Number String new typeof this)
    ;; Imported from Raphael.js
    (import Raphael)
    
    ;; Define constructors for elements of various types.
    (define-html-tags [<h1> h1] [<p> p] [<p> p] [<div> div])
    ;; (insert t) inserts a dom element into the body    
    (define intro #f)
    (define (insert t) (intro.appendChild t))
    ;; text nodes
    (define (text t)   (document.createTextNode t))

    (define (draw)
      ;; The html has a <div id="holder"></div>. Put a canvas there.
      (var [r (Raphael "holder" 720 520)])
      ;; Draw circles 30 degrees apart
      (for ([angle in-range 0 360 30])
        (let ([t (+ "r" angle " 320 240")]  ; transformation : rotate angle around point
              [c (Raphael.getColor)])       ; each call returns new color in spectrum
          (let* ([v (r.circle 320 450 20)]  ; a circle with these attributes:
                 [v (v.attr (object [stroke c] [fill c] [transform t] ["fill-opacity" .4]))]
                 ;; The click handler moves the hand to the circle
                 [v (v.click     (λ()(s.animate    (object [stroke c] [transform t]) 2000 "bounce")))]
                 ;; the mouse over handler darkens the circle
                 [v (v.mouseover (λ()(this.animate (object ["fill-opacity" 0.75]) 500)))]
                 ;; the mouse out handler brightens the circle
                 [v (v.mouseout  (λ()(this.animate (object ["fill-opacity" 0.4])  500)))])
            v)))
      (Raphael.getColor.reset)
      (var [no-fill (λ (w) (object [fill "none"] ["stroke-width" w]))])
      (var [s (r.set)]) ; set to keep the elements of the "hand" (of the "clock")
      ((ref (s.push (r.path "M320,240c-50,100,50,110,0,190")) "attr") (no-fill  2)) 
      ((ref (s.push (r.circle 320 450 20))                    "attr") (no-fill  2))
      ((ref (s.push (r.circle 320 240 5))                     "attr") (no-fill 10))
      (s.attr (object [stroke (Raphael.getColor)]))) ; all elements of the hand get the same color
    
    ;; entry point called by browser
    (define (run-on-load)
      (:= intro (document.getElementById "intro")) ; register the body element (used by insert)
      (insert (<h1> (text "Welcome to Urlang")))   ; make header
      (insert (<p>  (text "This example illustrates how to use Raphael.")))
      (insert (<p>  (text "Click one of the circles.")))
      (draw))

    ;; Instruct the browser to run run-on-load when the page has loaded and the DOM is created.
    (window.addEventListener "load" run-on-load))))
