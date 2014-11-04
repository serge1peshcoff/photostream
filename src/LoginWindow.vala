using Gtk;
using WebKit;

public class PhotoStream.LoginWindow : Gtk.ApplicationWindow
{

	private WebView web_view;
	private const string INSTAGRAM_LOGIN = "https://instagram.com/accounts/login/";
	private const string INSTAGRAM_AUTH = "https://api.instagram.com/oauth/authorize/?client_id="
											 + PhotoStream.App.CLIENT_ID 
											 + "&redirect_uri="
											 + PhotoStream.App.REDIRECT_URI
											 + "&response_type=code";

	public LoginWindow () 
	{
		this.web_view = new WebKit.WebView ();
		this.title = "Hello World!";
		stdout.printf ("Hi!\n");

		Thread<int> thread = new Thread<int>.try("", (ThreadFunc)this.load);		

		var scrolled_window = new ScrolledWindow (null, null);
		scrolled_window.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scrolled_window.add (this.web_view);

        var vbox = new VBox (false, 0);
        vbox.add (scrolled_window);
        add (vbox);        

        

        this.web_view.open(INSTAGRAM_AUTH);

	}

	int load()
	{
		this.web_view.load_committed.connect ((source, frame) => {
            stdout.printf(frame.get_uri ());
        });		

		return 0;
	}
}