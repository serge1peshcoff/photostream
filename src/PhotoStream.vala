using PhotoStream.Utils;

public class PhotoStream.App : Granite.Application 
{

	public static MainWindow mainWindow;
    public static string appToken = "1528631860.1fb234f.e72be2d22ad444d594026ac9e4012cf7";
    public static List<MediaInfo> feedPosts;
    public Gtk.ToolButton newButton;

	protected override void activate () 
	{       
        application_id = "1";
        program_name = "PhotoStream";

        Thread<int> thread = new Thread<int>.try("", (ThreadFunc)this.load);

        mainWindow = new MainWindow ();
  
        mainWindow.show_all ();
        mainWindow.destroy.connect (Gtk.main_quit);
        mainWindow.set_application(this);

        //mainWindow.set_default_size (425, 500);
        //mainWindow.set_size_request (425, 50);

        this.newButton = new Gtk.ToolButton (new Gtk.Image.from_icon_name ("folder-new", Gtk.IconSize.LARGE_TOOLBAR), "New Tweet");
        newButton.set_tooltip_text ("New Tweet");
        newButton.set_sensitive (false);
        this.mainWindow.header.pack_start (newButton);

        //this.newButton = new Gtk.ToolButton (new Gtk.Image.from_icon_name ("folder-new", Gtk.IconSize.LARGE_TOOLBAR), "New Tweet");
        //newButton.set_tooltip_text ("New Tweet");
        //newButton.set_sensitive (false);
        //mainWindow.header.pack_start (newButton);

        //this.newButton = new Gtk.ToolButton (new Gtk.Image.from_icon_name ("folder-new", Gtk.IconSize.LARGE_TOOLBAR), "New Tweet");
        //newButton.set_tooltip_text ("New Tweet");
        //newButton.set_sensitive (false);
        //mainWindow.header.pack_end (newButton);

        //Gtk.Toolbar bar = new Gtk.Toolbar ();
        //mainWindow.add (bar);
        //bar.add (newButton);

        mainWindow.header.set_title("PhotoStream");
        mainWindow.header.set_subtitle("PhotoStream");

    }

    int load()
    {
        string responce = getUserFeed();
        //parseFeed(responce);
        //printFeed();        
        return 0;       
    }

    protected override void shutdown () 
    {
        stdout.printf ("Bye!\n");
    }

}
//https://api.instagram.com/oauth/authorize/?client_id=6e7283f612c645a5a22846d79cab54c3&redirect_uri=http://itprogramming1.tk/photostream&response_type=token