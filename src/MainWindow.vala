public class PhotoStream.MainWindow : Gtk.ApplicationWindow
{
	public Gtk.HeaderBar header;
	public Gtk.ToolButton homeButton;
	public Gtk.ToolButton photoButton;
	/*private const string ELEMENTARY_STYLESHEET = """
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
         """; */


	public MainWindow () 
	{
		header = new Gtk.HeaderBar ();
		
		this.set_title ("Birdie");
		header.set_show_close_button (true);
        this.set_titlebar (header);

        //Granite.Widgets.Utils.set_theming_for_screen (this.get_screen (), ELEMENTARY_STYLESHEET,
                                               //Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        Gtk.Box centered_toolbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

        this.homeButton = new Gtk.ToggleToolButton ();
        var icon = new Gtk.Image();
        icon.set_from_file("../icons/home24.png");
        this.homeButton.set_icon_widget (icon);
        homeButton.set_tooltip_text ("Home");
        homeButton.set_label ("Home");
        //this.homeButton.set_sensitive (false);
        centered_toolbar.add (homeButton);

        this.photoButton = new Gtk.ToggleToolButton ();
        icon = new Gtk.Image();
        icon.set_from_file("../icons/photo24.png");
        this.photoButton.set_icon_widget (icon);
        photoButton.set_tooltip_text ("Home");
        photoButton.set_label ("Home");
        //this.photoButton.set_sensitive (false);
        centered_toolbar.add (photoButton);

        this.header.set_custom_title (centered_toolbar);

	}
	public override void add (Gtk.Widget w) 
	{
        base.add (w);
	}
}