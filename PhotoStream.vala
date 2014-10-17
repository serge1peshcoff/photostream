public class PhotoStream.App : Granite.Application 
{

	public static MainWindow mainWindow;

	protected override void activate () 
	{       
        mainWindow = new MainWindow ();

        mainWindow.title = "Hello World!";

        
        mainWindow.show_all ();

        stdout.printf("yay");
        string responce = getResponce("api.instagram.com");
        print(responce);
        //stdout.printf("yay");
        Gtk.main ();

        //while (Gtk.events_pending ())
                    //Gtk.main_iteration ();

        //mainWindow.present ();

       //return;
       
    }

    protected override void shutdown () 
    {
        stdout.printf ("Bye!\n");
        Gtk.main_quit ();
    }

}
//https://api.instagram.com/oauth/authorize/?client_id=6e7283f612c645a5a22846d79cab54c3&redirect_uri=http://itprogramming1.tk/photostream&response_type=token