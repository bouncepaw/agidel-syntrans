(module
 agidel-syntrans.prepare
 *
 (import scheme
         (chicken base)
         (prefix (agidel core) core/)
         (prefix (agidel plugin) plugin/)
         (srfi 1)
         (srfi 13)
         (srfi 69)
         (clojurian syntax)
         format)
 
 (define signatures (make-hash-table))

 (define (aquote expr)
   `(quote ,expr))

 (define (q/e->λ q/e)
   (cond
    ((eq? q/e 'q) aquote)
    ((eq? q/e 'e) aeval)))

 (define (make-parser name-of-λ)
   (define signature (hash-table-ref signatures name-of-λ))

   (define (rest-parser . args)
     (define λ (q/e->λ signature))
     (map λ args))
   
   (define (normal-parser . args)
     (define λs (map q/e->λ signature))
     (map (lambda (λ+arg)
            (apply (car λ+arg) (cdr λ+arg)))
          (zip λs args)))

   (define (normal+rest-parser . args)
     (define normal-length (length+ signature))
     (define normal-λs (map q/e->λ (take signature normal-length)))
     (define rest-λ (q/e->λ (drop signature normal-length)))

     (append (map (lambda (λ+arg) ((car λ+arg) (cdr λ+arg)))
                  (zip normal-λs args))
             (map rest-λ (drop args normal-length))))

   (cond
    ((symbol? signature)      rest-parser)
    ((proper-list? signature) normal-parser)
    ((dotted-list? signature) normal+rest-parser)))

 (define (aeval expr)
   (cond
    ((list? expr)
     (let* ((name-of-λ   (string->symbol (car expr)))
            (name-of-λ*  (symbol-append '/agidel name-of-λ))
            (args        (cdr expr))
            (parser      (make-parser name-of-λ))
            (parsed-args (apply parser args)))
       (cons name-of-λ* parsed-args)))
    (else expr)))

 (define (main source-string plugins)
   (set! signatures (plugin/signatures plugins))
   (map aeval
        (core/parse-string source-string))))
