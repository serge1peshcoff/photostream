using PhotoStream.Utils;

public class PhotoStream.Widgets.UserList : Gtk.Box
{
	public GLib.List<UserBox> boxes;
	public Gtk.Button moreButton;
	public string olderUsersLink;

	public Gtk.ScrolledWindow userListWindow;
	public Gtk.ListBox userList;

	public PhotoStream.App app;

	public UserList()
	{
		boxes = new GLib.List<UserBox>();
		this.moreButton = new Gtk.Button.with_label("Load more...");

		this.userListWindow = new Gtk.ScrolledWindow(null, null);
		this.userListWindow.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.ALWAYS);		

		this.userList = new Gtk.ListBox();
		this.userListWindow.add_with_viewport(userList);
		this.pack_start(userListWindow, true, true);

		this.userList.set_selection_mode (Gtk.SelectionMode.NONE);
		this.userList.activate_on_single_click = false;

		this.realize.connect(() => {
			var window = (Gtk.Window)this.get_toplevel();
			app = (PhotoStream.App) window.get_application();
		});
	}
	public void addMoreButton()
	{
		if(!this.moreButton.is_ancestor(this))
			userList.prepend(this.moreButton);
	}
	public void deleteMoreButton()
	{
		if(this.moreButton.is_ancestor(this))
			this.userList.remove(this.get_children().last().data);
	}
	public bool contains(User user)
	{
		foreach(UserBox box in boxes)
			if(box.user.id == user.id)
				return true;

		return false;
	}

	public void loadUsers(string response, string type)
	{	
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
        	this.loadUsersFromList(likees, type);
        	return false;
        });
	}

	public void loadUsersFromList(List<User> userList, string type)
	{
		this.clear();

		if (userList.length() == 0)
		{
			stubEmptyList();
			return;
		}
		else if (!this.userList.is_ancestor(this))
		{
			if (this.get_children().length() != 0)
				this.remove(this.get_children().first().data);
			this.pack_start(this.userListWindow, true, true);
		}

        foreach(User user in userList)
            this.prepend(user);

        new Thread<int>("", () => {                  
            foreach(UserBox userBox in this.boxes)
                userBox.loadAvatar();                    
            return 0;
        });     

        foreach(UserBox userBox in this.boxes)
        {
            userBox.userNameLabel.activate_link.connect(app.handleUris);
            userBox.avatarBox.button_release_event.connect(() => {
                new Thread<int>("", () => {
                    app.loadUser(userBox.user.id, userBox.user);
                    return 0;
                });
                return false;
            });  
        }              

        foreach(UserBox userBox in this.boxes)
        {
            if (userBox.user.id == PhotoStream.App.selfUser.id)
                continue;

            new Thread<int>("", () => {
                Relationship usersRelationship;
                if (type == "follows" && app.userWindowBox.user.id == PhotoStream.App.selfUser.id) // loading self followers
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
	}

	public void stubEmptyList()
	{
		if (!userListWindow.is_ancestor(this) && this.get_children().length() != 0)
			return;

		EmptyUserList emptyUserList = new EmptyUserList();
		this.remove(userListWindow);
		this.pack_end(emptyUserList, true, true);
		this.show_all();
	}

	public void append(User user)
	{
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		userList.prepend(separator);
		UserBox box = new UserBox(user);
		userList.prepend(box);
		boxes.append(box);		
	}

	public new void prepend(User user)
	{
		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		userList.insert (separator, (int) this.userList.get_children().length () - 1);
		UserBox box = new UserBox(user);
		userList.insert (box, (int) this.userList.get_children().length () - 1);
		boxes.append(box);			
	}

	public void clear()
	{
		foreach (var child in this.userList.get_children())
			this.userList.remove(child);
		this.boxes = new List<UserBox>();

		this.userListWindow.get_vadjustment().set_value(0);
	}
}