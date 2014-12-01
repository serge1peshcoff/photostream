using Gtk;
using WebKit;

public class PhotoStream.LocationMapWindow : Gtk.ApplicationWindow
{

	private WebView webView;
	public LocationMapWindow () 
	{
		this.set_default_size (800, 700);
        this.set_size_request (800, 700);
		this.resizable = false;

		this.webView = new WebKit.WebView ();
		this.title = "Location";

		//print("Using WebKit version %d.%d.%d\n", WebKit.MAJOR_VERSION, WebKit.MINOR_VERSION, WebKit.MICRO_VERSION);

		//this.webView.ready_to_show.connect (() => {
        //   
        //});		

        //this.show.connect (() => {
        //    //this.webView.open(INSTAGRAM_AUTH);
        //});			

		var scrolled_window = new ScrolledWindow (null, null);
		scrolled_window.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scrolled_window.add (this.webView);

        var box = new Box (Gtk.Orientation.VERTICAL, 0);       
		box.pack_start (scrolled_window, true, true);
        add (box); 
	}
}