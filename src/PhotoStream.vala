using PhotoStream.Utils;

public class PhotoStream.App : Granite.Application 
{

	public static MainWindow mainWindow;
    public static LoginWindow loginWindow;
    //public string appToken = "1528631860.1fb234f.e72be2d22ad444d594026ac9e4012cf7";
    public static string appToken = "";
    public const string REDIRECT_URI = "http://itprogramming1.tk/photostream";
    public const string CLIENT_ID = "6e7283f612c645a5a22846d79cab54c3";
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

        loginWindow = new LoginWindow ();
  
        loginWindow.show_all ();
        loginWindow.destroy.connect(loadFeed);
        loginWindow.set_application(this);
    }

    int load()
    {
        string responce = ""; 

        /*loginWindow.destroy.connect(() => {     
            stdout.printf("1\n") ;      
            appToken = loadToken();
            stdout.printf(appToken + " 2\n") ;    
            responce = getUserFeed();
            stdout.printf(responce + "\n") ;    
            parseFeed(responce);
            stdout.printf("4\n") ;    
            printFeed(); 
        });*/

        //parseFeed(responce);
        //printFeed();        
        return 0;       
    }

    void loadFeed()
    {
        string responce = ""; 
        
        stdout.printf("1\n") ;      
        appToken = loadToken();
        stdout.printf(appToken + " 2\n") ;    
        responce = getUserFeed();
        stdout.printf(responce + "\n") ;    
        parseFeed(responce);
        stdout.printf("4\n") ;    
        printFeed(); 
    }

    public string loadToken()
    {
        var settings = new GLib.Settings ("tk.itprogramming1.photostream");
        return settings.get_string("token");
    }

    protected override void shutdown () 
    {
        stdout.printf ("Bye!\n");
        base.shutdown();
    }

}
//https://api.instagram.com/oauth/authorize/?client_id=6e7283f612c645a5a22846d79cab54c3&redirect_uri=http://itprogramming1.tk/photostream&response_type=token