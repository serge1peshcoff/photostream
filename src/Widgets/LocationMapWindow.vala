using Gtk;
using WebKit;

public class PhotoStream.LocationMapWindow : Gtk.ApplicationWindow
{
	private WebView webView;
	public static const string MAPS_API_KEY = "AIzaSyCnUHdNP9KhZa33NYdPbOBqkzyzEKlpsR8";
	public LocationMapWindow () 
	{
		this.set_default_size (800, 700);
        this.set_size_request (800, 700);
		this.resizable = false;

		this.webView = new WebKit.WebView ();
		this.title = "Location";

        this.show.connect (() => {
            loadHtml();
        });			

		var scrolled_window = new ScrolledWindow (null, null);
		scrolled_window.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scrolled_window.add (this.webView);

        var box = new Box (Gtk.Orientation.VERTICAL, 0);       
		box.pack_start (scrolled_window, true, true);
        add (box); 
	}
	private void loadHtml()
	{
		var file = File.new_for_path (PhotoStream.App.CACHE_HTML + "maps.html");
		string html = "";
        try 
        {
        	string line;
        	var dis = new DataInputStream (file.read ());
	        
	        while ((line = dis.read_line (null)) != null)
	            html += line;
	    } 
	    catch (Error e) 
	    {
	        error ("Something wrong with file loading: %s", e.message);
	    }
	    html = html.replace("YOUR_API_KEY", MAPS_API_KEY);
	    this.webView.load_html(html, null);
	    this.webView.load_changed.connect((loadEvent) => 
	    {
	    	if (loadEvent == LoadEvent.FINISHED)
	    		loadMapsJavascript();

	    });
	}
	private void loadMapsJavascript()
	{
		string mapsJs = "
        var mapOptions = {
          center: new google.maps.LatLng(%f, %f),
          zoom: %d,
          mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        var map = new google.maps.Map(document.getElementById(\"map_canvas\"),
            mapOptions);".printf(-34.397, 150.644, 8);
		this.webView.run_javascript.begin(mapsJs, null, () => {
			print("js run.\n");
		});

	}
}