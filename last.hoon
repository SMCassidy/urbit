::  Keeps track of the previous noun it has been
::  poked with and prints the it out
::
::::  /===/app/last/hoon
  ::
!:
|%
++  move  {bone card}
++  card  $%  $~
          ==
--
|_  {bow/bowl prev/*}                                    ::<  prev is our app state
::
++  poke-noun
  |=  new/*
  ^-  {(list move) _+>.$}
  ~&  last+prev
  [~ +>.$(prev new)]
::
++  coup
  |=  {wir/wire err/(unit tang)}
  ^-  {(list move) _+>.$}
  ?~  err
    ~&  last+success+'Poke succeeded!'
    [~ +>.$]
  ~&  last+error+'Poke failed. Error:'
  ~&  last+error+err
  [~ +>.$]
::
--
