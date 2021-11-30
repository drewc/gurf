(export #t setup surf  newclient showview current-surf-driver start-surfing! gtk_surf_iteration
        Client Client* Client-next
        Client-title Client-targeturi
       
        )
(import :std/foreign
        :gerbil/gambit/foreign
        :gerbil/gambit/threads)

(def (surf-driver!)
  (def min-sleep 0.00001)
  (def max-sleep 0.05)
  (def sleep-incr 0.00000001)
  (def sleep min-sleep)
  (def (sleepy)
    (thread-sleep! (max sleep max-sleep))
    (when (< sleep max-sleep)
      (+ sleep sleep-incr)))
  (let lp ()
    (def events? (gtk_surf_iteration))
    (if events?
      (set! sleep min-sleep)
      (sleepy))
    (lp)))

(def current-surf-driver (make-parameter #f))
(def (start-surfing!)
  (cond ((current-surf-driver) => values)
        (else
         (setup)
         (let (drv (spawn surf-driver!))
                (current-surf-driver drv)
                drv))))

(def (surf (uri "about:blank") (rclient (current-surf-client)))
  (start-surfing!)
  (let (client (newclient rclient))
    (showview client)
    (loaduri client uri)
    (updatetitle client)
    (current-surf-client client)
    client))

(defalias surf-client clients)
(def (surf-clients)
  (let lp ((c (surf-client)))
    (if (not c)
      []
      (cons c (lp (Client-next c))))))
(def current-surf-client (make-parameter #f))





(begin-ffi (setup
            newclient clients loaduri showview
            gtk_surf_iteration updatetitle
            Client Client* Client-next
            Client-title Client-targeturi
            evalscript)
  (c-declare "#include \"surf/surf.c\"")
  (define-c-lambda setup () void "setup")
  (c-declare "int ____nofreeclient(Client *c){ return 0;}")
  (define-c-struct Client
    ((title . char-string)
     (targeturi . char-string)
     (next . Client-borrowed-ptr*))
    "____nofreeclient")
  (define-c-lambda newclient (Client*) Client* "newclient")
  (define-c-lambda showview (Client*) void
    "showview(NULL, ___arg1); ___return;")
  (define-c-lambda loaduri (Client* char-string) void
      "Arg arg; arg.v = ___arg2 ; loaduri(___arg1, &arg); ___return;")
  (define-c-lambda updatetitle (Client*) void "updatetitle")
  (define-c-lambda evalscript (Client-borrowed-ptr* char-string) void
    "evalscript(___arg1, \"%s\", ___arg2); ___return;")
    (define-c-lambda clients () Client* "___return(clients);")
  (define-c-lambda gtk_surf_iteration
      () bool "gboolean res = g_main_context_pending(NULL);
      while (g_main_context_pending(NULL)) {
        g_main_context_iteration(NULL, FALSE);
     }; ___return(res);")
  )
