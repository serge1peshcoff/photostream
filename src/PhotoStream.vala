using PhotoStream.Utils;
using PhotoStream.Widgets;
using Gdk;

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
    public static string CACHE_URL;
    public static string CACHE_AVATARS;
    public const string CACHE_IMAGES = "/usr/share/photostream/images/";
    public static List<MediaInfo> feedPosts;
    public bool isFeedLoaded = false;
    
    public Gtk.HeaderBar header;

    public Gtk.ToggleToolButton feedButton;
    public Gtk.ToggleToolButton exploreButton;
    public Gtk.ToggleToolButton photoButton;
    public Gtk.ToggleToolButton newsButton; 
    public Gtk.ToggleToolButton userButton;

    public Gtk.InfoBar bar;
    public Gtk.Box box;
    public Gtk.Image loadingImage;

    public PhotoStack stack;
    public Gtk.ScrolledWindow userFeedWindow;
    public Gtk.ScrolledWindow tagFeedWindow;
    public Gtk.ScrolledWindow userWindow;
    public Gtk.ScrolledWindow postWindow;
    public Gtk.ScrolledWindow likesWindow;
    public Gtk.ScrolledWindow commentsWindow;
    public Gtk.ScrolledWindow usersWindow;
    public Gtk.ScrolledWindow searchWindow;

    public UserWindowBox userWindowBox;

    public PostList feedList; 
    
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
        box.add(bar);

        mainWindow.show_all ();
        mainWindow.destroy.connect (Gtk.main_quit);
        mainWindow.set_application(this); 

        tryLogin();

        Idle.add(() => {
            preloadWindows();
            return false;
        });
    }

    public void tryLogin()
    {   
        box.remove(bar);
        PixbufAnimation loadingPixbuf;
        try 
        {   
            loadingPixbuf = new PixbufAnimation.from_file(CACHE_IMAGES + "loading.gif");            
        }
        catch (Error e)
        {
            error("Loading image went wrong.\n");
        }

        loadingImage = new Gtk.Image.from_animation(loadingPixbuf);
        box.pack_start(loadingImage, true, true);
        mainWindow.show_all ();


        appToken = loadToken();  
        if (appToken == "") //something went wrong. need to re-login
            this.setErrorWidgets("not-logged-in");          
        else
            new Thread<int>("", loadFeed);
    }

    public void preloadWindows()
    {
        this.stack = new PhotoStack();
        this.userFeedWindow = new Gtk.ScrolledWindow (null, null);
        this.userFeedWindow.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.ALWAYS);
        stack.add_named(userFeedWindow, "userFeed");

        try {
            File file = File.new_for_path(CACHE_URL);
            if (!file.query_exists())
                file.make_directory_with_parents ();

            file = File.new_for_path(CACHE_AVATARS);
            if (!file.query_exists())
                file.make_directory_with_parents ();

        } catch (Error e) {
            error("Error: %s\n", e.message);
        }

        this.feedList = new PostList();
        this.feedList.moreButton.clicked.connect(() => {
            new Thread<int>("", loadOlderFeed);
        });

        this.userFeedWindow.add_with_viewport (feedList);

        this.userWindow = new Gtk.ScrolledWindow(null, null);

        this.userWindowBox = new UserWindowBox();
        this.userWindow.add_with_viewport (userWindowBox);
        stack.add_named(userWindow, "user");
    }

    public void setLoginWindow()
    {
        this.loginWindow = new LoginWindow ();

        this.loginWindow.show_all ();
        this.loginWindow.destroy.connect(tryLogin);
        this.loginWindow.set_application(this);
    }

    public bool handleUris(string uri)
    {
        print(uri + "\n");
        switch(uri[0])
        {
            case '#': // hashtag, stub
            print("hashtag\n");
            break;
            case '@': // username
            new Thread<int>("", () => {
                loadUserFromUsername(uri.substring(1, uri.length - 2));
                return 0;
            });
            break;
            default: // apparently this is URL
            Regex protocolRegex = new Regex("/^[a-zA-Z]+://");
            if (!protocolRegex.match(uri))
            {
                string newUri = "http://" + uri;
                Gtk.show_uri(null, newUri, Gdk.CURRENT_TIME); 
                return true; // overwriting default behaviour because I can't change uri, so need to open a new uri with http:// at the beginning.
            }
            else
                return false;   
            break; 
        }
        return true; // if removed, the compiler complaints
    }

    public int loadUserFromUsername(string username)
    {
        string response = searchUser(username);
        List<User> userList;
        try
        {   
            userList  = parseUserList(response);
        }
        catch (Error e)
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }
        loadUser(userList.nth(0).data.id);
        return 0;
    }

    public int loadUser(string id)
    {
        Idle.add(() => {
            box.remove(stack);
            box.pack_start(loadingImage, true, true);
            switchWindow("user");
            return false;
        });
        string userInfo = getUserInfo(id);
        string userFeed = getUserMedia(id);
        User user;
        List<MediaInfo> userFeedList;
        try
        {
            user = parseUser(userInfo);
            userFeedList = parseFeed(userFeed);
            this.userWindowBox.userFeed.olderFeedLink = parsePagination(userFeed);
        }
        catch (Error e) // wrong token
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }

        Idle.add(() => {
            userWindowBox.load(user);
            userWindowBox.loadFeed(userFeedList);

            box.remove(loadingImage);
            box.pack_start(stack, true, true); 
            this.userWindowBox.userFeed.moreButton.clicked.connect(() => {
                new Thread<int>("", loadOlderUserFeed);
            });
            return false;
        });  
        return 0;
    } 
    public int loadOlderUserFeed()
    {
        /*Idle.add(() => {
            box.remove(stack);
            box.pack_start(loadingImage, true, true);
            return false;
        }); */
        string userFeed = getResponse(this.userWindowBox.userFeed.olderFeedLink);
        List<MediaInfo> userFeedList;
        try
        {
            userFeedList = parseFeed(userFeed);
            this.userWindowBox.userFeed.olderFeedLink = parsePagination(userFeed);
        }
        catch (Error e) // wrong token
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }

        Idle.add(() => {
            userWindowBox.loadOlderFeed(userFeedList);
            return false;
        });

        

        /*Idle.add(() => {
            box.remove(loadingImage);
            box.pack_start(stack, true, true); 
            return false;
        });  */

        return 0;
    } 

    protected override void shutdown () 
    {
        base.shutdown();
    }

    public int loadFeed()
    {
        string response = getUserFeed();
        try 
        {
            feedPosts = parseFeed(response);
            this.feedList.olderFeedLink = parsePagination(response);
        }
        catch (Error e) // wrong token
        {
            setErrorWidgets("wrong-login");
            return 0;
        }
        // if we got here then we've got no errors, yay!
        if(box.get_children().find(bar) != null)
            box.remove(bar);  

        new Thread<int>("", setFeedWidgets);
        return 0;
    }   

    public int loadOlderFeed()
    {
        string response = getOlderUserFeed(this.feedList.olderFeedLink);
        try 
        {
            var oldFeedPosts = parseFeed(response);
            this.feedList.olderFeedLink = parsePagination(response);
            foreach (MediaInfo post in oldFeedPosts)
                feedPosts.append(post);

            Idle.add(() => {
                if (this.feedList.olderFeedLink == "")
                    this.feedList.deleteMoreButton();

                return false;
            });

            
        }
        catch (Error e) // wrong token
        {
            setErrorWidgets("wrong-login");
            return 0;
        }
        // if we got here then we've got no errors, yay!   

        new Thread<int>("", setFeedWidgets);
        return 0;
    }

    public void setErrorWidgets(string reason)
    { 
        if(box.get_children().find(bar) != null)
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
        box.remove(loadingImage);
        box.pack_start(bar, false, true);
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
        feedButton.set_tooltip_text ("Feed");
        feedButton.set_label ("Feed");
        //feedButton.set_sensitive (false);
        centered_toolbar.add (feedButton);

        feedButton.clicked.connect(() => {
            switchWindow("userFeed");
        });

        exploreButton = new Gtk.ToggleToolButton ();
        exploreButton.set_icon_widget (new Gtk.Image.from_icon_name ("midori", Gtk.IconSize.LARGE_TOOLBAR));
        exploreButton.set_tooltip_text ("Explore");
        exploreButton.set_label ("Explore");
        //this.mainWindow.exploreButton.set_sensitive (false);
        centered_toolbar.add (exploreButton);

        photoButton = new Gtk.ToggleToolButton ();
        photoButton.set_icon_widget (new Gtk.Image.from_icon_name ("camera", Gtk.IconSize.LARGE_TOOLBAR));
        photoButton.set_tooltip_text ("Take a picture");
        photoButton.set_label ("Take a picture");
        //this.mainWindow.photoButton.set_sensitive (false);
        centered_toolbar.add (photoButton);

        newsButton = new Gtk.ToggleToolButton ();
        newsButton.set_icon_widget (new Gtk.Image.from_icon_name ("emblem-synchronizing", Gtk.IconSize.LARGE_TOOLBAR));
        newsButton.set_tooltip_text ("News");
        newsButton.set_label ("News");
        //this.mainWindow.newsButton.set_sensitive (false);
        centered_toolbar.add (newsButton);

        userButton = new Gtk.ToggleToolButton ();
        userButton.set_icon_widget (new Gtk.Image.from_icon_name ("system-users", Gtk.IconSize.LARGE_TOOLBAR));
        userButton.set_tooltip_text ("You");
        userButton.set_label ("You");
        //this.mainWindow.userButton.set_sensitive (false);
        centered_toolbar.add (userButton);

        header.set_custom_title (centered_toolbar);
    }

    public int setFeedWidgets()
    {        
        Idle.add(() => { 

            if (this.feedList.olderFeedLink != "")
                this.feedList.addMoreButton();         

            foreach (MediaInfo post in feedPosts)
                if (!feedList.contains(post))
                { 
                    feedList.prepend(post);
                    feedList.boxes.last().data.avatarBox.button_release_event.connect(() =>{
                        new Thread<int>("", () => {
                            loadUser(post.postedUser.id);
                            return 0;
                        });
                        return false;
                    });
                }         

            new Thread<int>("", loadImages);

            foreach(PostBox postBox in this.feedList.boxes)
                postBox.titleLabel.activate_link.connect(handleUris);

            if (!isFeedLoaded)
            {
                box.remove(loadingImage);
                box.pack_start(stack, true, true);
            }

            mainWindow.show_all();
            isFeedLoaded = true;

            return false;
        });

        
        return 0;
    } 

    public int loadImages()
    {
        foreach (PostBox postBox in feedList.boxes)
        {
            if (postBox.avatar.pixbuf == null) //avatar not loaded, that means image was not added to PostList
            {        
                postBox.loadAvatar();
                postBox.loadImage();
            }
            else
                print("already loaded.\n");
        }
        return 0;
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