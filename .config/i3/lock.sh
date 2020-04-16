#!/bin/sh

BLANK='#00000000'  # blank
C='#ffffff22'  # clear ish
D='#ff00ffcc'  # default
T='#ee00eeee'  # text
WHITE='#FFFFFFFF' # white
WRONG='#880000bb'  # wrong
V='#bb00bbbb'  # verifying
BLUE='#2196f3ff'  # blue

i3lock \
--insidevercolor=$BLANK   \
--ringvercolor=$WHITE     \
\
--insidewrongcolor=$BLANK \
--ringwrongcolor=$WRONG   \
--ringvercolor=$BLUE   \
\
--insidecolor=$BLANK      \
--ringcolor=$WHITE        \
--linecolor=$BLANK        \
--separatorcolor=$WHITE   \
\
--verifcolor=$WHITE        \
--wrongcolor=$WHITE        \
--timecolor=$WHITE        \
--datecolor=$WHITE        \
--keyhlcolor=$BLUE       \
--bshlcolor=$WRONG        \
\
--screen 1            \
--blur 5              \
--clock               \
--indicator           \
--timestr="%H:%M"  \
--datestr="%d / %m / %Y" \
\
--wrongtext="U BITCH !" \
--veriftext=""


# --veriftext="Drinking verification can..."
# --textsize=20
# --modsize=10
# --timefont=comic-sans
# --datefont=monofur
# etc