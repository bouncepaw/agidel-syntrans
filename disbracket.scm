(module
 agidel-syntrans.disbracket
 *
 (import scheme
         (chicken base))

 (define (add-to-list lst elt)
   (append lst (list elt)))
 
 (define (main source-string)
   (let [[in-string? #f]
         [escaping-char? #f]
         [pairs-in-search 0]
         [acc '()]]
     (for-each
      (lambda (ch)
        (if in-string?
            (cond
             [escaping-char?
              (set! acc (add-to-list acc ch))
              (set! escaping-char? #f)]
             [in-string?
              (set! acc (add-to-list acc ch))
              (cond
               [(eq? ch #\") (set! in-string? #f)]
               [(eq? ch #\\) (set! escaping-char? #t)])])
            (cond
             [(eq? ch #\[)
              (set! acc (add-to-list acc (string->list "(_bracket")))
              (set! pairs-in-search (+ 1 pairs-in-search))]
             [(eq? ch #\])
              (set! acc (add-to-list acc #\)))
              (set! pairs-in-search (- pairs-in-search 1))]
             [(eq? ch #\")
              (set! in-string? #t)
              (set! acc (add-to-list acc ch))]
             [else
              (set! acc (add-to-list acc ch))])))
      (string->list source-string))
     (when (not (zero? pairs-in-search))
       (display "Agidel: unmatched bracket pair. Exiting.")
       (exit 1))
     (list->string (flatten acc)))))
