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
    public Gtk.ScrolledWindow tagSearchWindow;
    public Gtk.ScrolledWindow userWindow;
    public Gtk.ScrolledWindow postWindow;
    public Gtk.ScrolledWindow userListWindow;
    public Gtk.ScrolledWindow commentWindow;
    public Gtk.ScrolledWindow usersWindow;
    public Gtk.ScrolledWindow searchWindow;

    public UserWindowBox userWindowBox;
    public HashTagFeedBox tagFeedBox;

    public PostList feedList; 
    public CommentsList commentsList;
    public HashTagList tagList;
    public UserList userList;

    public static User selfUser;

    private bool headersCallbacksSet = false;
    
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

        mainWindow.show_all ();
        mainWindow.destroy.connect (Gtk.main_quit);
        mainWindow.set_application(this); 

        preloadWindows();

        tryLogin();
    }

    public void tryLogin()
    {   
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
        {
            new Thread<int>("", loadFeed);
        }
    }

    public void stubLoading()
    {
        if (!loadingImage.is_ancestor(box))
        {
            box.remove(stack);
            box.pack_start(loadingImage, true, true);
        }
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
            error("Error creating caching directories: %s\n", e.message);
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

        userWindowBox.followersCountBox.button_release_event.connect(() => {
            new Thread<int>("", () => {
                loadUsers(userWindowBox.user.id, "followers");
                return 0;
            }); 
            return false;
        });

        userWindowBox.followsCountBox.button_release_event.connect(() => {
            new Thread<int>("", () => {
                loadUsers(userWindowBox.user.id, "follows");
                return 0;
            }); 
            return false;
        });

        this.commentWindow = new Gtk.ScrolledWindow(null, null);
        this.commentsList = new CommentsList();
        this.commentWindow.add_with_viewport(commentsList);
        stack.add_named(commentWindow, "comments");

        this.tagSearchWindow = new Gtk.ScrolledWindow(null, null);
        this.tagList = new HashTagList();
        this.tagSearchWindow.add_with_viewport(tagList);
        stack.add_named(tagSearchWindow, "tags");

        this.userListWindow = new Gtk.ScrolledWindow(null, null);
        this.userList = new UserList();
        this.userListWindow.add_with_viewport(userList);
        stack.add_named(userListWindow, "userList");

        this.tagFeedWindow = new Gtk.ScrolledWindow(null, null);
        this.tagFeedWindow.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.ALWAYS);
        this.tagFeedBox = new HashTagFeedBox();
        this.tagFeedWindow.add_with_viewport(tagFeedBox);
        stack.add_named(tagFeedWindow, "tagFeed");

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
            Regex protocolRegex = new Regex("/^[a-zA-Z]+://");
            if (!protocolRegex.match(uri))
            {
                string newUri = "http://" + uri;
                Gtk.show_uri(null, newUri, Gdk.CURRENT_TIME); 
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
        loadUser(userList.nth(0).data.id, userList.nth(0).data);
        return 0;
    }

    public int loadTag(string tagName)
    {
        Idle.add(() => {
            stubLoading();
            switchWindow("tagFeed");
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
        }
        catch (Error e)
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }



        //tagList.clear();
        //foreach(Tag tagInList in tagListRequested)
        //    tagList.prepend(tagInList);

        tagFeedBox.loadTag(receivedTag);
        tagFeedBox.loadFeed(tagFeedReceived);

        Idle.add(() => {
            box.remove(loadingImage);
            box.pack_start(stack, true, true); 
            this.stack.show_all();
            return false;
        });
        
        return 0;
    }

    public int searchTag(string tag)
    {

        Idle.add(() => {
            stubLoading();
            switchWindow("tags");
            return false;
        });
        string response = searchTags(tag);
        List<Tag> tagListRequested = new List<Tag>();

        try
        {
            tagListRequested = parseTagList(response);

        }
        catch (Error e) // wrong token
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }

        tagList.clear();
        foreach(Tag tagInList in tagListRequested)
            tagList.prepend(tagInList);

        Idle.add(() => {
            box.remove(loadingImage);
            box.pack_start(stack, true, true); 
            this.stack.show_all();
            return false;
        });
        
        return 0;
    }

    public int loadComments(string postId)
    {
        Idle.add(() => {
            stubLoading();
            switchWindow("comments");
            return false;
        });
        string response = getComments(postId);
        List<Comment> commentsListRequested = new List<Comment>();

        try
        {
            commentsListRequested = parseComments(response);

        }
        catch (Error e) // wrong token
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }

        commentsList.clear();
        foreach(Comment comment in commentsListRequested)
        {
            commentsList.prepend(comment, true);
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

        Idle.add(() => {
            box.remove(loadingImage);
            box.pack_start(stack, true, true); 
            return false;
        });
        
        return 0;
    }


    public int loadUsers(string postId, string type)
    {
        Idle.add(() => {
            stubLoading();
            switchWindow("userList");
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
        
            box.remove(loadingImage);
            box.pack_start(stack, true, true); 
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
            switchWindow("user");
            return false;
        });

        if (userWindowBox.user != null &&userWindowBox.user.id == id) // if user is already loaded, just open the user tab and return. no need to load.
        {
            Idle.add(() => {
                box.remove(loadingImage);
                box.pack_start(stack, true, true); 
                return false;
            });
            return 0;
        }

        string userInfo = getUserInfo(id);
        string relationshipInfo = getUsersRelationship(id);
        User user = new User();
        bool isPrivate = false;
        Relationship relationship = null;

        try
        {
            relationship = parseRelationship(relationshipInfo);
            user = parseUser(userInfo);            
            user.relationship = relationship;
        }
        catch (Error e) // wrong token
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

                box.remove(loadingImage);
                box.pack_start(stack, true, true); 
                this.userWindowBox.userFeed.moreButton.clicked.connect(() => {
                    new Thread<int>("", loadOlderUserFeed);
                });
                return false;
            });
            return 0;
        }

        // if we got here, user it not private (aparently).

        string userFeed = getUserMedia(id);        
        List<MediaInfo> userFeedList = new List<MediaInfo>();        

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

            userWindowBox.loadFeed(userFeedList);
            userWindowBox.load(user);

            foreach (PostBox postBox in userWindowBox.userFeed.boxes)
                connectPostBoxHandlers(postBox);

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

    protected override void shutdown () 
    {
        base.shutdown();
    }

    public int loadFeed()
    {
        loadSelfInfo();
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
        feedButton.set_sensitive (false);
        centered_toolbar.add (feedButton);        

        exploreButton = new Gtk.ToggleToolButton ();
        exploreButton.set_icon_widget (new Gtk.Image.from_icon_name ("midori", Gtk.IconSize.LARGE_TOOLBAR));
        exploreButton.set_tooltip_text ("Explore");
        exploreButton.set_label ("Explore");
        exploreButton.set_sensitive (false);
        centered_toolbar.add (exploreButton);

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

        header.set_custom_title (centered_toolbar);
    }

    public void setHeaderCallbacks()
    {
        if (headersCallbacksSet)
            return;

        feedButton.set_sensitive (true);
        exploreButton.set_sensitive (true);
        photoButton.set_sensitive (true);
        newsButton.set_sensitive (true);
        userButton.set_sensitive (true);

        feedButton.clicked.connect(() => {
            switchWindow("userFeed");
            uncheckButtonsExcept("feed");
        });

        exploreButton.clicked.connect(() => {
            uncheckButtonsExcept("explore");
        });

        photoButton.clicked.connect(() => {
            uncheckButtonsExcept("photo");
        });

        newsButton.clicked.connect(() => {
            uncheckButtonsExcept("news");
        });        

        userButton.clicked.connect(() => {
            uncheckButtonsExcept("self");
            //print("1\n");
            new Thread<int>("", () => {
                loadUser(selfUser.id);
                return 0;
            });            
        });

        headersCallbacksSet = true;
    }

    public void uncheckButtonsExcept(string notUncheck)
    {
        //feedButton.active = (notUncheck == "feed");
        //userButton.active = (notUncheck == "self");
        //photoButton.active = (notUncheck == "photo");
        //exploreButton.active = (notUncheck == "explore");
        //newsButton.active = (notUncheck == "news");
    }

    public int setFeedWidgets()
    {   
        print("loadFeed start.\n");     
        Idle.add(() => { 

            setHeaderCallbacks();

            if (this.feedList.olderFeedLink != "")
                this.feedList.addMoreButton();         

            foreach (MediaInfo post in feedPosts)
                if (!feedList.contains(post)) 
                    feedList.prepend(post);
                       

            new Thread<int>("", loadImages);

            foreach(PostBox postBox in this.feedList.boxes)
                connectPostBoxHandlers(postBox);

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
        if (postBox.post.location != null 
            && postBox.post.location.latitude == 0 
            && postBox.post.location.longitude == 0 
            && postBox.post.location.name == "") // sometimes location contains only ID, for such cases
            new Thread<int>("", () => {
                loadMissingLocation(postBox, postBox.post.location.id);
                return 0;
            });
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