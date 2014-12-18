using Gtk;
using WebKit;

public class PhotoStream.LoginWindow : Gtk.ApplicationWindow
{

	private WebView webView;
	private const string INSTAGRAM_LOGIN = "https://instagram.com/accounts/login/";
	private const string INSTAGRAM_AUTH = "https://api.instagram.com/oauth/authorize/?client_id="
											 + PhotoStream.App.CLIENT_ID 
											 + "&redirect_uri="
											 + PhotoStream.App.REDIRECT_URI
											 + "&scope=basic+comments+relationships+likes"
											 + "&response_type=code";
	private string HOST;

	public Gtk.Spinner spinner;
	public Gtk.Box box;
	public Gtk.ScrolledWindow scrolledWindow;

	public LoginWindow () 
	{
		this.set_default_size (800, 700);
        this.set_size_request (800, 700);
		this.resizable = false;

		HOST = getHost(PhotoStream.App.REDIRECT_URI);

		this.webView = new WebView ();
		this.webView.web_context.get_cookie_manager().set_persistent_storage(PhotoStream.App.CACHE_URL + "cookie.txt", 
										CookiePersistentStorage.TEXT);
		
		this.title = "Login to Instagram";

		print("Using WebKit version %d.%d.%d\n", WebKit.MAJOR_VERSION, WebKit.MINOR_VERSION, WebKit.MICRO_VERSION);

		this.webView.load_changed.connect ((loadEvent) => {
			if (loadEvent != LoadEvent.FINISHED)
				return;
            var uri = webView.get_uri ();
            var host = getHost(uri);
            
            if (host == this.HOST)
            {
            	this.spinner = new Gtk.Spinner();
            	spinner.start();            	

            	box.remove(scrolledWindow);
            	box.pack_start(spinner, true, true);

            	this.show_all();
            	
            	new Thread<int>("", () => {
            		confirmToken(uri);
            		return 0;
            	});
            }
        });

        this.show.connect (() => {
            this.webView.load_uri(INSTAGRAM_AUTH);
        });			

		scrolledWindow = new ScrolledWindow (null, null);
		scrolledWindow.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scrolledWindow.add (this.webView);

        box = new Box (Gtk.Orientation.VERTICAL, 0);       
		box.pack_start (scrolledWindow, true, true);
        add (box); 
	}
	public string getHost(string uri)
	{
		var indexStart = uri.index_of("//") + 2;
		var indexEnd = uri.index_of("/", 8);
		return uri.substring(indexStart, indexEnd - indexStart);
	}

	public string getCode(string uri)
	{
		var indexStart = uri.index_of("=") + 1;
		return uri.substring(indexStart, uri.length - indexStart);
	}

	public void confirmToken(string uri)
	{
		var session = new Soup.Session ();
	    var message = new Soup.Message ("POST", "https://api.instagram.com/oauth/access_token");

	    uint8[] requestString = ("client_id=" + PhotoStream.App.CLIENT_ID 
	    						 + "&client_secret=" + PhotoStream.App.CLIENT_SECRET
	    						 + "&grant_type=authorization_code"
	    						 + "&redirect_uri=" + PhotoStream.App.REDIRECT_URI
	    						 + "&code=" + getCode(uri)).data;

	    message.request_body.append_take(requestString);
	    session.send_message (message);

	    string token;
	    try
	    {
	    	token = parseToken((string)message.response_body.data);		
	    }
	    catch (Error e)
	    {
	    	error("Something wrong with received token: %s", e.message);
	    }	    

	    Idle.add(() => {
	    	setToken(token);
	    	this.close();
	    	return false;
	    });    	
	}
}