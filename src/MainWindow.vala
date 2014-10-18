public class PhotoStream.MainWindow : Gtk.ApplicationWindow
{
	public Gtk.HeaderBar header;
	public Gtk.ToolButton newButton; 
	public Gtk.ToolButton newButton2;
	public Gtk.ToolButton newButton3;
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

		var newButton = new Gtk.ToolButton (new Gtk.Image.from_icon_name ("go-home", Gtk.IconSize.LARGE_TOOLBAR), "New Tweet");
        newButton.set_tooltip_text ("New Tweet");
        newButton.set_sensitive (false);
        this.header.pack_start (newButton);

        this.newButton2 = new Gtk.ToolButton (new Gtk.Image.from_icon_name ("folder-new", Gtk.IconSize.LARGE_TOOLBAR), "New Tweet");
        newButton2.set_tooltip_text ("New Tweet");
        newButton2.set_sensitive (false);
        this.header.pack_start (newButton2);

        this.newButton3 = new Gtk.ToolButton (new Gtk.Image.from_icon_name ("folder-new", Gtk.IconSize.LARGE_TOOLBAR), "New Tweet");
        newButton3.set_tooltip_text ("New Tweet");
        newButton3.set_sensitive (false);
        this.header.pack_end (newButton3);
	}
	public override void add (Gtk.Widget w) 
	{
        base.add (w);
	}
}