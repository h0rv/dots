#!/bin/sh
if [ -f /tmp/polybarhidden ]; then 
  polybar-msg cmd show 
  rm /tmp/polybarhidden 
else 
  polybar-msg cmd hide 
  touch /tmp/polybarhidden 
fi
