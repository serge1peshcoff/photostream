using PhotoStream.Utils;
using Gdk;

public class PhotoStream.App : Granite.Application 
{

	public MainWindow mainWindow;
    public LoginWindow loginWindow;
    public static string appToken = "";
    public static string olderFeedLink = "";
    public const string REDIRECT_URI = "http://www.google.com/photostream";
    public const string CLIENT_ID = "e139a947d6de45a88297366282c27137";
    public const string CLIENT_SECRET = "4b54aac105534413b6885c2c48bcaa66";
    public const string SCHEMA_URI = "tk.itprogramming1.photostream";
    public const string SCHEMA_TOKEN = "token";
    public static string CACHE_URL;
    public static string CACHE_AVATARS;
    public static List<MediaInfo> feedPosts;
    
    public Gtk.HeaderBar header;

    public Gtk.ToggleToolButton feedButton;
    public Gtk.ToggleToolButton exploreButton;
    public Gtk.ToggleToolButton photoButton;
    public Gtk.ToggleToolButton newsButton; 
    public Gtk.ToggleToolButton userButton;

    public Gtk.InfoBar bar;
    public Gtk.Box box;
    public Gtk.Image loadingImage;

    public PhotoStream.PhotoStack stack;
    public Gtk.ScrolledWindow feedWindow;
    public Gtk.ScrolledWindow userWindow; 

    public PhotoStream.PostList feedList; 
    
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

        CACHE_URL = Environment.get_home_dir() + "/.cache/photostream/";
        CACHE_AVATARS = CACHE_URL + "avatars/";

        mainWindow = new MainWindow ();
        this.setHeader();

        bar = new Gtk.InfoBar();         

        box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        mainWindow.add(box);

        PixbufAnimation loadingPixbuf;

        try 
        {   
            loadingPixbuf = new PixbufAnimation.from_file("/usr/share/photostream/images/loading.gif");            
        }
        catch (Error e)
        {
            error("Loading image went wrong.\n");
        }

        loadingImage = new Gtk.Image.from_animation(loadingPixbuf);
        box.pack_start(loadingImage, true, true);

        mainWindow.show_all ();
        mainWindow.destroy.connect (Gtk.main_quit);
        mainWindow.set_application(this); 

        var loop = new MainLoop();
        tryLogin.begin((obj, res) => {
            loop.quit();
        });
        loop.run();

        
        print("activate() finished.\n");
    }

    public async void tryLogin()
    {   
        print("tryLogin start\n");        
        appToken = loadToken();  
        if (appToken == "") //something went wrong. need to re-login
        {
            this.setErrorWidgets("not-logged-in");          
        }
        else
        {
            loadFeed.begin((obj, res) => {
                //loadFeed.end(res);
            });
        }  
        print("tryLogin end\n");  
    }

    public void setLoginWindow()
    {
        this.loginWindow = new LoginWindow ();

        this.loginWindow.show_all ();
        this.loginWindow.destroy.connect(tryLogin);
        this.loginWindow.set_application(this);
    }  

    protected override void shutdown () 
    {
        base.shutdown();
    }

    public async void loadFeed()
    {
        //string response = "";// = getUserFeed();
        print("loadFeed start\n"); 
        getUserFeed.begin((obj, res) => {
            string response = getUserFeed.end(res);
            print("load finished.\n"); 

            try 
            {
                feedPosts = parseFeed(response);
                //feedPosts.append(parseImage(response));
            }
            catch (Error e) // wrokg token
            {
                setErrorWidgets("wrong-login");
                return;
            }

            // if we got here then we've got no errors, yay!
            box.remove(bar);        

            setFeedWidgets.begin((obj, res) => {
                setFeedWidgets.end(res);
            });
            print("loadFeed end\n"); 
        });
    }   

    public void setErrorWidgets(string reason)
    { 
        box.remove(bar);
        bar = new Gtk.InfoBar();     
            
        bar.message_type = Gtk.MessageType.ERROR;
        Gtk.Container content = bar.get_content_area ();
       
        switch(reason)
        {
            case "not-logged-in":
                content.add (new Gtk.Label ("You are not logged in."));
                bar.add_button("Log in", 1);
                print("Not logged in\n");
                break;
            case "wrong-login":
                content.add (new Gtk.Label ("Need to re-login."));
                bar.add_button("Relogin", 2);
                print("Need to re-login.\n");
                break;
            default:
                break;
        }
        box.add(bar);
        bar.response.connect(this.response);
        mainWindow.show_all ();
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

    public async void setFeedWidgets()
    {        
        print("setFeedWidgets start\n"); 
        this.stack = new PhotoStack();
        this.feedWindow = new Gtk.ScrolledWindow (null, null);
        stack.add_named(feedWindow, "feed");

        print("loading images...\n");

        try {
            File file = File.new_for_path(CACHE_URL);
            if (!file.query_exists())
                file.make_directory_with_parents ();

            file = File.new_for_path(CACHE_AVATARS);
            if (!file.query_exists())
                file.make_directory_with_parents ();

        } catch (Error e) {
            stdout.printf ("Error: %s\n", e.message);
        }



        this.feedList = new PostList();
        this.feedWindow.add_with_viewport (feedList);

        

        foreach (MediaInfo post in feedPosts)   
            feedList.prepend(post);

        //Idle.add((SourceFunc)loadImage(feedList.boxes, 0));
        //Idle.add((SourceFunc)loadAvatar(feedList.boxes, 0));
        foreach (PostBox box in feedList.boxes)
        {            
            /*var avatarLoop = new MainLoop();
            box.loadAvatar.begin((obj, res) => {
                    box.loadAvatar.end(res);
                    avatarLoop.quit();
                });
            avatarLoop.run();*/

            /*var imageLoop = new MainLoop();
            box.loadImage.begin((obj, res) => {
                    box.loadImage.end(res);
                    imageLoop.quit();
                });
            imageLoop.run();*/
            /*Idle.add(() => {
                box.loadAvatar();
                return false;
            });
            Idle.add(() => {
                box.loadImage();
                return false;
            });*/
            box.loadAvatar();
            box.loadImage();
            //feedList.show_all ();
        }   

        box.remove(loadingImage);
        box.pack_start(stack, true, true);
        print("setFeedWidgets end\n");
    } 

    public void switchWindow(string window)
    {
        stack.set_visible_child_name(window);
    } 
    public void response (int response_id)
    {
        switch (response_id)
        {
            case 1: //not logged in
            setLoginWindow();
            break;
            case 2:
            setLoginWindow();
            break;

        }        
    }   
}