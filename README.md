# PhotoStream

An unofficial Instagram client for elementary OS.

Uses libraries:
* `gtk+-3.0` - for all graphic stuff
* `glib-2.0` - for almost all stuff
* `gio-2.0` - for file input/output
* `granite`
* `libsoup` - for networking stuff
* `json-glib` - for parsing JSON data received through API
* `webkit2gtk-4.0` - for logging in
* `libxml-2.0` - for parsing user news and settings

`webkit2gtk` which is in Ubuntu 14.04 repositories is too older, you need at least version 2.6.2, so you need to fetch the latest release from the http://webkitgtk.org/, download and compile it yourself.
You can also get it by installing libwebkit2gtk-4.0-dev from GNOME 3 Staging PPA: [ppa:gnome3-team/gnome3-staging](https://launchpad.net/~gnome3-team/+archive/ubuntu/gnome3-staging)

Inspired a lot by Birdie Twitter client.

## Installation 

```shell
# If you don't have Vala
sudo add-apt-repository ppa:vala-team/ppa
sudo apt-get update
sudo apt-get install valac-0.26
# Installing necessary dependencies:
sudo apt-get install libgstreamer-plugins-base1.0-dev \
libsoup2.4-dev libjson-glib-dev libxml2-dev libnotify-dev \
libgee-0.8-dev ttf-ancient-fonts
```

Building:

```shell
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ../
make
sudo make install
```
