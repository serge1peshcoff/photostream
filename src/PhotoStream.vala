using PhotoStream.Utils;
using PhotoStream.Widgets;
using Gdk;

#if HAVE_GRANITE
    public class PhotoStream.App : Granite.Application
#else
    public class PhotoStream.App : Gtk.Application
#endif
{
	public MainWindow mainWindow;
    public LoginWindow loginWindow;
    public SettingsWindow settingsWindow;
    public static string appToken = "";
    public const string REDIRECT_URI = "http://www.google.com/photostream";
    public const string CLIENT_ID = "e139a947d6de45a88297366282c27137";
    public const string CLIENT_SECRET = "4b54aac105534413b6885c2c48bcaa66";
    public const string SCHEMA_URI = "tk.itprogramming1.photostream";
    public const string SCHEMA_TOKEN = "token";
    public const string SCHEMA_LAST_CHECKED = "last-news-checked";
    public const string SCHEMA_REFRESH_INTERVAL = "refresh-interval";
    public const string SCHEMA_INSTAGRAM_IP = "instagram-api-ip";
    public const string SCHEMA_POSTS_OR_IMAGES = "posts-or-images";
    public static string CACHE_URL;
    public static string CACHE_AVATARS;
    public const string CACHE_IMAGES = "/usr/share/photostream/images/";
    public static string CACHE_HTML = "/usr/share/photostream/html/";
    public static List<MediaInfo> feedPosts;
    public bool isFeedLoaded = false;
    public static bool isMainWindowShown = false;
    
    public Gtk.HeaderBar header;

    public Gtk.ToolButton backButton;
    public Gtk.MenuButton settingsButton;

    public Gtk.Menu menu;
    public Gtk.MenuItem settingsMenuItem;
    public Gtk.MenuItem aboutMenuItem;
    public Gtk.MenuItem quitMenuItem;

    public Gtk.ToggleToolButton feedButton;
    public Gtk.ToggleToolButton searchButton;
    public Gtk.ToggleToolButton photoButton;
    public Gtk.ToggleToolButton newsButton; 
    public Gtk.ToggleToolButton userButton;

    public Gtk.InfoBar bar;
    public Gtk.Box box;
    public Gtk.Spinner loadingSpinner;

    public PhotoStack stack;

    public UserWindowBox userWindowBox;
    public HashTagFeedBox tagFeedBox;
    public LocationFeedBox locationFeedBox;
    public SearchWindowBox searchWindowBox;

    public PostList feedList; 
    public PostList postList; 
    public CommentsList commentsList;
    public UserList userList;
    public NewsList newsList;

    public static User selfUser;
    public Gee.HashMap<string, bool> isPageLoaded;

    public int REFRESH_INTERVAL;

    private bool headersCallbacksSet = false;

    public GLib.List<HistoryEntry> history;

#if HAVE_GRANITE
    construct {
        program_name        = "PhotoStream";
        exec_name           = "photostream";
        build_version       = "0.1";
        app_years           = "2014";
        app_icon            = "photostream";
        app_launcher        = "photostream.desktop";
        application_id      = "org.itprogramming1.photostream";
        main_url            = "http://itprogramming1.tk/photostream";
        about_authors       = {"Sergey Peshkov"};
        about_comments      = null;
        about_documenters   = {};
        about_translators   = null;
        about_license_type  = Gtk.License.GPL_3_0;
    }
#endif

    public App()
    {
#if !HAVE_GRANITE
    this.set_application_id("org.itprogramming1.photostream");
#endif
    }

	protected override void activate () 
	{
        isMainWindowShown = true;
        if (get_windows() == null) 
        { 
            isPageLoaded = new Gee.HashMap<string, bool>(); 

            isPageLoaded["news"] = false;
            isPageLoaded["user"] = false;
            isPageLoaded["feed"] = false;
            isPageLoaded["tagFeed"] = false;

            history = new GLib.List<HistoryEntry>();

            REFRESH_INTERVAL = loadRefreshInterval();


            CACHE_URL = Environment.get_home_dir() + "/.cache/photostream/";
            CACHE_AVATARS = CACHE_URL + "avatars/";

            mainWindow = new MainWindow ();
            setHeader();            
            
            box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            mainWindow.add(box);

            mainWindow.show_all ();
            mainWindow.set_application(this); 

            preloadWindows();

            tryLogin();
        }
        else
        {
            this.mainWindow.show_all();
        }
    }

    public void tryLogin()
    {
        appToken = loadToken();

        File file = File.new_for_path(CACHE_URL + "cookie.txt");  
        if (appToken == "") //something went wrong. need to re-login
            this.setErrorWidgets("not-logged-in");          
        else if (!file.query_exists())
            this.setErrorWidgets("wrong-login"); 
        else
            new Thread<int>("", loadFeed);
    }

    public void stubLoading()
    {
        switchWindow("loading");
    }

    public void preloadWindows()
    {
        this.stack = new PhotoStack();

        loadingSpinner = new Gtk.Spinner();
        loadingSpinner.start();

        stack.add_named(loadingSpinner, "loading"); 

        try 
        {
            File file = File.new_for_path(CACHE_URL);
            if (!file.query_exists())
                file.make_directory_with_parents ();

            file = File.new_for_path(CACHE_AVATARS);
            if (!file.query_exists())
                file.make_directory_with_parents ();

        } 
        catch (Error e) 
        {
            error("Error creating caching directories: %s\n", e.message);
        }

        this.feedList = new PostList();        
        stack.add_named(feedList, "userFeed");

        this.userWindowBox = new UserWindowBox();
        stack.add_named(userWindowBox, "user");

        userWindowBox.followersCountEventBox.button_release_event.connect(() => {
            new Thread<int>("", () => {
                if (!userWindowBox.isPrivate)
                    loadUsers(userWindowBox.user.id, "followers");
                return 0;
            }); 
            return false;
        });

        userWindowBox.followsCountEventBox.button_release_event.connect(() => {
            new Thread<int>("", () => {
                if (!userWindowBox.isPrivate)
                    loadUsers(userWindowBox.user.id, "follows");
                return 0;
            }); 
            return false;
        });

        this.commentsList = new CommentsList.withAvatars();
        stack.add_named(commentsList, "comments");

        this.userList = new UserList();
        stack.add_named(userList, "userList");

        this.tagFeedBox = new HashTagFeedBox();
        stack.add_named(tagFeedBox, "tagFeed");

        this.locationFeedBox = new LocationFeedBox();
        stack.add_named(locationFeedBox, "location");

        this.locationFeedBox.openInMapsButton.clicked.connect(() => {
            openLocationMap(this.locationFeedBox.location);
        });

        this.newsList = new NewsList();
        stack.add_named(newsList, "news");

        this.searchWindowBox = new SearchWindowBox();
        stack.add_named(searchWindowBox, "search");

        this.searchWindowBox.locationMapWindow.locationLoaded.connect((location) => {
            this.searchWindowBox.locationMapWindow.hide();
            new Thread<int>("", () => {
                loadLocation(location.id);
                return 0;
            });
        });
        this.searchWindowBox.usersLoaded.connect(() => {
            foreach (var box in searchWindowBox.userList.boxes)
                box.userNameLabel.activate_link.connect(handleUris);
        });
        this.searchWindowBox.userAvatarLoaded.connect((box) => {
            box.avatarBox.button_release_event.connect(() => {
                loadUser(box.user.id, box.user);
                return false;
            });
            box.avatarBox.enter_notify_event.connect((event) => {
                event.window.set_cursor (
                    new Gdk.Cursor.from_name (Gdk.Display.get_default(), "hand2")
                );
                return false;
            }); 
        });
        this.searchWindowBox.tagsLoaded.connect(() => {
            foreach (var box in searchWindowBox.tagList.boxes)
                box.hashtagNameLabel.activate_link.connect(handleUris);
        });

        this.postList = new PostList(true);
        stack.add_named(postList, "post");

        switchWindow("loading");

        box.pack_end(stack, true, true); 
        this.stack.show_all();
        this.mainWindow.show_all();      
    }

    public void setLoginWindow()
    {
        this.loginWindow = new LoginWindow ();
        bar.response.disconnect(this.response);

        this.loginWindow.show_all ();
        this.loginWindow.destroy.connect(() => {
            bar.response.connect(this.response);
            tryLogin();
        });
        this.loginWindow.set_application(this);
    }

    public void setSettingsWindow()
    {
        this.settingsWindow = new SettingsWindow ();

        this.settingsWindow.show_all ();
        this.settingsWindow.set_application(this);
        this.settingsWindow.destroy.connect(() => {
            if(loadToken() == "") // user has logged off
                Idle.add(() => {
                    this.mainWindow.destroy();
                    return false;
                });                
        });          
    }

    public bool handleUris(string uri)
    {
        switch(uri[0])
        {
            case '#': // hashtag, stub
                new Thread<int>("", () => {
                    loadTag(uri.substring(1, uri.length - 1));
                    return 0;
                });
                break;
            case '@': // username
                new Thread<int>("", () => {
                    loadUserFromUsername(uri.substring(1, uri.length - 1));
                    return 0;
                });
                break;
            default: // apparently this is URL
                Regex protocolRegex;
                try
                {
                   protocolRegex = new Regex("/^[a-zA-Z]+://");
                } 
                catch (Error e)
                {
                    error("Something wrong with regexes: %s", e.message);
                }
                if (!protocolRegex.match(uri))
                {
                    string newUri = "http://" + uri;
                    try
                    {
                        Gtk.show_uri(null, newUri, Gdk.CURRENT_TIME); 
                    }
                    catch (Error e)
                    {
                        error("Something wrong with url showing: %s", e.message);
                    }
                    return true; // overwriting default behaviour because I can't change uri, so need to open a new uri with http:// at the beginning.
                }
                else
                    return false;   
        }
        return true; // if removed, the compiler complaints
    }

    public int loadUserFromUsername(string username)
    {
        Idle.add(() => {
            stubLoading();
            return false;
        });
        isPageLoaded["user"] = false;
        string response = searchUsers(username);
        List<User> userList;
        try
        {   
            userList  = parseUserList(response);
        }
        catch (Error e)
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }
        loadUser(userList.nth(0).data.id, userList.nth(0).data);
        return 0;
    }

    public int loadTag(string tagName)
    {
        isPageLoaded["tagFeed"] = false;
        uncheckButtonsExcept("");

        Idle.add(() => {
            stubLoading();            
            return false;
        });
        string responseTagInfo = getTagInfo(tagName);
        string responseTagFeed = getTagRecent(tagName);
        Tag receivedTag;
        List<MediaInfo> tagFeedReceived = new List<MediaInfo>();

        try
        {
            receivedTag = parseTag(responseTagInfo);
            tagFeedReceived = parseFeed(responseTagFeed);
            tagFeedBox.hashtagFeed.olderFeedLink = parsePagination(responseTagFeed);
        }
        catch (Error e)
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }


        Idle.add(() => {
            tagFeedBox.hashtagFeed.clear();

            tagFeedBox.loadTag(receivedTag);
            tagFeedBox.loadFeed(tagFeedReceived);

            if (getActiveWindow() == "loading")
            {
                isPageLoaded["tagFeed"] = true;
                addHistoryEntry("tag", tagName);

                
                switchWindow("tagFeed");
                this.stack.show_all();
            }
            return false;
        });
        
        return 0;
    }

    public int loadPost(string id)
    {
        uncheckButtonsExcept("");
        Idle.add(() => {
            stubLoading();            
            return false;
        });
        string responsePostInfo = getMediaData(id);
        MediaInfo receivedPost;

        try
        {
            receivedPost = parseMediaPost(responsePostInfo);
        }
        catch (Error e)
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }


        Idle.add(() => {
            postList.clear();
            postList.deleteMoreButton();
                        
            postList.prepend(receivedPost);

            new Thread<int>("", () => {
                postList.boxes.last().data.loadAvatar();
                postList.boxes.last().data.loadImage();
                return 0;
            });  

            if (getActiveWindow() == "loading")
            {

                addHistoryEntry("post", id);       

                switchWindow("post");
                this.stack.show_all();
            }
            return false;
        });
        
        return 0;
    }

    public int openLocationMap(Location location)
    {
        LocationMapWindow locationWindow = new LocationMapWindow.with_location(location);
        locationWindow.locationLoaded.connect((location) => {
            locationWindow.close();
            new Thread<int>("", () => {
                loadLocation(location.id);
                return 0;
            });
        });
        locationWindow.show_all();

        return 0;
    }

    public int loadLocation(string locationId)
    {
        uncheckButtonsExcept("");
        Idle.add(() => {
            stubLoading();            
            return false;
        });
        string responseLocationInfo = getLocationInfo(locationId);
        string responseLocationFeed = getLocationRecent(locationId);
        Location receivedLocation;
        List<MediaInfo> locationFeedReceived = new List<MediaInfo>();

        try
        {
            receivedLocation = parseLocation(responseLocationInfo);
            locationFeedReceived = parseFeed(responseLocationFeed);
            locationFeedBox.locationFeed.olderFeedLink = parsePagination(responseLocationFeed);
        }
        catch (Error e)
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }


        Idle.add(() => {
            locationFeedBox.locationFeed.clear();

            locationFeedBox.loadLocation(receivedLocation);
            locationFeedBox.loadFeed(locationFeedReceived);

            if (getActiveWindow() == "loading")
            {

                addHistoryEntry("location", locationId.to_string());

                switchWindow("location");
                this.stack.show_all();
            }
            return false;
        });
        
        return 0;
    }


    public int loadComments(string postId)
    {
        uncheckButtonsExcept("");
        Idle.add(() => {
            stubLoading();            
            return false;
        });
        string response = getComments(postId);
        List<Comment> commentsListRequested = new List<Comment>();

        try
        {
            commentsListRequested = parseComments(response);

        }
        catch (Error e)
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }

        Idle.add(() => {
            commentsList.clear();
            foreach(Comment comment in commentsListRequested)
            {
                commentsList.prepend(comment);
                commentsList.comments.last().data.textLabel.activate_link.connect(handleUris);
                if( commentsList.comments.last().data.avatarBox != null)
                    commentsList.comments.last().data.avatarBox.button_release_event.connect(() => {
                        new Thread<int>("", () => {
                            loadUser(comment.user.id, comment.user);
                            return 0;
                        });                   
                        return false;
                    });
            }

            if (getActiveWindow() == "loading")
            {

                addHistoryEntry("comments", postId);

                commentsList.postId = postId;
                switchWindow("comments");
            }
            return false;
        });
        
        return 0;
    }


    public int loadUsers(string postId, string type)
    {
        uncheckButtonsExcept("");
        isPageLoaded["user"] = false;
        Idle.add(() => {
            stubLoading();            
            return false;
        });
        string response;
        if (type == "likes")
            response = getMediaLikes(postId);
        else if (type == "follows")
            response = getUserFollows(postId); 
        else if (type == "followers")
            response = getUserFollowers(postId);  
        else
            error("Should've not reach here."); 
        List<User> likees = new List<User>();

        try
        {
            likees = parseUserList(response);
        }
        catch (Error e) // wrong token
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }

        Idle.add(() => {
            userList.clear();
            foreach(User user in likees)
                userList.prepend(user);

            if (getActiveWindow() == "loading")
            {

                isPageLoaded["user"] = true;
                addHistoryEntry(type, postId);
            
                switchWindow("userList");
                this.box.show_all();   
            }

            new Thread<int>("", () => {                  
                foreach(UserBox userBox in userList.boxes)
                    userBox.loadAvatar();                    
                return 0;
            });     

            foreach(UserBox userBox in userList.boxes)
            {
                userBox.userNameLabel.activate_link.connect(handleUris);
                userBox.avatarBox.button_release_event.connect(() => {
                    new Thread<int>("", () => {
                        loadUser(userBox.user.id, userBox.user);
                        return 0;
                    });
                    return false;
                });  
            }              

            foreach(UserBox userBox in userList.boxes)
            {
                if (userBox.user.id == selfUser.id)
                    continue;

                new Thread<int>("", () => {
                    Relationship usersRelationship;
                    if (type == "follows" && userWindowBox.user.id == selfUser.id) // loading self followers
                    {   
                        usersRelationship = new Relationship();  // don't need to actually load this from server, lol
                        usersRelationship.outcoming = "follows"; // so make a stub Relationship object and load it into userBox
                    }
                    else
                    {
                        string responseRelatioship = getUsersRelationship(userBox.user.id);
                        usersRelationship = new Relationship();

                        try
                        {
                            usersRelationship = parseRelationship(responseRelatioship);
                        }
                        catch (Error e) 
                        {
                            error("Something wrong with parsing: " + e.message + ".\n");
                        }
                    }            

                    userBox.user.relationship = usersRelationship;
                    Idle.add(() => {
                        userBox.loadRelationship();
                        return false;
                    });

                    return 0;
                }); 
            }
            return false; 
        });
        
        return 0;
    }

    public int loadUser(string id, User? loadedUser = null)
    {
        Idle.add(() => {
            if (id != selfUser.id)
                uncheckButtonsExcept("");
            stubLoading();            
            return false;
        });

        if (userWindowBox.user != null && userWindowBox.user.id == id) // if user is already loaded, just open the user tab and return. no need to load.
        {
            Idle.add(() => {
                switchWindow("user");
                return false;
            });
            return 0;
        }

        string userInfo = getUserInfo(id);
        string relationshipInfo = getUsersRelationship(id);
        User user = new User();
        bool isPrivate = false;
        Relationship relationship = null;

        if (getActiveWindow() == "loading")
            addHistoryEntry("user", id);

        try
        {
            relationship = parseRelationship(relationshipInfo);
            user = parseUser(userInfo);            
            user.relationship = relationship;
        }
        catch (Error e)
        {
            if (e.message == "you cannot view this resource") // this profile is private
            {
                isPrivate = true;
                loadedUser.relationship = relationship;
            }
            else
                error("Something wrong with parsing: " + e.message + ".\n");
        }

        if (isPrivate)
        {
            Idle.add(() => {
                userWindowBox.load(loadedUser);
                userWindowBox.loadPrivate();

                if (getActiveWindow() == "loading")
                    switchWindow("user");
                return false;
            });
            return 0;
        }

        // if we got here, user it not private (apparently).

        string userFeed = getUserMedia(id);        
        List<MediaInfo> userFeedList = new List<MediaInfo>();        

        try
        {            
            userFeedList = parseFeed(userFeed);
            this.userWindowBox.userFeed.olderFeedLink = parsePagination(userFeed);
        }
        catch (Error e)
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }

        Idle.add(() => {
            userWindowBox.loadFeed(userFeedList);
            userWindowBox.load(user);

            if (getActiveWindow() == "loading")
                switchWindow("user");
            return false;
        });  
        return 0;
    }

    public int loadFeed()
    {
        loadSelfInfo();
        new Thread<int>("", () => {
            loadNews();
            return 0;
        });
        Idle.add(() => {
            uncheckButtonsExcept("feed");
            return false;
        });      

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
        if(bar != null && bar.is_ancestor(box))
            box.remove(bar); 

        //if (getActiveWindow() == "loading")
            addHistoryEntry("feed", "");        

        new Thread<int>("", setFeedWidgets);      
        return 0;
    }  

    public void loadNews()
    {
        string response = getUserNews();
        List<NewsActivity> userNews = parseNews(response);

        Idle.add(() => {
            foreach(NewsActivity activity in userNews)
                newsList.prepend(activity);

            isPageLoaded["news"] = true;

            foreach(NewsBox newsBox in newsList.boxes)
                connectNewsBoxHandlers(newsBox);

            if (isMainWindowShown)
                this.mainWindow.show_all();
            displayNewsNotifications(userNews);
            return false;
        });
    }

    public void refreshFeed()
    {
        var lastId = feedPosts.first().data.id;
        string response = getUserFeed(lastId);

        List<MediaInfo> newList;
        try
        {
            newList = parseFeed(response);
        }
        catch (Error e) 
        {
            error("Something wrong with parsing: %s", e.message);
        }

        newList.reverse();

        foreach (MediaInfo element in newList)
        {
            feedPosts.prepend(element);
            Idle.add(() => {
                feedList.append(element);

                new Thread<int>("", () => {
                    feedList.boxes.first().data.loadAvatar();
                    feedList.boxes.first().data.loadImage();
                    Idle.add(() => {
                        if (isMainWindowShown)
                            this.mainWindow.show_all();
                        return false;
                    });
                    return 0;
                });               

                return false;
            });
            
        }

        GLib.Timeout.add_seconds(REFRESH_INTERVAL, () => {
            new Thread<int>("", () => {
                refreshFeed();
                return 0;
            });                
            return false;
        });
    }

    public void refreshNews()
    {
        string response = getUserNews();

        List<NewsActivity> newList = parseNews(response);
        newList.reverse();

        Idle.add(() => {
            foreach (NewsActivity element in newList)
            {
                if (newsList.contains(element))
                    continue;

                newsList.append(element);
                connectNewsBoxHandlers(newsList.boxes.last().data);         

                if (isMainWindowShown)
                    this.mainWindow.show_all();               
            }     
            newList.reverse();
            displayNewsNotifications(newList);
            return false;            
        });        

        GLib.Timeout.add_seconds(REFRESH_INTERVAL, () => {
            new Thread<int>("", () => {
                refreshNews();
                return 0;
            });                
            return false;
        });
    }

    public void loadSelfInfo()
    {
        string response = getUserInfo("self");
        try 
        {
            selfUser = parseUser(response);
        }
        catch (Error e) // wrong token
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }
    } 

    public void setErrorWidgets(string reason)
    { 
        if(bar != null && bar.is_ancestor(box))
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
        box.pack_start(bar, false, true);
        bar.response.connect(this.response);
        if (isMainWindowShown)
            mainWindow.show_all ();
    }
    public void setHeader()
    {
        header = new Gtk.HeaderBar ();
        header.set_show_close_button (true);
        this.mainWindow.set_titlebar (header);

        backButton = new Gtk.ToolButton(new Gtk.Image.from_icon_name ("go-previous", Gtk.IconSize.LARGE_TOOLBAR), "Go back");
        backButton.set_tooltip_text ("Go back");
        backButton.set_sensitive (false);
        this.header.pack_start(backButton);

        Gtk.Box centered_toolbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

        feedButton = new Gtk.ToggleToolButton ();
        feedButton.set_icon_widget (new Gtk.Image.from_icon_name ("go-home", Gtk.IconSize.LARGE_TOOLBAR));
        feedButton.set_tooltip_text ("Feed");
        feedButton.set_label ("Feed");
        feedButton.set_sensitive (false);
        centered_toolbar.add (feedButton);        

        photoButton = new Gtk.ToggleToolButton ();
        photoButton.set_icon_widget (new Gtk.Image.from_icon_name ("camera", Gtk.IconSize.LARGE_TOOLBAR));
        photoButton.set_tooltip_text ("Take a picture");
        photoButton.set_label ("Take a picture");
        photoButton.set_sensitive (false);
        centered_toolbar.add (photoButton);

        newsButton = new Gtk.ToggleToolButton ();
        newsButton.set_icon_widget (new Gtk.Image.from_icon_name ("emblem-synchronizing", Gtk.IconSize.LARGE_TOOLBAR));
        newsButton.set_tooltip_text ("News");
        newsButton.set_label ("News");
        newsButton.set_sensitive (false);
        centered_toolbar.add (newsButton);

        userButton = new Gtk.ToggleToolButton ();
        userButton.set_icon_widget (new Gtk.Image.from_icon_name ("system-users", Gtk.IconSize.LARGE_TOOLBAR));
        userButton.set_tooltip_text ("You");
        userButton.set_label ("You");
        userButton.set_sensitive (false);
        centered_toolbar.add (userButton);   

        searchButton = new Gtk.ToggleToolButton ();
        searchButton.set_icon_widget (new Gtk.Image.from_icon_name ("search", Gtk.IconSize.LARGE_TOOLBAR));
        searchButton.set_tooltip_text ("Search");
        searchButton.set_label ("Search");
        searchButton.set_sensitive (false);
        centered_toolbar.add (searchButton);     

        header.set_custom_title (centered_toolbar);

        menu = new Gtk.Menu();
        settingsMenuItem = new Gtk.MenuItem.with_label("Settings...");
        aboutMenuItem = new Gtk.MenuItem.with_label("About...");
        quitMenuItem = new Gtk.MenuItem.with_label("Quit");
        menu.add(settingsMenuItem);
        menu.add(new Gtk.SeparatorMenuItem());
        menu.add(aboutMenuItem);
        menu.add(quitMenuItem);
        this.menu.show_all();

        settingsButton = new Gtk.MenuButton();
        settingsButton.set_relief (Gtk.ReliefStyle.NONE);
        settingsButton.set_tooltip_text ("Settings");
        settingsButton.set_popup(menu);
        this.header.pack_end(settingsButton);
    }

    public void setHeaderCallbacks()
    {
        if (headersCallbacksSet)
            return;

        feedButton.set_sensitive (true);
        searchButton.set_sensitive (true);
        photoButton.set_sensitive (true);
        newsButton.set_sensitive (true);
        userButton.set_sensitive (true);

        feedButton.toggled.connect(() => {
            if (!feedButton.get_active())
                return;
            if (isPageLoaded["feed"])
                switchWindow("userFeed");
            else
                switchWindow("loading");
            uncheckButtonsExcept("feed");
            addHistoryEntry("feed", "");
        });

        searchButton.toggled.connect(() => {
            if (!searchButton.get_active())
                return;
            switchWindow("search");
            addHistoryEntry("search", "");
            uncheckButtonsExcept("search");
        });

        photoButton.toggled.connect(() => {
            if (!photoButton.get_active())
                return;
            uncheckButtonsExcept("photo");
            //addHistoryEntry("photo", "");
        });

        newsButton.toggled.connect(() => {
            if (!newsButton.get_active())
                return;
            switchWindow("news");
            addHistoryEntry("news", "");
            uncheckButtonsExcept("news");
        });        

        userButton.toggled.connect(() => {
            if (!userButton.get_active())
                return;
            uncheckButtonsExcept("self");            
            if (isPageLoaded["feed"])
                new Thread<int>("", () => {
                    loadUser(selfUser.id);
                    return 0;
                }); 
            else
                switchWindow("loading");             
        });
        backButton.clicked.connect(() => {
            stepBackHistory();
        });

        settingsMenuItem.activate.connect(() => {
            this.setSettingsWindow();
        });
        aboutMenuItem.activate.connect(() => {
#if HAVE_GRANITE
            show_about(this.mainWindow);
#else
            // stub, to do later
#endif
        });
        quitMenuItem.activate.connect(() => {
            this.mainWindow.destroy();
        });

        headersCallbacksSet = true;
    }

    public void uncheckButtonsExcept(string notUncheck)
    {
        Idle.add(() => {
            feedButton.set_active(notUncheck == "feed");
            userButton.set_active(notUncheck == "self");
            photoButton.set_active(notUncheck == "photo");
            searchButton.set_active(notUncheck == "search");
            newsButton.set_active(notUncheck == "news");
            return false;
        });
    }

    public int setFeedWidgets()
    {       
        //string response = postPicture("/allext/image.jpg");
        //print(response + "\n");

        Idle.add(() => { 
            if (!headersCallbacksSet)
                this.searchWindowBox.addFields();

            setHeaderCallbacks();

            var statusIcon = new PhotoStream.Widgets.StatusIcon();   

            foreach (MediaInfo post in feedPosts)
                if (!feedList.contains(post)) 
                    feedList.prepend(post);

            if (feedList.olderFeedLink == "")
                feedList.deleteMoreButton();

            isPageLoaded["feed"] = true;                       

            new Thread<int>("", loadImages);                    

            if (!isFeedLoaded && getActiveWindow() == "loading")
                switchWindow("userFeed");

            GLib.Timeout.add_seconds(REFRESH_INTERVAL, () => {
                new Thread<int>("", () => {
                    refreshFeed();
                    return 0;
                });                
                return false;
            });

            GLib.Timeout.add_seconds(REFRESH_INTERVAL, () => {
                new Thread<int>("", () => {
                    refreshNews();
                    return 0;
                });                
                return false;
            });

            if (isMainWindowShown)
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
        }
        //feedList.resizeAllImages(this.mainWindow.get_allocated_width());
        return 0;
    }

    public void connectNewsBoxHandlers(NewsBox newsBox)
    {
        newsBox.avatarBox.button_release_event.connect(() => {
            new Thread<int>("", () => {
                loadUserFromUsername(newsBox.activity.username);
                return 0;
            });                    
            return false;
        });
        newsBox.postImageBox.button_release_event.connect(() => {
            new Thread<int>("", () => {
                loadPost(newsBox.activity.postId);
                return 0;
            });                    
            return false;
        });
        newsBox.commentLabel.activate_link.connect(handleUris); 
    }  

    public void switchWindow(string window)
    {
        stack.set_visible_child_name(window);
    } 
    public string getActiveWindow()
    {
        return stack.get_visible_child_name();
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
    public void addHistoryEntry(string type, string id)
    {
        if (history.length() != 0 && history.last().data.type == type && history.last().data.id == id)
            return;

        var entry = new HistoryEntry();
        entry.type = type;
        entry.id = id;
        history.append(entry);

        if (this.history.length() > 1)
            this.backButton.set_sensitive(true);
    } 
    public void stepBackHistory()
    {
        var lastEntry = history.last().data;
        history.remove(lastEntry);

        if (history.length() <= 1)
            this.backButton.set_sensitive(false);

        var lastEntryType = history.last().data.type;
        var lastEntryId = history.last().data.id;
        

        switch (lastEntryType)
        {
            case "user":
                new Thread<int>("", () => {
                    loadUser(lastEntryId);
                    return 0;
                });
                break;
            case "likes":
            case "follows":
            case "followers":
                new Thread<int>("", () => {
                    loadUsers(lastEntryId, lastEntryType);
                    return 0;
                });
                break;
            case "comments":
                new Thread<int>("", () => {
                    loadComments(lastEntryId);
                    return 0;
                });
                break;
            case "feed":
                switchWindow("userFeed");
                break;
            case "tag":
                new Thread<int>("", () => {
                    loadTag(lastEntryId);
                    return 0;
                });
                break;
            case "location":
                new Thread<int>("", () => {
                    loadLocation(lastEntryId);
                    return 0;
                });
                break;
            case "post":
                new Thread<int>("", () => {
                    loadPost(lastEntryId);
                    return 0;
                });
                break;
            case "search":
                switchWindow("search");
                break;
            case "news":
                switchWindow("news");
                break;
            default:
                error("Should've not reached here: %s", lastEntryType);
        }

    }   
}