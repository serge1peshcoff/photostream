using PhotoStream.Utils;

public class PhotoStream.App : Granite.Application 
{

	public MainWindow mainWindow;
    public LoginWindow loginWindow;
    public static string appToken = "";
    public const string REDIRECT_URI = "http://www.google.com/photostream";
    public const string CLIENT_ID = "e139a947d6de45a88297366282c27137";
    public const string CLIENT_SECRET = "4b54aac105534413b6885c2c48bcaa66";
    public const string SCHEMA_URI = "tk.itprogramming1.photostream";
    public const string SCHEMA_TOKEN = "token";
    public static List<MediaInfo> feedPosts;
    
    public Gtk.HeaderBar header;

    public Gtk.ToggleToolButton feedButton;
    public Gtk.ToggleToolButton exploreButton;
    public Gtk.ToggleToolButton photoButton;
    public Gtk.ToggleToolButton newsButton; 
    public Gtk.ToggleToolButton userButton;

    public Gtk.InfoBar bar;
    public Gtk.Box box;
    
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
        this.setHeader();       

        box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        mainWindow.add(box);

        appToken = loadToken();  
        print(appToken);
        if (appToken == "") //something went wrong. need to re-login
        {
            this.setErrorWidgets("not-logged-in");           
        }
        else
        {
            loadFeed();
        }   

        mainWindow.show_all ();
        mainWindow.destroy.connect (Gtk.main_quit);
        mainWindow.set_application(this); 

    }

    int load()
    {              
        return 0;       
    }   

    public void setLoginWindow()
    {
        this.loginWindow = new LoginWindow ();

        this.loginWindow.show_all ();
        this.loginWindow.destroy.connect(loadFeed);
        this.loginWindow.set_application(this);
    }  

    protected override void shutdown () 
    {
        stdout.printf ("Bye!\n");
        base.shutdown();
    }

    public void loadFeed()
    {
        string responce = "";              
        
        responce = getUserFeed();
        parseFeed(responce);
        //printFeed(); 
    }   

    public void setErrorWidgets(string reason)
    { 
        bar = new Gtk.InfoBar();       
        bar.message_type = Gtk.MessageType.ERROR;
        Gtk.Container content = bar.get_content_area ();
       
        switch(reason)
        {
            case "not-logged-in":
                content.add (new Gtk.Label ("You are not logged in."));
                bar.add_button("Log in", 1);
                break;
            case "wrong-login":
                content.add (new Gtk.Label ("Need to re-login."));
                bar.add_button("Relogin", 2);
                break;
            default:
                break;
        }
        print("aaa112\n'");
        box.add(bar);
        bar.response.connect(this.response);
    }
    public void setHeader()
    {
        header = new Gtk.HeaderBar ();
        header.set_show_close_button (true);
        this.mainWindow.set_titlebar (header);

        Gtk.Box centered_toolbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

        feedButton = new Gtk.ToggleToolButton ();
        feedButton.set_icon_widget (new Gtk.Image.from_icon_name ("go-home", Gtk.IconSize.LARGE_TOOLBAR));
        feedButton.set_tooltip_text ("Home");
        feedButton.set_label ("Home");
        //this.mainWindow.feedButton.set_sensitive (false);
        centered_toolbar.add (feedButton);

        exploreButton = new Gtk.ToggleToolButton ();
        exploreButton.set_icon_widget (new Gtk.Image.from_icon_name ("midori", Gtk.IconSize.LARGE_TOOLBAR));
        exploreButton.set_tooltip_text ("Home");
        exploreButton.set_label ("Home");
        //this.mainWindow.exploreButton.set_sensitive (false);
        centered_toolbar.add (exploreButton);

        photoButton = new Gtk.ToggleToolButton ();
        photoButton.set_icon_widget (new Gtk.Image.from_icon_name ("camera", Gtk.IconSize.LARGE_TOOLBAR));
        photoButton.set_tooltip_text ("Home");
        photoButton.set_label ("Home");
        //this.mainWindow.photoButton.set_sensitive (false);
        centered_toolbar.add (photoButton);

        newsButton = new Gtk.ToggleToolButton ();
        newsButton.set_icon_widget (new Gtk.Image.from_icon_name ("emblem-synchronizing", Gtk.IconSize.LARGE_TOOLBAR));
        newsButton.set_tooltip_text ("Home");
        newsButton.set_label ("Home");
        //this.mainWindow.newsButton.set_sensitive (false);
        centered_toolbar.add (newsButton);

        userButton = new Gtk.ToggleToolButton ();
        userButton.set_icon_widget (new Gtk.Image.from_icon_name ("system-users", Gtk.IconSize.LARGE_TOOLBAR));
        userButton.set_tooltip_text ("Home");
        userButton.set_label ("Home");
        //this.mainWindow.userButton.set_sensitive (false);
        centered_toolbar.add (userButton);

        header.set_custom_title (centered_toolbar);
    }

    public void setFeedWidgets()
    {

    }
    public void response (int response_id)
    {
        print("aaa\n");
        switch (response_id)
        {
            case 1: //not logged in
            setLoginWindow();
            break;
        }        
    }   
}