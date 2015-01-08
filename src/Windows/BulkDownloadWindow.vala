using PhotoStream.Utils;

public class PhotoStream.BulkDownloadWindow : Gtk.Window
{
	public Gtk.Box box;
	public Gtk.Label statusLabel;
	public Gtk.ProgressBar progressBar;

	public Gtk.Grid settingsGrid; 

	public Gtk.Label saveFolderLabel;
	public Gtk.Entry saveFolderEntry;
	public Gtk.Button saveFolderButton;

	public Gtk.CheckButton useSavePattern;
	public Gtk.Entry savePatternEntry;

	public Gtk.Label postsTypeLabel;
	public Gtk.Box radioBox;
	public Gtk.RadioButton allPosts;
	public Gtk.RadioButton onlyImages;
	public Gtk.RadioButton onlyVideos;

	public Gtk.Label patternExplanation;

	public Gtk.Button downloadPostsButton;

	public Gtk.Alignment gridAlignment;
	public Gtk.Alignment statusAlignment;
	public Gtk.Alignment progressBarAlignment;

	private List<MediaInfo> posts;

	public string id;
	private string selectedFolder;
	private string savedPostsType = "all";

	public BulkDownloadWindow(string id)
	{
        this.set_resizable(false);

        selectedFolder = Environment.get_home_dir() + "/";

        this.box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

		this.id = id;

		this.settingsGrid = new Gtk.Grid();
		this.settingsGrid.set_row_spacing(6);
		this.settingsGrid.set_column_spacing(6);

		this.saveFolderLabel = new Gtk.Label("Save folder:");
		this.saveFolderLabel.set_halign(Gtk.Align.END);

		this.saveFolderEntry = new Gtk.Entry();
		this.saveFolderEntry.set_text(selectedFolder);
		this.saveFolderEntry.set_size_request(400, -1);

		this.saveFolderButton = new Gtk.Button.from_icon_name("document-open", Gtk.IconSize.BUTTON);

		this.useSavePattern = new Gtk.CheckButton.with_label("Use filename pattern:");
		this.useSavePattern.set_active(false);		

		this.savePatternEntry = new Gtk.Entry();
		this.savePatternEntry.set_sensitive(false);
		this.savePatternEntry.set_text("%d%.%m%.%y% %title%");

		this.postsTypeLabel = new Gtk.Label("Posts type:");
		this.postsTypeLabel.set_halign(Gtk.Align.END);

		this.radioBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

		this.allPosts = new Gtk.RadioButton.with_label_from_widget(null, "All");
		this.allPosts.toggled.connect(toggleSavedType);
		this.radioBox.add(allPosts);

		this.onlyImages = new Gtk.RadioButton.with_label_from_widget(allPosts, "Images only");
		this.onlyImages.toggled.connect(toggleSavedType);
		this.radioBox.add(onlyImages);

		this.onlyVideos = new Gtk.RadioButton.with_label_from_widget(allPosts, "Videos only");
		this.onlyVideos.toggled.connect(toggleSavedType);
		this.radioBox.add(onlyVideos);

		var patternString = "<i>Pattern format:</i>
%y% - year, %m% - month, %d% - day, %h% - hour, %m% - minute, %s% - second.
%title% - post title (post doesn't have to have a title).
%user% - posted user.
%number% - post number.
";

		this.patternExplanation = new Gtk.Label("");
		this.patternExplanation.set_markup(patternString);
		this.patternExplanation.set_halign(Gtk.Align.START);
		this.patternExplanation.xalign = 0;

		this.downloadPostsButton = new Gtk.Button.with_label("Download...");

		this.settingsGrid.attach(saveFolderLabel, 0, 0, 1, 1);
		this.settingsGrid.attach(saveFolderEntry, 1, 0, 1, 1);
		this.settingsGrid.attach(saveFolderButton, 2, 0, 1, 1);
		this.settingsGrid.attach(postsTypeLabel, 0, 1, 1, 1);
		this.settingsGrid.attach(radioBox, 1, 1, 1, 1);
		this.settingsGrid.attach(useSavePattern, 0, 2, 1, 1);
		this.settingsGrid.attach(savePatternEntry, 1, 2, 1, 1);
		this.settingsGrid.attach(patternExplanation, 0, 3, 2, 1);
		this.settingsGrid.attach(downloadPostsButton, 0, 4, 3, 1);

		this.gridAlignment = new Gtk.Alignment (1,0,1,1);
        this.gridAlignment.top_padding = 6;
        this.gridAlignment.right_padding = 6;
        this.gridAlignment.bottom_padding = 6;
        this.gridAlignment.left_padding = 6;

       	this.gridAlignment.add(settingsGrid);
		this.box.pack_start(gridAlignment, true, false);

		this.statusAlignment = new Gtk.Alignment (1,0,1,1);
        this.statusAlignment.top_padding = 6;
        this.statusAlignment.right_padding = 6;
        this.statusAlignment.bottom_padding = 6;
        this.statusAlignment.left_padding = 6;

        this.progressBarAlignment = new Gtk.Alignment (1,0,1,1);
        this.progressBarAlignment.top_padding = 6;
        this.progressBarAlignment.right_padding = 6;
        this.progressBarAlignment.bottom_padding = 0;
        this.progressBarAlignment.left_padding = 6;
        
        this.progressBar = new Gtk.ProgressBar();
        this.statusLabel = new Gtk.Label("Doing nothing");
        this.statusLabel.set_halign(Gtk.Align.START);

        this.statusAlignment.add(statusLabel);
        this.progressBarAlignment.add(this.progressBar);
        
        this.box.add(progressBarAlignment);
        this.box.add(statusAlignment);

        this.add(box);

        this.saveFolderButton.clicked.connect(() => {
        	var fileChooser = new Gtk.FileChooserDialog ("Select folder to save media posts...", this,
	                                      Gtk.FileChooserAction.SELECT_FOLDER,
	                                      "Cancel", Gtk.ResponseType.CANCEL,
	                                      "Open", Gtk.ResponseType.ACCEPT);
	        if (fileChooser.run () == Gtk.ResponseType.ACCEPT)
        		selectedFolder = fileChooser.get_filename() + "/";

        	fileChooser.destroy (); 

        	this.saveFolderEntry.set_text(selectedFolder);

        });
        this.useSavePattern.toggled.connect(() => {
        	this.savePatternEntry.set_sensitive(this.useSavePattern.get_active());
        });
        this.downloadPostsButton.clicked.connect(() => {
        	this.saveFolderEntry.set_sensitive(false);
        	this.saveFolderButton.set_sensitive(false);
        	this.useSavePattern.set_sensitive(false);
        	this.allPosts.set_sensitive(false);
        	this.onlyImages.set_sensitive(false);
        	this.onlyVideos.set_sensitive(false);

        	posts = new List<MediaInfo>();

	        new Thread<int>("", () => {
	        	getAllPosts();
	        	return 0;
	        });
        });
	}

	private void toggleSavedType(Gtk.ToggleButton button)
	{
		if (!button.get_active())
			return;
		switch (button.label)
		{
			case "All":
				savedPostsType = "all";
				break;
			case "Images only":
				savedPostsType = "images";
				break;
			case "Videos only":
				savedPostsType = "videos";
				break;
			default:
				error("Should've not reach here: %s.", button.label);
		}
	}

	private void getAllPosts()
	{
		string pagination = "null";
		do
		{
			List<MediaInfo> newPosts;
			try 
			{
				string response;
				if (pagination == "null")
					response = getUserMedia(id);
				else
					response = getResponse(pagination);

				pagination = parsePagination(response);
				newPosts = parseFeed(response);

				posts.concat((owned)newPosts);
				Idle.add(() => {
					statusLabel.set_text("Getting user posts (already got %s)...".printf(posts.length().to_string()));
					progressBar.pulse();
					return false;
				});
			}
			catch (Error e)
			{
				error("Something wrong with JSON parsing: %s.", e.message);
			}
		}
		while (pagination != "");
		downloadPosts();
	} 

	private void downloadPosts()
	{
		foreach (MediaInfo post in posts)
		{
			bool isDownloaded = true;
			if ((post.type == PhotoStream.MediaType.VIDEO && savedPostsType == "images")
				|| (post.type == PhotoStream.MediaType.IMAGE && savedPostsType == "videos"))
				isDownloaded = false;

			string fileName;

			if (!useSavePattern.get_active())
				fileName = getFileName(post.media.url);
			else
			{
				fileName = savePatternEntry.get_text();

				var dateTime = post.creationTime;
				fileName = fileName.replace("%y%", dateTime.get_year().to_string());
				fileName = fileName.replace("%m%", dateTime.get_month().to_string());
				fileName = fileName.replace("%d%", dateTime.get_day_of_month().to_string());
				fileName = fileName.replace("%h%", dateTime.get_hour().to_string());
				fileName = fileName.replace("%m%", dateTime.get_minute().to_string());
				fileName = fileName.replace("%s%", dateTime.get_second().to_string());

				fileName = fileName.replace("%title%", post.title);
				fileName = fileName.replace("%user%", post.postedUser.username);
				fileName = fileName.replace("%number%", (posts.index(post) + 1).to_string());

				if (fileName.length >= 255 - 4)
					fileName = fileName.substring(0, 255 - 4); // - ".jpg"

				fileName += ".jpg";
			}


			if (isDownloaded)
			{
				try
				{
					downloadFile(post.media.url, selectedFolder + fileName);
				}
				catch (Error e)
				{
					error("Something wrong with downloading: %s.", e.message);
				}
			}
			Idle.add(() => {
				statusLabel.set_text("%s post %d of %s...".printf(isDownloaded ? "Downloading" : "Skipped", 
					posts.index(post) + 1, 
					posts.length().to_string()));

				progressBar.set_fraction((double)(posts.index(post) + 1) / posts.length());
				return false;
			});
		}
		Idle.add(() => {
			statusLabel.set_text("All files successfully downloaded.");
			progressBar.set_fraction(1);

			this.destroy();
			return false;
		});
	}
}