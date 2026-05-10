#!/bin/bash

i3lock \
  --blur 7 \
  --tiling \
  --clock \
  --indicator \
  --show-failed-attempts \
  \
  --time-str="%H:%M:%S" \
  --date-str="%A, %d %B" \
  \
  --time-font="JetBrainsMono Nerd Font" \
  --date-font="JetBrainsMono Nerd Font" \
  --layout-font="JetBrainsMono Nerd Font" \
  --verif-font="JetBrainsMono Nerd Font" \
  --wrong-font="JetBrainsMono Nerd Font" \
  \
  --radius 95 \
  --ring-width 6 \
  \
  --ind-pos="x+150:y+h-150" \
  --time-pos="ix:iy-20" \
  --date-pos="ix:iy+20" \
  \
  --time-color=ffffffff \
  --date-color=ffffff88 \
  --ring-color=ffffff44 \
  --keyhl-color=00ff00ff \
  --wrong-color=ff0000ff
