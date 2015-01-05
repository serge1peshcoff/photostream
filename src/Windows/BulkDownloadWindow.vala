using PhotoStream.Utils;

public class PhotoStream.BulkDownloadWindow : Gtk.Window
{
	public Gtk.Box box;
	public Gtk.Label statusLabel;
	public Gtk.ProgressBar progressBar;

	public Gtk.Alignment statusAlignment;
	public Gtk.Alignment progressBarAlignment;

	private List<MediaInfo> posts;

	public string id;
	private string selectedFolder;

	public BulkDownloadWindow(string id)
	{
		this.id = id;

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

        this.box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        this.progressBar = new Gtk.ProgressBar();
        this.statusLabel = new Gtk.Label("Sample text");
        this.statusLabel.set_halign(Gtk.Align.START);

        this.statusAlignment.add(statusLabel);
        this.progressBarAlignment.add(this.progressBar);
        
        this.box.add(progressBarAlignment);
        this.box.add(statusAlignment);

        this.add(box);

        var fileChooser = new Gtk.FileChooserDialog ("Select folder to save media posts...", this,
                                      Gtk.FileChooserAction.SELECT_FOLDER,
                                      "Cancel", Gtk.ResponseType.CANCEL,
                                      "Open", Gtk.ResponseType.ACCEPT);
        if (fileChooser.run () != Gtk.ResponseType.ACCEPT)
            this.destroy();
        else
        	selectedFolder = fileChooser.get_filename() + "/";

        fileChooser.destroy ();

        posts = new List<MediaInfo>();

        new Thread<int>("", () => {
        	getAllPosts();
        	return 0;
        });

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
			try
			{
				downloadFile(post.media.url, selectedFolder + getFileName(post.media.url));
			}
			catch (Error e)
			{
				error("Something wrong with downloading: %s.", e.message);
			}
			Idle.add(() => {
				statusLabel.set_text("Downloading post %d of %s...".printf(posts.index(post) + 1, posts.length().to_string()));
				progressBar.set_fraction((double)(posts.index(post) + 1) / posts.length());
				return false;
			});
		}
		Idle.add(() => {
			statusLabel.set_text("All files successfully downloaded.");
			progressBar.set_fraction(1);
			return false;
		});
	}
}