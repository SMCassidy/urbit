::  A Caesar cipher generator
::
::  Call from dojo with +caesar ["message" n]
::
::::
  ::
|=
[a=tape b=@]
=>
|%
++  $
  ^-  tape
  |-
  ?:  =(b 0)
    a
  $(a (turn a inc), b (dec b))
++  inc
  |=  c=@
  ^-  @
    ?:  |((lth c 65) (gth c 122) &((gth c 90) (lth c 97)))
      c
    ?:  =(c 122)
      97
    ?:  =(c 90)
      65
    +(c)
--
$.$
