# PhotoStream

An unofficial Instagram client for elementary OS.

Used libraries:
* gtk+-3.0
* glib-2.0
* gio-2.0
* granite
* libsoup - for networking stuff
* json-glib - for parsing JSON data received through API
* webkitgtk-3.0 - for logging in
* libxml-2.0 - for parsing user news

## Installation  
Building:

'''shell
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ../
make
sudo make install

'''