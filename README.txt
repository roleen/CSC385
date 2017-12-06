# CSC385

The recoreder can be viewed as the following FSM:


-->[ Playblack Stop  ] <--(R)--> [ Recording Stop ]
       |       ^                      |       ^
    (D)|       |(S) or             (D)|       |(S)
       |       | Recording            |       |
       v       | Ends                 v       |
   [ Playing Selected ]           [ Recording New ]
       |       ^                      |        ^
    (P)|       |(D)                (P)|        |(D)
       |       |                      |        |
       v       |                      v        |
   [ Playing Paused ]             [ Recording Paused ]
