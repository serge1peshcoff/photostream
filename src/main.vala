int main (string[] args) {
    Gtk.init (ref args);
    Gst.init (ref args);
    var app = new PhotoStream.App ();

    return app.run (args);
}
