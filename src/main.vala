int main (string[] args) 
{
	Stacktrace.register_handlers();
    Gtk.init (ref args);
    Gst.init (ref args);
    Xml.Parser.init ();
    Notify.init ("PhotoStream");
    var app = new PhotoStream.App ();

    return app.run (args);
}
