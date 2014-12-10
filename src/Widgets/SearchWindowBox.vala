using PhotoStream.Utils;

public class PhotoStream.Widgets.SearchWindowBox: Gtk.Box
{
	public Gtk.Entry searchQuery;
	public Gtk.Stack stack;

	public Gtk.RadioButton tagsRadio;
	public Gtk.RadioButton usersRadio;
	public Gtk.RadioButton locationsRadio;

	public Gtk.ScrolledWindow tagsWindow;
	public Gtk.ScrolledWindow usersWindow;
	public Gtk.ScrolledWindow locationWindow;

	public Gtk.Spinner spinner;

	public Gtk.Box radioBox;

	public HashTagList tagList;
	public UserList userList;
	public LocationMapWindow locationMapWindow;

	public string currentWindow = "tags";
	public string tagsRequest = "";
	public string usersRequest = "";

	public SearchWindowBox()
	{
		GLib.Object (orientation: Gtk.Orientation.VERTICAL);

		this.searchQuery = new Gtk.Entry();

		this.radioBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);		

		this.tagsRadio = new Gtk.RadioButton.with_label_from_widget(null, "Hashtags");
		this.usersRadio = new Gtk.RadioButton.with_label_from_widget(tagsRadio, "Users");
		this.locationsRadio = new Gtk.RadioButton.with_label_from_widget(tagsRadio, "Locations");

		this.radioBox.add(tagsRadio);
		this.radioBox.add(usersRadio);
		this.radioBox.add(locationsRadio);		

		this.stack = new Gtk.Stack();

		this.tagList = new HashTagList();
		this.stack.add_named(tagList, "tags");

		this.userList = new UserList();
		this.stack.add_named(userList, "users");

		this.tagsRadio.toggled.connect(switchView);
		this.usersRadio.toggled.connect(switchView);
		this.locationsRadio.toggled.connect(switchView);

		this.searchQuery.activate.connect(() => {
			this.typed();
		});

		spinner = new Gtk.Spinner();
		spinner.start();

		this.stack.add_named(spinner, "loading");

		locationMapWindow = new LocationMapWindow();
	}

	public void addFields()
	{
		// don't know why, but if the pack_start of searchQuery is called in preloadWindows, 
		// window doesn't show. so, this is why I'm doing it in separate function. 
		// and this function is called in setFeedWidgets.
		this.pack_start(searchQuery, false, true);
		this.add(radioBox);
		this.pack_end(stack, true, true);
	}

	private void switchView (Gtk.ToggleButton button) 
	{
		switch (button.label)
		{
			case "Hashtags":
				if (currentWindow != "users")
					return;

				if (tagsRequest != usersRequest)
				{
					searchTag(usersRequest);
					tagsRequest = usersRequest;
				}
				else
					stack.set_visible_child_name("tags");
				currentWindow = "tags";
				break;
			case "Users":
				if (currentWindow != "tags")
					return;

				if (tagsRequest != usersRequest)
				{
					searchUser(tagsRequest);
					usersRequest = tagsRequest;
				}
				else
					stack.set_visible_child_name("users");
				currentWindow = "users";
				break;
			case "Locations":
				currentWindow = "locations";
				openSearchLocation();
				break;
			default:
				error("Should've not reached here.");
		}
	}

	public void typed()
	{
		if (currentWindow == "tags")
		{
			string hashtagSearch = searchQuery.get_text().strip();
			if (hashtagSearch[0] == '#')
				hashtagSearch = hashtagSearch.substring(1, hashtagSearch.length - 1);

			new Thread<int>("", () => {
				searchTag(hashtagSearch);				
				return 0;
			});
			tagsRequest = hashtagSearch;
		}
		else if (currentWindow == "users")
		{
			string usernameSearch = searchQuery.get_text().strip();
			if (usernameSearch[0] == '@')
				usernameSearch = usernameSearch.substring(1, usernameSearch.length - 1);

			new Thread<int>("", () => {
				searchUser(usernameSearch);				
				return 0;
			});
			usersRequest = usernameSearch;
		}
	}

	public void openSearchLocation()
	{
		locationMapWindow.show_all();
	}

	public int searchTag(string tag)
    {

        Idle.add(() => {
            stack.set_visible_child_name("loading");
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

        Idle.add(() => { 
        	tagList.clear();
	        foreach(Tag tagInList in tagListRequested)
	            tagList.prepend(tagInList);  	
            
            stack.set_visible_child_name("tags");
            this.show_all();
            return false;
        });
        
        return 0;
    }
    public int searchUser(string username)
    {

        Idle.add(() => {
            stack.set_visible_child_name("loading");
            return false;
        });
        string response = searchUsers(username);
        List<User> userListRequested = new List<User>();

        try
        {
            userListRequested = parseUserList(response);

        }
        catch (Error e) // wrong token
        {
            error("Something wrong with parsing: " + e.message + ".\n");
        }

        

        Idle.add(() => {
        	userList.clear();
	        foreach(User userInList in userListRequested)
	            userList.prepend(userInList);

	        new Thread<int>("", () => {                  
	            foreach(UserBox userBox in userList.boxes)
	                userBox.loadAvatar();                    
	            return 0;
	        });
	        new Thread<int>("", () => {                  
	            foreach(UserBox userBox in userList.boxes)
	            {
	            	Relationship usersRelationship;
                    if (userBox.user.id == PhotoStream.App.selfUser.id) // loading self followers
                    	continue;

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

                    userBox.user.relationship = usersRelationship;
                    Idle.add(() => {
                        userBox.loadRelationship();
                        return false;
                    });                 
	            }
	            return 0;
        	}); 

            stack.set_visible_child_name("users"); 
            this.show_all();
            return false;
        });
        
        return 0;
    }
}