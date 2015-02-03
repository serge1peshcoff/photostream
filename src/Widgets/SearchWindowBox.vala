using PhotoStream.Utils;

public class PhotoStream.Widgets.SearchWindowBox: Gtk.Box
{
	public signal void usersLoaded();
	public signal void userRelationshipLoaded(UserBox box);
	public signal void userAvatarLoaded(UserBox box);
	public signal void tagsLoaded();

	public Gtk.Entry searchQuery;
	public Gtk.Stack stack;
	public Gtk.StackSwitcher stackSwitcher;
	public Gtk.Box switcherBox;
	public Gtk.Button locationButton;

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

	public bool isInitialized = false;

	public SearchWindowBox()
	{
		GLib.Object (orientation: Gtk.Orientation.VERTICAL);

		var rgba = Gdk.RGBA();
		rgba.red = 1;
		rgba.green = 1;
		rgba.blue = 1;
		rgba.alpha = 1;
		this.override_background_color(Gtk.StateFlags.NORMAL, rgba);

		this.searchQuery = new Gtk.Entry();	

		this.stack = new Gtk.Stack();

		stackSwitcher = new Gtk.StackSwitcher();
		stackSwitcher.set_stack(stack);
		stackSwitcher.set_homogeneous(true);
		stackSwitcher.hexpand = true;

		this.tagList = new HashTagList();
		this.stack.add_titled(tagList, "tags", "Tags");

		this.userList = new UserList();
		this.stack.add_titled(userList, "users", "Users");

		this.switcherBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);		
		this.locationButton = new Gtk.Button.with_label("Locations");
		this.switcherBox.pack_start(stackSwitcher, true, true);
		this.stackSwitcher.add(locationButton);

		this.searchQuery.activate.connect(() => {
			this.typed();
		});

		spinner = new Gtk.Spinner();
		spinner.set_halign(Gtk.Align.CENTER);
		spinner.start();

		((Gtk.RadioButton)(this.stackSwitcher.get_children().first().data)).toggled.connect((btn) => {
			switchView(btn, "Hashtags");
		});
		((Gtk.RadioButton)(this.stackSwitcher.get_children().nth(1).data)).toggled.connect((btn) => {
			switchView(btn, "Users");
		});
		this.locationButton.clicked.connect(openSearchLocation);

		locationMapWindow = new LocationMapWindow();
		locationMapWindow.destroy_event.connect(() => {
			return true;
		});
	}

	public void addFields()
	{
		// don't know why, but if the pack_start of searchQuery is called in preloadWindows, 
		// window doesn't show. so, this is why I'm doing it in separate function. 
		// and this function is called in setFeedWidgets.
		this.pack_start(searchQuery, false, true);
		this.add(switcherBox);
		this.pack_end(stack, true, true);
	}

	private void switchView (Gtk.ToggleButton button, string label) 
	{		
		if (button.get_active() == false)
			return; // to not execute 2 times, for untoggled and toggled button.

		switch (label)
		{
			case "Hashtags":
				if (currentWindow != "users")
					return;

				if (tagsRequest != usersRequest)
				{
					new Thread<int>("", () => {
						searchTag(usersRequest);				
						return 0;
					});
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
					new Thread<int>("", () => {
						searchUser(tagsRequest);				
						return 0;
					});
					usersRequest = tagsRequest;
				}
				else
					stack.set_visible_child_name("users");
				currentWindow = "users";
				break;
			default:
				error("Should've not reached here: %s.", label);
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
        	if (this.stack.is_ancestor(this))
        	{
	        	this.remove(stack);
	            this.pack_end(spinner, true, true);
	        }
            this.show_all();
            return false;
        });
        string response = searchTags(tag);
        this.tagList.loadTags(response);            

        Idle.add(() => { 
        	tagsRequest = tag;        	 	
            
            this.remove(spinner);
            this.pack_end(stack, true, true);
            this.stack.set_visible_child_name("tags");
            this.show_all();

            tagsLoaded();
            return false;
        });
        
        return 0;
    }
    public int searchUser(string username)
    {

        Idle.add(() => {
            this.remove(stack);
            this.pack_end(spinner, true, true);
            this.show_all();
            return false;
        });

        string response = searchUsers(username);
        this.userList.loadUsers(response, "");  

        Idle.add(() => {

	        usersLoaded();

			this.remove(spinner);
            this.pack_end(stack, true, true);
            this.stack.set_visible_child_name("users"); 
            this.show_all();        
            return false;
        });
        
        return 0;
    }
}