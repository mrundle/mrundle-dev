#!/bin/bash
fortune -a \
    | cowsay -W 80 -rC \
    | lolcat --animate --duration=3 --speed=200 --spread=1
