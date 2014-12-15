public class PhotoStream.MainWindow : Gtk.ApplicationWindow
{  
      

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
		this.set_title ("PhotoStream");		

        Granite.Widgets.Utils.set_theming_for_screen (this.get_screen (), ELEMENTARY_STYLESHEET,
                                               Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        this.set_default_size (625, 700);
        this.set_size_request (625, 700);  
        
        this.set_resizable(false);

	}    
    public override bool delete_event(Gdk.EventAny event)
    {
        this.hide();
        PhotoStream.App.isMainWindowShown = false;
        return true;
    }  
}