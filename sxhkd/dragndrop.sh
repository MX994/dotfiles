#!/bin/env bash

: "${BUTTON:=1}" "${RADIUS:=200}"

eval "$(xdotool getmouselocation --shell)"
(( x = X )); (( y = Y ))

bspc node pointed.tiled -f               || exit 1
node="$(bspc query -N -n focused.tiled)" || exit 1

die() {
    jobs -p | xargs -r -n1 -I{} kill {}
    killall xmmv
    exit
}

trap 'die' USR1

{ bspc subscribe node_focus | while read -r _ _ _ wid; do
    (( wid != node )) && break; done; kill -USR1 "$$" ;} &
{ while xinput list \
      | sed -nE 's,.*id=([0-9]+).*slave\s+pointer.*,\1,p' \
      | xargs -r -n1 -I{} xinput query-state {} 2> /dev/null \
      | grep -qF "button[${BUTTON}]=down"; do sleep .3; done; kill -USR1 "$$" ;} &

dunstify -r 222 "x=$x y=$y" "X=$X Y=$Y"
eval "$(xdotool getmouselocation --shell)"
until (( ( x - X > RADIUS || X - x > RADIUS ) \
      || ( y - Y > RADIUS || y - Y > RADIUS ) )); do
    dunstify -r 222 "x=$x y=$y" "X=$X Y=$Y"
    eval "$(xdotool getmouselocation --shell)"
done

bspc node "$node" -t floating
{ xmmv; kill -USR1 "$$" ;} &

wait
