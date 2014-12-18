using PhotoStream.Utils;
using PhotoStream.Widgets;
using Gdk;

public class PhotoStream.App : Granite.Application 
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
    public Gtk.ScrolledWindow userFeedWindow;
    public Gtk.ScrolledWindow userNewsWindow;
    public Gtk.ScrolledWindow tagFeedWindow;
    public Gtk.ScrolledWindow locationFeedWindow;
    public Gtk.ScrolledWindow userWindow;
    public Gtk.ScrolledWindow postWindow;
    public Gtk.ScrolledWindow userListWindow;
    public Gtk.ScrolledWindow commentWindow;
    public Gtk.ScrolledWindow usersWindow;
    public Gtk.ScrolledWindow searchWindow;

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

    public App()
    {
        //this.create_appmenu(new Gtk.Menu());
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

            bar = new Gtk.InfoBar();  
            
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

        this.userFeedWindow = new Gtk.ScrolledWindow (null, null);
        this.userFeedWindow.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.ALWAYS);
        stack.add_named(userFeedWindow, "userFeed");

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
        this.userFeedWindow.add_with_viewport (feedList);

        this.userWindow = new Gtk.ScrolledWindow(null, null);
        this.userWindowBox = new UserWindowBox();
        this.userWindow.add_with_viewport (userWindowBox);
        stack.add_named(userWindow, "user");

        userWindowBox.followersCountEventBox.button_release_event.connect(() => {
            new Thread<int>("", () => {
                loadUsers(userWindowBox.user.id, "followers");
                return 0;
            }); 
            return false;
        });

        userWindowBox.followsCountEventBox.button_release_event.connect(() => {
            new Thread<int>("", () => {
                loadUsers(userWindowBox.user.id, "follows");
                return 0;
            }); 
            return false;
        });

        this.commentWindow = new Gtk.ScrolledWindow(null, null);
        this.commentsList = new CommentsList.withAvatars();
        this.commentWindow.add_with_viewport(commentsList);
        stack.add_named(commentWindow, "comments");

        this.userListWindow = new Gtk.ScrolledWindow(null, null);
        this.userList = new UserList();
        this.userListWindow.add_with_viewport(userList);
        stack.add_named(userListWindow, "userList");

        this.tagFeedWindow = new Gtk.ScrolledWindow(null, null);
        this.tagFeedWindow.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.ALWAYS);
        this.tagFeedBox = new HashTagFeedBox();
        this.tagFeedWindow.add_with_viewport(tagFeedBox);
        stack.add_named(tagFeedWindow, "tagFeed");

        this.locationFeedWindow = new Gtk.ScrolledWindow(null, null);
        this.locationFeedWindow.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.ALWAYS);
        this.locationFeedBox = new LocationFeedBox();
        this.locationFeedWindow.add_with_viewport(locationFeedBox);
        stack.add_named(locationFeedWindow, "location");

        this.locationFeedBox.openInMapsButton.clicked.connect(() => {
            openLocationMap(this.locationFeedBox.location);
        });

        this.userNewsWindow = new Gtk.ScrolledWindow(null, null);
        this.newsList = new NewsList();
        this.userNewsWindow.add_with_viewport(newsList);
        stack.add_named(userNewsWindow, "news");

        this.searchWindow = new Gtk.ScrolledWindow(null, null);
        this.searchWindow.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.ALWAYS);
        this.searchWindowBox = new SearchWindowBox();
        this.searchWindow.add_with_viewport(searchWindowBox);
        stack.add_named(searchWindow, "search");

        this.searchWindowBox.locationMapWindow.locationLoaded.connect((location) => {
            loadLocation(location.id);
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


        this.postWindow = new Gtk.ScrolledWindow(null, null);
        this.postList = new PostList();
        this.postWindow.add_with_viewport(postList);
        stack.add_named(postWindow, "post");

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
            if (tagFeedBox.hashtagFeed.olderFeedLink != "")
                tagFeedBox.hashtagFeed.moreButton.clicked.connect(() => {
                    new Thread<int>("", () => {
                        loadOlderTagFeed();
                        return 0;
                    });
                    
                });

            tagFeedBox.loadTag(receivedTag);
            tagFeedBox.loadFeed(tagFeedReceived);

            foreach(PostBox box in tagFeedBox.hashtagFeed.boxes)
                connectPostBoxHandlers(box);

            isPageLoaded["tagFeed"] = true;
            addHistoryEntry("tag", tagName);

            switchWindow("tagFeed");
            this.stack.show_all();
            return false;
        });
        
        return 0;
    }

    public void loadOlderTagFeed()
    {
        string response = getOlderUserFeed(tagFeedBox.hashtagFeed.olderFeedLink);
        List<MediaInfo> olderFeed;
        try 
        {
            olderFeed = parseFeed(response);
            tagFeedBox.hashtagFeed.olderFeedLink = parsePagination(response);
            
        }
        catch (Error e)
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }
        Idle.add(() => {            
            tagFeedBox.loadOlderFeed(olderFeed);
            if (tagFeedBox.hashtagFeed.olderFeedLink == "")
                tagFeedBox.hashtagFeed.deleteMoreButton();
            return false;
        });        
    }

    public int loadPost(string id)
    {
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
            connectPostBoxHandlers(postList.boxes.last().data);   

            addHistoryEntry("post", id);       

            switchWindow("post");
            this.stack.show_all();
            return false;
        });
        
        return 0;
    }

    public int openLocationMap(Location location)
    {
        LocationMapWindow locationWindow = new LocationMapWindow.with_location(location);
        locationWindow.show_all();

        return 0;
    }

    public int loadLocation(int64 locationId)
    {
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
            if (locationFeedBox.locationFeed.olderFeedLink != "")
                locationFeedBox.locationFeed.moreButton.clicked.connect(() => {
                    new Thread<int>("", () => {
                        loadOlderLocationFeed();
                        return 0;
                    });
                    
                });

            locationFeedBox.loadLocation(receivedLocation);
            locationFeedBox.loadFeed(locationFeedReceived);

            foreach(PostBox box in locationFeedBox.locationFeed.boxes)
                connectPostBoxHandlers(box);

            addHistoryEntry("location", locationId.to_string());

            switchWindow("location");
            this.stack.show_all();
            return false;
        });
        
        return 0;
    }

    public void loadOlderLocationFeed()
    {
        string response = getOlderUserFeed(locationFeedBox.locationFeed.olderFeedLink);
        List<MediaInfo> olderFeed;
        try 
        {
            olderFeed = parseFeed(response);
            locationFeedBox.locationFeed.olderFeedLink = parsePagination(response);
            
        }
        catch (Error e)
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }
        Idle.add(() => {            
            locationFeedBox.loadOlderFeed(olderFeed);
            if (locationFeedBox.locationFeed.olderFeedLink == "")
                locationFeedBox.locationFeed.deleteMoreButton();
            return false;
        });        
    }

    public int loadComments(string postId)
    {
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

            addHistoryEntry("comments", postId);

            commentsList.postId = postId;
            switchWindow("comments");
            return false;
        });
        
        return 0;
    }


    public int loadUsers(string postId, string type)
    {
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

            isPageLoaded["user"] = true;
            addHistoryEntry(type, postId);
        
            switchWindow("userList");
            this.box.show_all();   

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
            stubLoading();
            
            return false;
        });

        if (userWindowBox.user != null &&userWindowBox.user.id == id) // if user is already loaded, just open the user tab and return. no need to load.
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

                switchWindow("user");
                this.userWindowBox.userFeed.moreButton.clicked.connect(() => {
                    new Thread<int>("", loadOlderUserFeed);
                });
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

            foreach (PostBox postBox in userWindowBox.userFeed.boxes)
                connectPostBoxHandlers(postBox);

            switchWindow("user");
            this.userWindowBox.userFeed.moreButton.clicked.connect(() => {
                new Thread<int>("", loadOlderUserFeed);
            });
            return false;
        });  
        return 0;
    }

    public int loadOlderUserFeed()
    {
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
            foreach (PostBox postBox in userWindowBox.userFeed.boxes)
                connectPostBoxHandlers(postBox);
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
        if(bar.is_ancestor(box))
            box.remove(bar); 

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
                connectPostBoxHandlers(feedList.boxes.first().data);

                new Thread<int>("", () => {
                    feedList.boxes.last().data.loadAvatar();
                    feedList.boxes.last().data.loadImage();
                    return 0;
                });               

                if (isMainWindowShown)
                    this.mainWindow.show_all();

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

    public int loadMissingLocation(PostBox postBox, int64 id)
    {
        string response = getLocationInfo(id);
        Location location;
        try
        {
            location = parseLocation(response);
        }
        catch (Error e) 
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }
        Idle.add(() => {
            postBox.loadLocation(location);
            return false;
        });
        return 0;
    }

    public void setErrorWidgets(string reason)
    { 
        if(bar.is_ancestor(box))
            box.remove(bar);   
            
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

        feedButton.clicked.connect(() => {
            if (isPageLoaded["feed"])
                switchWindow("userFeed");
            else
                switchWindow("loading");
            uncheckButtonsExcept("feed");
            addHistoryEntry("feed", "");
        });

        searchButton.clicked.connect(() => {
            switchWindow("search");
            addHistoryEntry("search", "");
            uncheckButtonsExcept("search");
        });

        photoButton.clicked.connect(() => {
            uncheckButtonsExcept("photo");
            //addHistoryEntry("photo", "");
        });

        newsButton.clicked.connect(() => {
            switchWindow("news");
            addHistoryEntry("news", "");
            uncheckButtonsExcept("news");
        });        

        userButton.clicked.connect(() => {
            uncheckButtonsExcept("self");
            addHistoryEntry("user", selfUser.id);
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
            show_about(this.mainWindow);
        });
        quitMenuItem.activate.connect(() => {
            this.mainWindow.destroy();
        });

        headersCallbacksSet = true;
    }

    public void uncheckButtonsExcept(string notUncheck)
    {
        Idle.add(() => {
            //feedButton.active = (notUncheck == "feed");
            //userButton.active = (notUncheck == "self");
            //photoButton.active = (notUncheck == "photo");
            //searchButton.active = (notUncheck == "search");
            //newsButton.active = (notUncheck == "news");
            return false;
        });
    }

    public int setFeedWidgets()
    {       
        Idle.add(() => { 
            if (!headersCallbacksSet)
                this.searchWindowBox.addFields();

            setHeaderCallbacks();

            this.feedList.moreButton.clicked.connect(() => {
                new Thread<int>("", loadOlderFeed);
            });      

            foreach (MediaInfo post in feedPosts)
                if (!feedList.contains(post)) 
                {
                    feedList.prepend(post);
                    connectPostBoxHandlers(feedList.boxes.last().data);
                }

            if (feedList.olderFeedLink == "")
                feedList.deleteMoreButton();

            isPageLoaded["feed"] = true;                       

            new Thread<int>("", loadImages);                    

            if (!isFeedLoaded)
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
        return 0;
    }

    public void connectPostBoxHandlers(PostBox postBox)
    {
        postBox.titleLabel.activate_link.connect(handleUris);
        postBox.likesLabel.activate_link.connect((uri) => {
            if (uri == "getLikes")
            {
                new Thread<int>("", () => {
                    loadUsers(postBox.post.id, "likes");
                    return 0;
                });                
                return true;
            }
            else
                return handleUris(uri);
        });
        foreach(CommentBox commentBox in postBox.commentList.comments)
            commentBox.textLabel.activate_link.connect(handleUris);

        // for not crashing when using loadMissingLocation
        int64 tmpLocationId = (postBox.post.location == null) ? 0 : postBox.post.location.id; 
        bool locationMissing = false;

        if (postBox.post.location != null 
            && postBox.post.location.latitude == 0 
            && postBox.post.location.longitude == 0 
            && postBox.post.location.name == ""
            && postBox.post.location.id != 0) // sometimes location contains only ID, for such cases
        {
            locationMissing = true;
            new Thread<int>("", () => {
                loadMissingLocation(postBox, postBox.post.location.id);
                return 0;
            });
        }
        if (postBox.commentList.loadMoreButton != null)
            postBox.commentList.loadMoreButton.activate_link.connect(() => { 
                new Thread<int>("", () => {
                    loadComments(postBox.post.id);
                    return 0;
                });
                return true;
            });

        postBox.avatarBox.button_release_event.connect(() =>{
            new Thread<int>("", () => {
                loadUser(postBox.post.postedUser.id, postBox.post.postedUser);
                return 0;
            });
            return false;
        });
        if (postBox.locationEventBox != null)
        {
            postBox.locationEventBox.button_release_event.connect(() =>{
                new Thread<int>("", () => {
                    if (!locationMissing && postBox.post.location.id == 0) // only coordinates available
                        Idle.add(() => {
                            openLocationMap(postBox.post.location); 
                            return false;
                        });                                           
                    else if (locationMissing && tmpLocationId != 0)
                        loadLocation(tmpLocationId);
                    else
                        loadLocation(postBox.post.location.id);                                    
                    return 0;
                });
                
                return false;
            });
        }
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
                    loadLocation(int64.parse(lastEntryId));
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