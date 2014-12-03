using PhotoStream.Utils;
using Gdk;

public class PhotoStream.Widgets.NewsBox : Gtk.EventBox
{
	public Gtk.Box box;

	public Gtk.Image avatarImage;
	public Gtk.Image postImage;
	public Gtk.Box textBox;
	public Gtk.Label commentLabel;
	public Gtk.Label dateLabel;


	public NewsActivity activity;

	public NewsBox(NewsActivity activity)
	{
		GLib.Object (orientation: Gtk.Orientation.HORIZONTAL);

		this.activity = activity;

		this.textBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		this.add(textBox);

		this.image = new Gtk.Image();
		this.add(image);

		new Thread<int>("", () => {
			this.loadImage;
		});

		this.commentLabel = new Gtk.Label("");
		this.commentLabel.set_markup(wrapInTags(this.activity.comment));
		this.commentLabel.set_line_wrap(true);
		this.commentLabel.wrap_mode = Pango.WrapMode.WORD_CHAR;
		this.dateLabel = new Gtk.Label("");
		this.dateLabel.set_markup(wrapInTags(this.activity.time.format("%e.%m.%Y %H:%M")));

		this.textBox.add(commentLabel);
		this.textBox.add(dateLabel);
    }

    private void loadAvatar()
    {
    	var avatarFileName = PhotoStream.App.CACHE_AVATARS + getFileName(activity.userProfilePicture);
		File file = File.new_for_path(avatarFileName);
        if (!file.query_exists()) // avatar not downloaded, download
        	try
        	{
        		downloadFile(activity.userProfilePicture, avatarFileName);
        	}
        	catch (Error e)
        	{
        		return; // not loading avatar, to fix.
        	}

        Idle.add(() => {
			avatar.set_from_file(avatarFileName);		
			return false;
        });
    }

    private void loadImage()
    {

    }

}