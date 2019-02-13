(module
 agidel-syntrans.discomment
 *
 (import scheme
         (chicken base)
         (only (agidel core) add-to-list add-to-list!))
 
 (define (main source-string _) ; -> string?
   (let [[in-string? #f]
         [deleting-comment? #f]
         [escaping-char? #f]
         [acc '()]]
     (for-each
      (lambda (ch)
        (cond
         {in-string?
          (begin
            (add-to-list! acc ch)
            (cond
             [escaping-char? (set! escaping-char? #f)]
             [(eq? ch #\\) (set! escaping-char? #t)]
             [(eq? ch #\") (set! in-string? #f)]))}
         {(not deleting-comment?)
          (cond
           [(eq? ch #\;)
            (set! deleting-comment? #t)]
           [(eq? ch #\")
            (add-to-list! acc ch)
            (set! in-string? #t)]
           [else
            (add-to-list! acc ch)])}
         {(eq? ch #\newline)
          (add-to-list! acc ch)
          (set! deleting-comment? #f)}))
      (string->list source-string))
     (list->string acc))))
