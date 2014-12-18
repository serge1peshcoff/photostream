# PhotoStream

An unofficial Instagram client for elementary OS.

Uses libraries:
* gtk+-3.0 - for all graphic stuff
* glib-2.0 - for almost all stuff
* gio-2.0 - for file input/output
* granite
* libsoup - for networking stuff
* json-glib - for parsing JSON data received through API
* webkit2gtk-4.0 - for logging in
* libxml-2.0 - for parsing user news and settings

webkit2gtk-4.0 which is in Ubuntu 14.04 repositories is too older, you need at least version 2.6.4, so you need to fetch the latest release from the http://webkitgtk.org/, download and compile it yourself.

Inspired a lot by Birdie Twitter client.

You need this packages to build:

* libgstreamer-plugins-base1.0-dev

## Installation  
Building:

```shell
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ../
make
sudo make install
```
