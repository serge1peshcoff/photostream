public class PhotoStream.App : Granite.Application 
{

	public static MainWindow mainWindow;
    public static string appToken = "1528631860.1fb234f.e72be2d22ad444d594026ac9e4012cf7";

	protected override void activate () 
	{       
        mainWindow = new MainWindow ();

        mainWindow.title = "Hello World!";

        
        mainWindow.show_all ();
        mainWindow.destroy.connect (Gtk.main_quit);

        string responce = getResponce("https://api.instagram.com/v1/users/self/media/liked?access_token=" + appToken);
        print(responce);
        //stdout.printf("yay");
        Gtk.main ();
        print("Yaa");
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