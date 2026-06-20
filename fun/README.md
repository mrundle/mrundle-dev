# Overview

A list of silly little terminal programs. String them together like:

```
fortune | cowsay | lolcat
```

# Installation

All of these can be installed like via:
- MacOS: `brew install {package-name}`
- Linux: `sudo {apt|yum} install {package-name}`

# Programs

## cmatrix

Turns your terminal into the falling code from the Matrix

Installation:
    - MacOS: `brew install cmatrix`
    - Linux:
        - `sudo apt install cmatrix`
        - `sudo yum install cmatrix`
        - etc.

## fortune

Prints random/funny quotes or messages like:

```
$ fortune
My opinions may have changed, but not the fact that I am right.
```
```
$ fortune
Wish and hope succeed in discerning signs of paranormality where reason and
careful scientific procedure fail.
- James E. Alcock, The Skeptical Inquirer, Vol. 12
```
```
$ fortune
Lord, what fools these mortals be!
		-- William Shakespeare, "A Midsummer-Night's Dream"
```

If you want the "offensive" flag to work (`-o`/`-a`), you'll need to download
and install some extra files. For example, I downloaded files from [here](https://github.com/theodric/fortitude/tree/master/off/openSUSE-tw),
ran rot13 to convert them to plaintext, ran `strfile <file>` for each one that wasn't a `.dat` or `.u8`, and then copied everything
into the directory indicated by `fortune -o`. Which on macOS happened to be `/opt/homebrew/Cellar/fortune/9708/share/games/fortunes/off/`.

## sl

Steam locomotive. If you mis-type `ls` as `sl`, a train will run across your screen.

Installation:

    - MacOS: `brew install sl`
    - Linux: untested


## cowsay

```
$ cowsay "what up dog"
 _____________
< what up dog >
 -------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

## bastet

Bastardized version of Tetris where you always get the wrong piece.

## moon-buggy

Little flappy-birds style game where you navigate a moon-buggy, jump over craters, and maybe shoot things.

## figlet

Turn text into giant via ascii art.

```
$ figlet "testing"
 _            _   _
| |_ ___  ___| |_(_)_ __   __ _
| __/ _ \/ __| __| | '_ \ / _` |
| ||  __/\__ \ |_| | | | | (_| |
 \__\___||___/\__|_|_| |_|\__, |
                          |___/
```
```
$ echo "foo bar" | figlet
  __               _
 / _| ___   ___   | |__   __ _ _ __
| |_ / _ \ / _ \  | '_ \ / _` | '__|
|  _| (_) | (_) | | |_) | (_| | |
|_|  \___/ \___/  |_.__/ \__,_|_|
```
