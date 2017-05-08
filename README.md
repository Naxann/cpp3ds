cpp3ds
======

[![Build Status](https://travis-ci.org/cpp3ds/cpp3ds.png?branch=master)](https://travis-ci.org/cpp3ds/cpp3ds) [![Codecov branch](https://img.shields.io/codecov/c/github/cpp3ds/cpp3ds/master.svg?maxAge=86400)](https://codecov.io/gh/cpp3ds/cpp3ds) [![Docker pulls](https://img.shields.io/docker/pulls/thecruel/cpp3ds.svg?maxAge=86400)](https://hub.docker.com/r/thecruel/cpp3ds/) [![AUR package](https://img.shields.io/aur/version/cpp3ds-git.svg?maxAge=86400)](https://aur.archlinux.org/packages/cpp3ds-git/)

Basic C++ gaming framework and library for Nintendo 3DS.

cpp3ds is essentially a barebones port of SFML with a parallel native 3ds emulator built on top of it. The goal is to completely abstract the developer from the hardware SDK and provide a nice object-oriented C++ framework for clean and easy coding. And the emulator is designed to provide a means of surface-level realtime debugging (with GDB or whatever you prefer).

Won't be stable and usable until v1.0

Installation
------------
Coming soon.

Documentation
-------------
Will be released with v1.0 stable

Requirements
------------

For 3DS :

- DevkitARM
- ctrulib
- citro3d
- libfmt
- libjpeg
- libfreetype
- libogg (to support OGG sound format)
- tremor (to support OGG sound format)
- faad (to support AAC sound format)

For emulator:

- [SFML 2.3](http://www.sfml-dev.org/index.php)
- [Qt 5](https://qt-project.org/)
- OpenAL
- libvorbis

For unit tests:

- [Google Test](https://code.google.com/p/googletest/)

Credit and Thanks
-----------------
- [Cruel](https://github.com/Cruel) - Original work on cpp3ds
- [Laurent Gomila](https://github.com/LaurentGomila) and SFML team
- [smealum](https://github.com/smealum) - ctrulib
- [Lectem](https://github.com/Lectem) - some CMake stuff
- Everyone on EFNet #3dsdev

