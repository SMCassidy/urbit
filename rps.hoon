::
::  Rock, Paper, Scissors in Urbit
::
::  Usage: start with |start %rps
::
::  There are two modes, initiate a game and receive a game.
::  Once the app is running anyone can initiate a game with you.
::
::  To initiate a game with someone use :rps [%init ~their-ship %rock ~]
::  To respond to a game use :rps [%resp ~their-ship %rock ~]
::
::  To see a list of ships currently awaiting a response use :rps [%show ~]
::
::::  /===/app/rps/hoon
  ::
!:
|%
+=  move  [bone card]
+=  card  $%  [%poke wire dock poke-contents]
          ==
+=  poke-contents  $%  [%atom @]
                   ==
+=  args  $%  [%show ~]
              [%init p=[q=ship r=hand]]
              [%resp p=[q=ship r=hand]]
          ==
+=  hand  $%  [%rock ~]
              [%paper ~]
              [%scissors ~]
          ==
+=  shad  [ship hand]
++  state  $:  inbx/(list ship)
               outx/(map ship @ud)
           ==
--
|_  [bow=bowl:gall game=state]                                  ::<
::
++  poke-noun
  |=  a=args
  ^-  [(list move) _+>.$]
  ?-  -.a
     %show
       ~&  rps+game
       [~ +>.$]
     %init
       (init p.a)
     %resp
       (resp p.a)
  ==                                         :: Basically using this as a state machine
++  poke-atom                                :: Atom codes:     4 - received init request
  |=  atm=@                                  ::             0,1,2 - replied with R,P,S
  ^-    [(list move) _+>.$]
  ?:  =(atm 4)
      ~&  'Someone wants to play Rock, Paper, Scissors..!'
      ~&  'Use :rsp [%show ~] to see who it is.'
      ~&  'Reply with... :rsp [%resp ~ship ~hand ~]'
  ?~  (find ~[src.bow] inbx.game)
      [~ +>.$(inbx.game (weld inbx.game ~[src.bow]))]
  ~&  'Already in inbox...'
      [~ +>.$]
  ?:  (lth atm 3)                            :: Initiator recieves opponents hand
  =+  you=(~(got by outx.game) src.bow)
  =+  hero=(calc-game [you atm])             :: Calculates game result
  =+  vill=(code-translate hero)
   (announce-game [hero vill])
   (announce-game [atm 99])                          :: Send result to players
  ::[~ +>.$]
++  coup
  |=  a=*
  ^-  [(list move) _+>.$]
  [~ +>.$]
++  init
   |=  shd=shad
   ^-  [(list move) _+>.$]
   =+  atm=(hand-to-atom +.shd)
   =+  par=[-.shd atm]
   ?~  (~(get by outx.game) -.shd)
      ~&  'Sending request...'
  :_  +>.$(outx.game (~(put by outx.game) par))
  :~  :*   ost.bow
           %poke
           /init
           [[-.shd %rps] [%atom 4]]
      ==
  ==
  ~&  'You already sent that ship a request!'
  [~ +>.$]
++  resp
   |=  shd=shad
   ^-  [(list move) _+>.$]
  :: ~&  shd
   =+  atm=(hand-to-atom +.shd)
   =+  indx=(find ~[-.shd] inbx.game)
   ?~  indx
   ~&  'That ship has not started a game with you!'
       [~ +>.$]
   :_  +>.$(inbx.game (oust [(need indx) 1] inbx.game))
   :~  :*  ost.bow
           %poke
           /resp
           [[-.shd %rps] [%atom atm]]
       ==
   ==
++  msg
    |=  cde=@
    ^-  [(list move) _+>.$]
    ?:  =(cde 99)
        [~ +>.$]
    :_  +>.$(outx.game (~(del by outx.game) src.bow))
    :~  :*  ost.bow
            %poke
            /msg
            [[src.bow %rps] [%atom cde]]
        ==
    ==
++  hand-to-atom
   |=  hnd=hand
   ^-  @
   ?:  =(hnd [%rock ~])
     0
   ?:  =(hnd [%paper ~])
     1
   ?:  =(hnd [%scissors ~])
     2
   99
++  calc-game
   |=  [a=@ b=@]
   ^-  @                                     :::::::::::::::::::::::::::
   ?:  =(a 0)                                :: You      Opp     Atom ::
   ?:  =(b 0)                                :::::::::::::::::::::::::::
     10                                      :: Rock     Rock      10 ::
   ?:  =(b 1)                                :: Rock     Paper     11 ::
     11                                      :: Rock     Scissors  12 ::
     12                                      :: Paper    Rock      13 ::
   ?:  =(a 1)                                :: Paper    Paper     14 ::
   ?:  =(b 0)                                :: Paper    Scissors  15 ::
     13                                      :: Scissors Rock      16 ::
   ?:  =(b 1)                                :: Scissors Paper     17 ::
     14                                      :: Scissors Scissors  18 ::
     15                                      :::::::::::::::::::::::::::
   ?:  =(b 0)
     16
   ?:  =(b 1)
     17
     18
++  code-translate                           :: Have to flip code
   |=  a=@                                   :: before sending to opponent
   ^-  @
   ?:  =(a 10)
     10
   ?:  =(a 11)
     13
   ?:  =(a 12)
     16
   ?:  =(a 13)
     11
   ?:  =(a 14)
     14
   ?:  =(a 15)
     17
   ?:  =(a 16)
     12
   ?:  =(a 17)
     15
   ?:  =(a 18)
     18
   99
++  announce-game
   |=  a=[h=@ v=@]
   ^-  [(list move) _+>.$]
   ?:  =(h.a 10)
       ~&  'Result from your match with...'
       ~&  src.bow
       ~&  'You both picked Rock! You Drew!'
         (msg v.a)
   ?:  =(h.a 11)
       ~&  'Result from your match with...'
       ~&  src.bow
       ~&  'Their Paper beat your Rock! You Lost!'
         (msg v.a)
   ?:  =(h.a 12)
       ~&  'Result from your match with...'
       ~&  src.bow
       ~&  'Your Rock beat their Scissors! You won!'
         (msg v.a)
   ?:   =(h.a 13)
       ~&  'Result from your match with...'
       ~&  src.bow
       ~&  'Your Paper beat their Rock! You won!'
         (msg v.a)
   ?:  =(h.a 14)
       ~&  'Result from your match with...'
       ~&  src.bow
       ~&  'You both picked Paper! You Drew!'
         (msg v.a)
   ?:  =(h.a 15)
       ~&  'Result from your match with...'
       ~&  src.bow
       ~&  'Their Scissors beat your Paper! You Lost!'
         (msg v.a)
   ?:  =(h.a 16)
       ~&  'Result from your match with...'
       ~&  src.bow
       ~&  'Their Rock beat your Scissors! You Lost!'
         (msg v.a)
   ?:  =(h.a 17)
       ~&  'Result from your match with...'
       ~&  src.bow
       ~&  'Your Scissors beat their Paper! You Won!'
         (msg v.a)
   ?:  =(h.a 18)
       ~&  'Result from your match with...'
       ~&  src.bow
       ~&  'You both picked Scissors! You Drew!'
         (msg v.a)
   [~ +>.$]
--
