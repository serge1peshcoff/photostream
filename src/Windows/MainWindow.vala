public class PhotoStream.MainWindow : Gtk.ApplicationWindow
{  
	public MainWindow () 
	{		    		
		this.set_title ("PhotoStream");		

        this.set_default_size (625, 700);
        this.set_size_request (625, 700);  
        
        //this.set_resizable(false);

	}    
    public override bool delete_event(Gdk.EventAny event)
    {
        this.hide();
        PhotoStream.App.isMainWindowShown = false;
        return true;
    }  
}