public class PhotoStream.MainWindow : Gtk.ApplicationWindow
{
	public Gtk.HeaderBar header;
	public Gtk.ToggleToolButton feedButton;
    public Gtk.ToggleToolButton exploreButton;
	public Gtk.ToggleToolButton photoButton;
    public Gtk.ToggleToolButton newsButton; 
    public Gtk.ToggleToolButton userButton;
    public PhotoStream.PhotoStack stack;
    public Gtk.ScrolledWindow feedWindow;
    public Gtk.ScrolledWindow userWindow;

    private Gtk.Box box;

	private const string ELEMENTARY_STYLESHEET = """
            .header-bar {
                padding: 0 6px;
            }


            .header-bar .button {
                border-radius: 0;
                padding: 11px 10px;
                border-width: 0 1px 0 1px;
            }

            .header-bar .button.image-button {
                border-radius: 3px;
                padding: 0;
            }


            .titlebar .titlebutton {
                background: none;
                padding: 3px;

                border-radius: 3px;
                border-width: 1px;
                border-color: transparent;
                border-style: solid;
                border-image: none;
            }
         """; 


	public MainWindow () 
	{
		header = new Gtk.HeaderBar ();
		
		this.set_title ("Birdie");
		header.set_show_close_button (true);
        this.set_titlebar (header);

        Granite.Widgets.Utils.set_theming_for_screen (this.get_screen (), ELEMENTARY_STYLESHEET,
                                               Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        this.set_default_size (425, 500);
        this.set_size_request (425, 50);

        Gtk.Box centered_toolbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

        this.feedButton = new Gtk.ToggleToolButton ();
        this.feedButton.set_icon_widget (new Gtk.Image.from_icon_name ("go-home", Gtk.IconSize.LARGE_TOOLBAR));
        feedButton.set_tooltip_text ("Home");
        feedButton.set_label ("Home");
        //this.feedButton.set_sensitive (false);
        centered_toolbar.add (feedButton);

        this.exploreButton = new Gtk.ToggleToolButton ();
        this.exploreButton.set_icon_widget (new Gtk.Image.from_icon_name ("midori", Gtk.IconSize.LARGE_TOOLBAR));
        exploreButton.set_tooltip_text ("Home");
        exploreButton.set_label ("Home");
        //this.exploreButton.set_sensitive (false);
        centered_toolbar.add (exploreButton);

        this.photoButton = new Gtk.ToggleToolButton ();
        this.photoButton.set_icon_widget (new Gtk.Image.from_icon_name ("camera", Gtk.IconSize.LARGE_TOOLBAR));
        photoButton.set_tooltip_text ("Home");
        photoButton.set_label ("Home");
        //this.photoButton.set_sensitive (false);
        centered_toolbar.add (photoButton);

        this.newsButton = new Gtk.ToggleToolButton ();
        this.newsButton.set_icon_widget (new Gtk.Image.from_icon_name ("emblem-synchronizing", Gtk.IconSize.LARGE_TOOLBAR));
        newsButton.set_tooltip_text ("Home");
        newsButton.set_label ("Home");
        //this.newsButton.set_sensitive (false);
        centered_toolbar.add (newsButton);

        this.userButton = new Gtk.ToggleToolButton ();
        this.userButton.set_icon_widget (new Gtk.Image.from_icon_name ("system-users", Gtk.IconSize.LARGE_TOOLBAR));
        userButton.set_tooltip_text ("Home");
        userButton.set_label ("Home");
        //this.userButton.set_sensitive (false);
        centered_toolbar.add (userButton);

        feedButton.toggled.connect(() => 
        {
            this.switchWindow("feed");
        });
        userButton.toggled.connect(() => 
        {
            this.switchWindow("user");
        });

        this.header.set_custom_title (centered_toolbar);

        stack = new PhotoStream.PhotoStack();
        feedWindow = new Gtk.ScrolledWindow (null, null);
        userWindow = new Gtk.ScrolledWindow (null, null);
        stack.add_named(feedWindow, "feed");
        stack.add_named(userWindow, "user");
        stack.set_transition_type(Gtk.StackTransitionType.CROSSFADE);
        stack.set_transition_duration(100);

        box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        box.pack_start(stack, true, true);
        this.add(box);
	}
    public void switchWindow(string window)
    {
        stack.set_visible_child_name(window);
    }
}