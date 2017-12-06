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


Characters on the transition are the keys to be pressed to change state. 
To select a recording, at Playback Stop mode, use + on numpad to select next and - on numpad to select previous.
Keypress won't have any affect if they are not in their corresponding state.

The LEDs will display current state:
LED 0 = playbackstop
LED 1 = playback playing
LED 2 = recordstop
LED 3 = recording
LED 4 = pause
Only one LED should be lit at the same time.

The 7-segment display will display the currently selected audio id to play for Playback mode. It displays 0 at the beginning, after one recording is recorded, going back to Playback Stop mode will make it display 1.

The VGA screen will display current state on bottom right. 
In playback mode, the VGA will display seconds left in the playing audio file, it will also diplay sample points.

There is a delete recording function mapped to V key(But it may not work!)
