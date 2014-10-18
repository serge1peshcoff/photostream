using PhotoStream.Utils;

public class PhotoStream.App : Granite.Application 
{

	public static MainWindow mainWindow;
    public static string appToken = "1528631860.1fb234f.e72be2d22ad444d594026ac9e4012cf7";
    public static List<MediaInfo> feedPosts;


	protected override void activate () 
	{       
        application_id = "1";
        program_name = "PhotoStream";

        Thread<int> thread = new Thread<int>.try("", (ThreadFunc)this.load);

        mainWindow = new MainWindow ();

        mainWindow.title = "Hello World!";   
        mainWindow.show_all ();
        mainWindow.destroy.connect (Gtk.main_quit);
        mainWindow.set_application(this);

        

    }

    int load()
    {
        string responce = getUserFeed();
        parseFeed(responce); 
        printFeed();        
        return 0;       
    }

    protected override void shutdown () 
    {
        stdout.printf ("Bye!\n");
    }

}
//https://api.instagram.com/oauth/authorize/?client_id=6e7283f612c645a5a22846d79cab54c3&redirect_uri=http://itprogramming1.tk/photostream&response_type=token