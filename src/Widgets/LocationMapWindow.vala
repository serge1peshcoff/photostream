using Gtk;
using WebKit;
using PhotoStream.Utils;

public class PhotoStream.LocationMapWindow : Gtk.ApplicationWindow
{
	private WebView webView;
	public static const string MAPS_API_KEY = "AIzaSyCnUHdNP9KhZa33NYdPbOBqkzyzEKlpsR8";
	public static const int ZOOM_INITIAL = 15;
	public Location location;


	public LocationMapWindow (Location location) 
	{		

		this.location = location;
		this.set_default_size (800, 700);
        this.set_size_request (800, 700);
		this.resizable = false;

		print("got here0\n");

		this.webView = new WebKit.WebView ();
		this.title = "Location";

		print("got here %f %f\n", location.latitude, location.longitude);

        this.show.connect (() => {
        	print("got here2\n");
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
		string mapsJs = 
		"var markerLocation = new google.maps.LatLng(%f, %f);

		var mapOptions = {
          center: markerLocation,
          zoom: %d,
          mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        var map = new google.maps.Map(document.getElementById(\"map_canvas\"),
            mapOptions);

		var marker = new google.maps.Marker({
	      position: markerLocation,
	      map: map,
	      title: \"%s\"
	  	});


		".printf(location.latitude, location.longitude, ZOOM_INITIAL, location.name);
		this.webView.run_javascript.begin(mapsJs, null, () => {
			print("js run.\n");
		});
	}
}