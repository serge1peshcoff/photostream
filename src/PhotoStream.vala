using PhotoStream.Utils;

public class PhotoStream.App : Granite.Application 
{

	public static MainWindow mainWindow;
    public static LoginWindow loginWindow;
    //public string appToken = "1528631860.1fb234f.e72be2d22ad444d594026ac9e4012cf7";
    public static string appToken = "";
    public const string REDIRECT_URI = "http://itprogramming1.tk/photostream";
    public const string CLIENT_ID = "e139a947d6de45a88297366282c27137";
    public const string CLIENT_SECRET = "4b54aac105534413b6885c2c48bcaa66";
    public static List<MediaInfo> feedPosts;
    public Gtk.ToolButton newButton;

	protected override void activate () 
	{      
        program_name        = "PhotoStream";
        exec_name           = "photostream";
        build_version       = "0.1";
        app_years           = "2014";
        app_icon            = "photostream";
        app_launcher        = "photostream.desktop";
        application_id      = "tk.itprogramming1.photostream";
        main_url            = "http://itprogramming1.tk/photostream";
        //bug_url             = "https://github.com/birdieapp/birdie/issues";
        //help_url            = "https://github.com/birdieapp/birdie/wiki";
        //translate_url       = "http://www.transifex.com/projects/p/birdie/";
        about_authors       = {"Sergey Peshkov"};
        about_comments      = null;
        about_documenters   = {};
        about_translators   = null;
        about_license_type  = Gtk.License.GPL_3_0;

        try 
        {
            Thread<int> thread = new Thread<int>.try("", (ThreadFunc)this.load);

        }
        catch (Error e)
        {

        }  

        mainWindow = new MainWindow ();
  
        mainWindow.show_all ();
        mainWindow.destroy.connect (Gtk.main_quit);
        mainWindow.set_application(this);

        appToken = loadToken();  
        //print(appToken);
        if (appToken == "") //something went wrong. need to re-login
        {
            loginWindow = new LoginWindow ();
  
            loginWindow.show_all ();
            loginWindow.destroy.connect(loadFeed);
            loginWindow.set_application(this);
        }
        else
        {
            loadFeed();
        }

        
    }

    int load()
    {              
        return 0;       
    }

    void loadFeed()
    {
        string responce = ""; 
             
        
        responce = getUserFeed();
        parseFeed(responce);
        printFeed(); 
    }

    public string loadToken()
    {
        GLib.Settings settings;
        string token = "";
        //try 
        //{
            settings = new GLib.Settings ("tk.itprogramming1.photostream");
            token = settings.get_string("token");
        //}
        //catch (Error e) // if key is not found, do nothing and return an empty string
        //{
            //print("error");
            //token = "";
        //}
        return token;
    }

    protected override void shutdown () 
    {
        stdout.printf ("Bye!\n");
        base.shutdown();
    }

}