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
	private string HOST;

	public LoginWindow () 
	{
		HOST = getHost(PhotoStream.App.REDIRECT_URI);

		this.web_view = new WebKit.WebView ();
		this.title = "Hello World!";
		stdout.printf (INSTAGRAM_AUTH + "\n");

		stdout.printf("%d %d %d\n", WebKit.MAJOR_VERSION, WebKit.MINOR_VERSION, WebKit.MICRO_VERSION);


		this.web_view.load_finished.connect ((source, frame) => {
            var uri = web_view.get_uri ();
            var host = getHost(uri);
            
            if (host == this.HOST)
            {
            	stdout.printf(uri + "\n");
            	stdout.printf(getToken(uri) + "\n");

            	//JavascriptResult results = web_view.run_javascript("window.location.hash", null);

            	var settings = new GLib.Settings ("tk.itprogramming1.photostream");
            	settings.set_string("token", getToken(uri));

            	this.close();
            }
        });		

        this.show.connect (() => {
            this.web_view.open(INSTAGRAM_AUTH);
            stdout.printf ("Hi2!\n");
        });			

		var scrolled_window = new ScrolledWindow (null, null);
		scrolled_window.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scrolled_window.add (this.web_view);

        var vbox = new VBox (false, 0);
        vbox.add (scrolled_window);
        add (vbox);  
	}
	public string getHost(string uri)
	{
		var indexStart = uri.index_of("//") + 2;
		var indexEnd = uri.index_of("/", 8);
		return uri.substring(indexStart, indexEnd - indexStart);
	}

	public string getToken(string uri)
	{
		var indexStart = uri.index_of("=") + 1;
		return uri.substring(indexStart, uri.length - indexStart);
	}
}