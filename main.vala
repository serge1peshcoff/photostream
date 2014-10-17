int main (string[] args) {
    Gtk.init (ref args);

    // Init internationalization support before anything else
    /*string package_name = Build.GETTEXT_PACKAGE;
    string langpack_dir = Path.build_filename (Build.DATADIR, "locale");
    Intl.setlocale (LocaleCategory.ALL, "");
    Intl.bindtextdomain (package_name, langpack_dir);
    Intl.bind_textdomain_codeset (package_name, "UTF-8");
    Intl.textdomain (package_name);
    GLib.Environ.set_variable ({"PULSE_PROP_media.role"}, "audio", "true");*/
    var app = new PhotoStream.App ();

    return app.run (args);
}
