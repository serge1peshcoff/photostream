int main (string[] args) {
    Gtk.init (ref args);
    Gst.init (ref args);
    Xml.Parser.init ();
    Notify.init ("PhotoStream");
    var app = new PhotoStream.App ();

    return app.run (args);
}
