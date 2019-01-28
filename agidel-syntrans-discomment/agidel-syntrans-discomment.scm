(module
 agidel-systrans-discomment
 *
 (import scheme
         format)

 (define (add-to-list lst elt)
   (append lst (list elt)))
 
 (define (main source-string) ; -> string?
   (let [[in-string? #f]
         [deleting-comment? #f]
         [escaping-char? #f]
         [acc '()]]
     (for-each
      (lambda (ch)
        (cond
         {in-string?
          (begin
            (set! acc (add-to-list acc ch))
            (cond
             [escaping-char? (set! escaping-char? #f)]
             [(eq? ch #\\) (set! escaping-char? #t)]
             [(eq? ch #\") (set! in-string? #t)]))}
         {(not deleting-comment?)
          (cond
           [(eq? ch #\;) (set! deleting-comment? #t)]
           [(eq? ch #\") (set! acc (add-to-list acc ch)) (set! in-string? #t)]
           [else (set! acc (add-to-list acc ch))])}
         {(eq? ch #\newline)
          (set! acc (add-to-list acc ch))
          (set! deleting-comment? #f)}))
      (string->list source-string))
     (list->string acc))))
