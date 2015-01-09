using Gtk;

public class PhotoStream.SettingsWindow : Gtk.Window
{
#if HAVE_GRANITE
	public Granite.Widgets.ThinPaned pane;
	public Granite.Widgets.SourceList sourceList;
	public Granite.Widgets.SourceList.Item editProfileItem;
	public Granite.Widgets.SourceList.Item changePasswordItem;
	public Granite.Widgets.SourceList.Item manageAppsItem;
	public Granite.Widgets.SourceList.Item appSettingsItem;
	public Granite.Widgets.SourceList.Item logOutItem;
#else
	public Gtk.Paned pane;
	public Gtk.Box sourceList;
	public Gtk.Button editProfileItem;
	public Gtk.Button changePasswordItem;
	public Gtk.Button manageAppsItem;
	public Gtk.Button appSettingsItem;
	public Gtk.Button logOutItem;
#endif
	public Gtk.Spinner spinner;

	public Gtk.Stack settingsStack;

	public Gtk.Box editProfileBox;
	public Gtk.Grid settingsGrid;

	public Gtk.Label fullNameLabel;
	public Gtk.Label emailLabel;
	public Gtk.Label usernameLabel;
	public Gtk.Label phoneNumberLabel;
	public Gtk.Label sexLabel;
	public Gtk.Label aboutLabel;
	public Gtk.Label websiteLabel;
	public Gtk.Label recommendLabel;

	public Gtk.Alignment fullNameLabelAlignment;
	public Gtk.Alignment emailLabelAlignment;
	public Gtk.Alignment usernameLabelAlignment;
	public Gtk.Alignment phoneNumberLabelAlignment;
	public Gtk.Alignment sexLabelAlignment;
	public Gtk.Alignment aboutLabelAlignment;
	public Gtk.Alignment websiteLabelAlignment;
	public Gtk.Alignment recommendLabelAlignment;

	public Gtk.Entry fullName;
	public Gtk.Entry email;
	public Gtk.Entry username;
	public Gtk.Entry phoneNumber;
	public Gtk.ComboBox sex;
	public Gtk.TextView about;
	public Gtk.Entry website;
	public Gtk.CheckButton recommend; 
	public Gtk.Button sumbitSettingsButton;

	public Gtk.Alignment fullNameAlignment;
	public Gtk.Alignment emailAlignment;
	public Gtk.Alignment usernameAlignment;
	public Gtk.Alignment phoneNumberAlignment;
	public Gtk.Alignment sexAlignment;
	public Gtk.Alignment aboutAlignment;
	public Gtk.Alignment websiteAlignment;
	public Gtk.Alignment recommendAlignment;

	public Gtk.Box appSettingsBox;
	public Gtk.Label cacheSpaceLabel;
	public Gtk.Button clearCacheButton;

	public Gtk.Alignment cacheSpaceLabelAlignment;
	public Gtk.Alignment clearCacheButtonAlignment;

	private int64 cacheElementsCount = 0;

	public SettingsWindow () 
	{
		this.set_title("Settings");

		this.set_default_size (800, 700);
        this.set_size_request (800, 700);
		this.resizable = false;	

		this.settingsStack = new Gtk.Stack();

#if HAVE_GRANITE 
		this.editProfileItem = new Granite.Widgets.SourceList.Item("Profile Settings");
		this.changePasswordItem = new Granite.Widgets.SourceList.Item("Change password");
		this.manageAppsItem = new Granite.Widgets.SourceList.Item("Manage applications");
		this.appSettingsItem = new Granite.Widgets.SourceList.Item("Application settings");
		this.logOutItem = new Granite.Widgets.SourceList.Item("Log out");

		pane = new Granite.Widgets.ThinPaned();
		sourceList = new Granite.Widgets.SourceList();
		var root = sourceList.root;
		root.add(editProfileItem);
		root.add(changePasswordItem);
		root.add(manageAppsItem);
		root.add(appSettingsItem);
		root.add(logOutItem);

		sourceList.set_size_request(150, -1);
		settingsStack.set_size_request(650, -1);
#else
		this.editProfileItem = new Gtk.Button.with_label("Profile Settings");
		this.changePasswordItem = new Gtk.Button.with_label("Change password");
		this.manageAppsItem = new Gtk.Button.with_label("Manage applications");
		this.appSettingsItem = new Gtk.Button.with_label("Application settings");
		this.logOutItem = new Gtk.Button.with_label("Log out");

		pane = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
		sourceList = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		sourceList.add(editProfileItem);
		sourceList.add(changePasswordItem);
		sourceList.add(manageAppsItem);
		sourceList.add(appSettingsItem);
		sourceList.add(logOutItem);

		sourceList.set_size_request(150, -1);
		settingsStack.set_size_request(650, -1);
#endif

		pane.pack1 (sourceList, false, false);
		pane.pack2 (settingsStack, true, false);
		this.add(pane);	

		this.editProfileBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		this.settingsGrid = new Gtk.Grid();

		initAlignments();

		this.fullNameLabel = new Gtk.Label("Name");
		this.emailLabel = new Gtk.Label("Email");
		this.usernameLabel = new Gtk.Label("User name");
		this.phoneNumberLabel = new Gtk.Label("Phone number");
		this.sexLabel = new Gtk.Label("Sex");
		this.aboutLabel = new Gtk.Label("About myself");
		this.websiteLabel = new Gtk.Label("Website");
		this.recommendLabel = new Gtk.Label("Simular Account Suggestion");

		fullNameLabelAlignment.add(fullNameLabel);
		emailLabelAlignment.add(emailLabel);
		usernameLabelAlignment.add(usernameLabel);
		phoneNumberLabelAlignment.add(phoneNumberLabel);
		sexLabelAlignment.add(sexLabel);
		aboutLabelAlignment.add(aboutLabel);
		websiteLabelAlignment.add(websiteLabel);
		recommendLabelAlignment.add(recommendLabel);

		this.fullName = new Gtk.Entry();
		this.email = new Gtk.Entry();
		this.username = new Gtk.Entry();
		this.phoneNumber = new Gtk.Entry();

		Gtk.ListStore list_store = new Gtk.ListStore (1, typeof (string));
		Gtk.TreeIter iter;
		list_store.append (out iter);
		list_store.set (iter, 0, "Male");
		list_store.append (out iter);
		list_store.set (iter, 0, "Female");
		list_store.append (out iter);
		list_store.set (iter, 0, "Not specified");
		this.sex = new Gtk.ComboBox.with_model(list_store);
		Gtk.CellRendererText renderer = new Gtk.CellRendererText ();
		sex.pack_start (renderer, true);
		sex.add_attribute (renderer, "text", 0);
		sex.active = 0;

		this.about = new Gtk.TextView();
		this.website = new Gtk.Entry();
		this.recommend = new Gtk.CheckButton();

		Gtk.Allocation allocation;
		this.fullNameLabel.get_allocation(out allocation);
		this.about.set_size_request(650 - allocation.width, 100); // to fill all entries
		this.about.set_editable(true);
		this.about.buffer.changed.connect(() => {
			string[] lines = this.about.buffer.text.split("\n", 6); // 5 lines, all that goes after it is 6th string.
			if (lines.length >= 6)
				lines[5] = "";

			string textJoined = string.joinv("\n", lines);

			if (this.about.buffer.text != textJoined) // to avoid infinite loop
				this.about.buffer.text = textJoined;
		});


		fullNameAlignment.add(fullName);
		emailAlignment.add(email);
		usernameAlignment.add(username);
		phoneNumberAlignment.add(phoneNumber);
		sexAlignment.add(sex);
		aboutAlignment.add(about);
		websiteAlignment.add(website);
		recommendAlignment.add(recommend);

		sumbitSettingsButton = new Gtk.Button.with_label("Submit");
		sumbitSettingsButton.set_sensitive(false);

		this.settingsGrid.attach(fullNameLabelAlignment, 0, 0, 1, 1);
		this.settingsGrid.attach(emailLabelAlignment, 0, 1, 1, 1);
		this.settingsGrid.attach(usernameLabelAlignment, 0, 2, 1, 1);
		this.settingsGrid.attach(phoneNumberLabelAlignment, 0, 3, 1, 1);
		this.settingsGrid.attach(sexLabelAlignment, 0, 4, 1, 1);
		this.settingsGrid.attach(aboutLabelAlignment, 0, 5, 1, 1);
		this.settingsGrid.attach(websiteLabelAlignment, 0, 6, 1, 1);
		this.settingsGrid.attach(recommendLabelAlignment, 0, 7, 1, 1);

		this.settingsGrid.attach(fullNameAlignment, 1, 0, 1, 1);
		this.settingsGrid.attach(emailAlignment, 1, 1, 1, 1);
		this.settingsGrid.attach(usernameAlignment, 1, 2, 1, 1);
		this.settingsGrid.attach(phoneNumberAlignment, 1, 3, 1, 1);
		this.settingsGrid.attach(sexAlignment, 1, 4, 1, 1);
		this.settingsGrid.attach(aboutAlignment, 1, 5, 1, 1);
		this.settingsGrid.attach(websiteAlignment, 1, 6, 1, 1);
		this.settingsGrid.attach(recommendAlignment, 1, 7, 1, 1);
		this.settingsGrid.attach(sumbitSettingsButton, 0, 8, 2, 1);

		this.editProfileBox.pack_start(settingsGrid, true, true);
		this.settingsStack.add_named(editProfileBox, "editProfile");


		this.appSettingsBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

		this.cacheSpaceLabel = new Gtk.Label("Cache space: 0 Kb");
		this.clearCacheButton = new Gtk.Button.with_label("Clear cache...");

		this.cacheSpaceLabelAlignment.add(cacheSpaceLabel);
		this.clearCacheButtonAlignment.add(clearCacheButton);
		this.appSettingsBox.add(cacheSpaceLabelAlignment);
		this.appSettingsBox.add(clearCacheButtonAlignment);

		this.settingsStack.add_named(appSettingsBox, "appSettings");

#if HAVE_GRANITE
		this.sourceList.item_selected.connect((id) => {
			if (id == logOutItem)
				logOutConfirm();
			else if (id == appSettingsItem)
				loadAppSettings();				
			else if (id == editProfileItem)
				settingsStack.set_visible_child_name("editProfile");

		});
#else
		this.logOutItem.clicked.connect(() => {
			logOutConfirm();
		});
		this.appSettingsItem.clicked.connect(() => {
			loadAppSettings();	
		});
		this.appSettingsItem.clicked.connect(() => {
			settingsStack.set_visible_child_name("editProfile");
		});
#endif

		this.clearCacheButton.clicked.connect(clearCache);

		this.spinner = new Gtk.Spinner();
		this.spinner.start();	
		this.settingsStack.add_named(spinner, "loading");

		new Thread<int>("", () => {
			loadSettings();
			return 0;
		});

		this.show_all();
	}

	public void loadSettings()
	{
		Idle.add(() => {
			settingsStack.set_visible_child_name("loading");
        	return false;
        });

		string settings = getUserSettings();
        var settingsParsed = parseSettings(settings);

        Idle.add(() => {
        	this.fullName.set_text(PhotoStream.App.selfUser.fullName);
        	this.username.set_text(PhotoStream.App.selfUser.username);
        	this.about.buffer.text = PhotoStream.App.selfUser.bio;
        	this.website.set_text(PhotoStream.App.selfUser.website);
        	this.email.set_text(settingsParsed.email);
        	this.phoneNumber.set_text(settingsParsed.phoneNumber);
        	if (settingsParsed.sex == "male")
        		this.sex.set_active(0);
        	else if (settingsParsed.sex == "female")
        		this.sex.set_active(1);
        	else if (settingsParsed.sex == "")
        		this.sex.set_active(2);
        	else
        		error("Should've not reached here: %s.", settingsParsed.sex);
        	this.recommend.active = settingsParsed.recommend;

        	this.sumbitSettingsButton.set_sensitive(true);
        	this.sumbitSettingsButton.clicked.connect(() => {
				submitSettingsConfirm();
			});


        	settingsStack.set_visible_child_name("editProfile");
        	return false;
        });
	}

	public void logOutConfirm()
	{
		Gtk.MessageDialog msg = new Gtk.MessageDialog (null, Gtk.DialogFlags.MODAL, 
													Gtk.MessageType.QUESTION, Gtk.ButtonsType.OK_CANCEL, 
													"Are you sure you want to log out?");
		msg.response.connect ((response_id) => {
			bool allowedToLogoff = (response_id == Gtk.ResponseType.OK);

			msg.destroy();

			if (!allowedToLogoff)
				return;
			else
				new Thread<int>("", () => {
	        		logOut();
	        		return 0;
	        	});				
		});
		msg.show ();
	}

	public void logOut()
	{
		setToken("");
		File file = File.new_for_path(PhotoStream.App.CACHE_URL + "cookie.txt"); 
		try
		{
			file.delete();
		}
		catch (Error e)
		{
			error("Something wrong with file removing: %s", e.message);
		}
		this.destroy();
	}

	public void initAlignments()
	{
		this.fullNameLabelAlignment = new Gtk.Alignment (0,0,0,1);
        this.fullNameLabelAlignment.top_padding = 6;
        this.fullNameLabelAlignment.right_padding = 4;
        this.fullNameLabelAlignment.bottom_padding = 6;
        this.fullNameLabelAlignment.left_padding = 6;

        this.emailLabelAlignment = new Gtk.Alignment (0,0,0,1);
        this.emailLabelAlignment.top_padding = 6;
        this.emailLabelAlignment.right_padding = 4;
        this.emailLabelAlignment.bottom_padding = 6;
        this.emailLabelAlignment.left_padding = 6;

        this.usernameLabelAlignment = new Gtk.Alignment (0,0,0,1);
        this.usernameLabelAlignment.top_padding = 6;
        this.usernameLabelAlignment.right_padding = 4;
        this.usernameLabelAlignment.bottom_padding = 6;
        this.usernameLabelAlignment.left_padding = 6;

        this.phoneNumberLabelAlignment = new Gtk.Alignment (0,0,0,1);
        this.phoneNumberLabelAlignment.top_padding = 6;
        this.phoneNumberLabelAlignment.right_padding = 4;
        this.phoneNumberLabelAlignment.bottom_padding = 6;
        this.phoneNumberLabelAlignment.left_padding = 6;

        this.sexLabelAlignment = new Gtk.Alignment (0,0,0,1);
        this.sexLabelAlignment.top_padding = 6;
        this.sexLabelAlignment.right_padding = 4;
        this.sexLabelAlignment.bottom_padding = 6;
        this.sexLabelAlignment.left_padding = 6;

        this.aboutLabelAlignment = new Gtk.Alignment (0,0,0,1);
        this.aboutLabelAlignment.top_padding = 6;
        this.aboutLabelAlignment.right_padding = 4;
        this.aboutLabelAlignment.bottom_padding = 6;
        this.aboutLabelAlignment.left_padding = 6;

        this.websiteLabelAlignment = new Gtk.Alignment (0,0,0,1);
        this.websiteLabelAlignment.top_padding = 6;
        this.websiteLabelAlignment.right_padding = 4;
        this.websiteLabelAlignment.bottom_padding = 6;
        this.websiteLabelAlignment.left_padding = 6;

        this.recommendLabelAlignment = new Gtk.Alignment (0,0,0,1);
        this.recommendLabelAlignment.top_padding = 6;
        this.recommendLabelAlignment.right_padding = 4;
        this.recommendLabelAlignment.bottom_padding = 6;
        this.recommendLabelAlignment.left_padding = 6;





        this.fullNameAlignment = new Gtk.Alignment (0,0,1,1);
        this.fullNameAlignment.right_padding = 4;
        this.fullNameAlignment.left_padding = 6;

        this.emailAlignment = new Gtk.Alignment (0,0,1,1);
        this.emailAlignment.right_padding = 4;
        this.emailAlignment.left_padding = 6;

        this.usernameAlignment = new Gtk.Alignment (0,0,1,1);
        this.usernameAlignment.right_padding = 4;
        this.usernameAlignment.left_padding = 6;

        this.phoneNumberAlignment = new Gtk.Alignment (0,0,1,1);
        this.phoneNumberAlignment.right_padding = 4;
        this.phoneNumberAlignment.left_padding = 6;

        this.sexAlignment = new Gtk.Alignment (0,0,1,1);
        this.sexAlignment.right_padding = 4;
        this.sexAlignment.left_padding = 6;

        this.aboutAlignment = new Gtk.Alignment (0,0,1,1);
        this.aboutAlignment.right_padding = 4;
        this.aboutAlignment.left_padding = 6;

        this.websiteAlignment = new Gtk.Alignment (0,0,1,1);
        this.websiteAlignment.right_padding = 4;
        this.websiteAlignment.left_padding = 6;

        this.recommendAlignment = new Gtk.Alignment (0,0,1,1);
        this.recommendAlignment.right_padding = 4;
        this.recommendAlignment.left_padding = 6;

        this.cacheSpaceLabelAlignment = new Gtk.Alignment (0,0,0,1);
        this.cacheSpaceLabelAlignment.top_padding = 6;
        this.cacheSpaceLabelAlignment.right_padding = 4;
        this.cacheSpaceLabelAlignment.bottom_padding = 6;
        this.cacheSpaceLabelAlignment.left_padding = 6;

        this.clearCacheButtonAlignment = new Gtk.Alignment (0,0,0,1);
        this.clearCacheButtonAlignment.top_padding = 6;
        this.clearCacheButtonAlignment.right_padding = 4;
        this.clearCacheButtonAlignment.bottom_padding = 6;
        this.clearCacheButtonAlignment.left_padding = 6;
	}

	public void submitSettingsConfirm()
	{
		PhotoStream.Utils.Settings settings = new PhotoStream.Utils.Settings();
		settings.email = this.email.get_text();
		settings.phoneNumber = this.phoneNumber.get_text();
		switch (this.sex.get_active())
		{
			case 0:
				settings.sex = "male";
				break;
			case 1:
				settings.sex = "female";
				break;
			case 2:
				settings.sex = "";
				break;
			default:
				error("Should've not reached here: %d", this.sex.get_active());
		}
		settings.recommend = this.recommend.active;

		PhotoStream.Utils.User user = new PhotoStream.Utils.User();
		user.fullName = this.fullName.get_text();
		user.username = this.username.get_text();
		user.bio = this.about.buffer.text;
		user.website = this.website.get_text();

		Gtk.MessageDialog msg = new Gtk.MessageDialog (this, Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.OK, "");
		msg.response.connect ((response_id) => {
			msg.destroy();
		});

		Regex emailRegex;
        try
        {
           emailRegex = new Regex("([a-zA-Z0-9_-])+@([a-zA-Z0-9_-]+\\.)+([a-zA-Z]{2,6})");
        } 
        catch (Error e)
        {
            error("Something wrong with regexes: %s", e.message);
        }
        if (!emailRegex.match(settings.email) || settings.email == "")
        {
        	msg.text = "Wrong email format.";
        	msg.show ();
        	return;
        }

        Regex phoneNumberRegex;
        try
        {
           phoneNumberRegex = new Regex("(\\+).[0-9 -]+");
        } 
        catch (Error e)
        {
            error("Something wrong with regexes: %s", e.message);
        }
        if (!phoneNumberRegex.match(settings.phoneNumber))
        {
        	msg.text = "Wrong phone number format.";
        	msg.show ();
        	return;
        }

        if (user.username == "")
        {
        	msg.text = "Username should not be empty.";
        	msg.show ();
        	return;
        }

        new Thread<int>("", () => {
        	submitSettingsReally(user, settings);
        	return 0;
        });        

	}

	public void loadAppSettings()
	{
		settingsStack.set_visible_child_name("appSettings");

		cacheElementsCount = 0;
		double size = getSize(PhotoStream.App.CACHE_URL);
		string measureUnit = "bytes";
		if (size > 1024)
		{
			size /= 1024;
			measureUnit = "Kb";
		}
		if (size > 1024)
		{
			size /= 1024;
			measureUnit = "Mb";
		}
		if (size > 1024)
		{
			size /= 1024;
			measureUnit = "Gb";
		}

        cacheSpaceLabel.set_text("Cache space: %4.2f %s (%lld elements)".printf(size, measureUnit, cacheElementsCount));
	}

	private double getSize(string filename)
	{
		double sum = 0;
		try 
		{
			var directory = File.new_for_path(filename);
	        var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME 
	        												+ "," 
	        												+ FileAttribute.STANDARD_SIZE, 0);

	        FileInfo file_info;
	        while ((file_info = enumerator.next_file ()) != null) 
	        {
	        	if (file_info.get_file_type () == FileType.DIRECTORY)
	        		sum += getSize(filename + file_info.get_name() + "/");
				else
	        		if (file_info.get_name() != "cookie.txt")
	        		{
	            		sum += (double)file_info.get_size();
	            		cacheElementsCount++;
	        		}
	        }
	    } 
	    catch (Error e) 
	    {
	        error("Error: %s\n", e.message);
	    }
	    return sum;
	}

	public void clearCache()
	{
        removeAllFiles(PhotoStream.App.CACHE_URL);

        cacheElementsCount = 0;
        loadAppSettings();
	}

	private void removeAllFiles(string filename)
	{
		try 
		{
			var directory = File.new_for_path(filename);
	        var enumerator = directory.enumerate_children (FileAttribute.STANDARD_EDIT_NAME, 0);
	        FileInfo file_info;
	        while ((file_info = enumerator.next_file ()) != null) 
	        {
	        	if (file_info.get_file_type () == FileType.DIRECTORY)
	        	{
	        		removeAllFiles(filename + file_info.get_name() + "/");
	        	}
				else
	        		if (file_info.get_name() != "cookie.txt")
	        		{
	        			try
	        			{
	        				File fileToRemove = File.new_for_path(filename + file_info.get_edit_name());
	        				fileToRemove.delete();
	        			}
	        			catch (Error e)
	        			{
	        				error("Error removing file: %s.", e.message);
	        			}	        			          	
	        		}
	        }
	    } 
	    catch (Error e) 
	    {
	        error("Error: %s\n", e.message);
	    }
	}

	public void submitSettingsReally(PhotoStream.Utils.User user, PhotoStream.Utils.Settings settings)
	{
		string response = postSettings(settings, user);
		print(response);
	}
}