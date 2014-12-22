using Gtk;
using WebKit;
using PhotoStream.Utils;


public class PhotoStream.LocationMapWindow : Gtk.Window
{
	public Box scaleBox;

	public Label distanceLabel;
	public Gtk.Scale scale;
	public Gtk.Button searchButton;

	public signal void locationLoaded(Location location);

	private WebView webView;
	public static const string MAPS_API_KEY = "AIzaSyCnUHdNP9KhZa33NYdPbOBqkzyzEKlpsR8";
	public static const int ZOOM_INITIAL = 15;
	public static const int RANGE_INITIAL = 1000;
	public Location location;

	public signal void locationOpened();

	public LocationMapWindow () 
	{
		this.initFields();
	}

	public LocationMapWindow.with_location(Location location)
	{		
		this.location = location;
		this.initFields();
	}

	public void initFields()
	{
		this.scaleBox = new Box(Gtk.Orientation.HORIZONTAL, 0);

		this.distanceLabel = new Gtk.Label("Distance: ");
		this.scaleBox.pack_start(distanceLabel, false, true);

		this.searchButton = new Gtk.Button.with_label("Search nearby locations...");
		this.scaleBox.pack_end(searchButton, false, true);

		this.searchButton.clicked.connect(() => {
			loadNearbyLocations();
		});

		this.scale = new Scale.with_range (Gtk.Orientation.HORIZONTAL, 100, 5000, 100);	
		this.scale.set_value(RANGE_INITIAL);
		this.scaleBox.pack_end(scale, true, true);


		this.set_default_size (800, 700);
        this.set_size_request (800, 700);
		this.resizable = false;

		this.webView = new WebKit.WebView ();
		this.title = "Location";

		this.webView.permission_request.connect((request) => {
			request.allow();
			return true;
		});

		this.webView.get_settings().set_enable_accelerated_2d_canvas(true);
		this.webView.get_settings().set_enable_webgl(true);
		this.webView.get_settings().set_enable_write_console_messages_to_stdout(true);
		

        this.show.connect (() => {
            loadHtml();
        });			

		var scrolled_window = new ScrolledWindow (null, null);
		scrolled_window.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scrolled_window.add (this.webView);

        var box = new Box (Gtk.Orientation.VERTICAL, 0); 
       	box.pack_start(scaleBox, false, true);   
		box.pack_end (scrolled_window, true, true);
        add (box); 

        this.scale.value_changed.connect(() => {
        	redrawCircle();
        });
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
		"
		var markers = [];
		";

		/*if (location == null)
			mapsJs += " 

		if(navigator.geolocation) 
		{
		    navigator.geolocation.getCurrentPosition(function(position) 
		    {
		        markerLocation = new google.maps.LatLng(position.coords.latitude,
		                                         position.coords.longitude);

			}, function() {
		      // stub, not doing anything and using (0, 0) as coords
		      alert(\"Cannot load location.\");
		    });
		}";		*/

		loadMap.begin(() => {
			mapsJs += "

			var userMarkerLocation = new google.maps.LatLng(%f, %f);

			var userMarker = new google.maps.Marker({
				position: userMarkerLocation,
			    map: map,
			    draggable: %s,
			    title: \"%s\"
			});		

			".printf(this.location == null ? 50.0 : this.location.latitude, 
					this.location == null ? 30.0 : this.location.longitude, 
					this.location == null ? "true" : "false", 
					this.location == null ? "User marker" : this.location.name);
			if (location == null)
				mapsJs += "

				var rangeOptions = {
			    	strokeColor: '#FF0000',
			    	strokeOpacity: 0.8,
			    	strokeWeight: 2,
			    	fillColor: '#FF0000',
			    	fillOpacity: 0.35,
			    	map: map,
			     	center: userMarkerLocation, 
			    	radius: %d
			    };

			    var rangeCircle = new google.maps.Circle(rangeOptions);

				google.maps.event.addListener(userMarker, 'dragend', function() 
				{
					rangeCircle.setCenter(userMarker.getPosition());
				});
				".printf(RANGE_INITIAL);
			this.webView.run_javascript.begin(mapsJs, null, () => {
				
			});			
		});
		
	}

	private async void loadMap()
	{
		string mapsJs = "
		var mapOptions = {
          center: new google.maps.LatLng(%f, %f),
          zoom: %d,
          mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        var map = new google.maps.Map(document.getElementById(\"map_canvas\"),
            mapOptions);".printf(location == null ? 50.0 : location.latitude, 
								location == null ? 30.0 : location.longitude, 
								ZOOM_INITIAL);
        this.webView.run_javascript.begin(mapsJs, null, (obj, res) => {
			try
			{
				this.webView.run_javascript.end(res);
			}
			catch (Error e)
			{
				error("Something wrong with Javascript.");
			}
			return;
		});	
	}

	private async void addMarker(Location? location)
	{
		string markerJs = "

		var markerLocation = new google.maps.LatLng(%f, %f);

		var marker = new google.maps.Marker({
			position: markerLocation,
		    map: map,
		    draggable: %s,
		    title: \"%s\"
		});	

		markers.push(marker);	

		".printf(location == null ? 50.0 : location.latitude, 
				location == null ? 30.0 : location.longitude, 
				location == null ? "true" : "false", 
				location == null ? "User marker" : location.name.replace("\"", "\\\""));

		this.webView.run_javascript.begin(markerJs, null, (obj, res) => {
			try
			{
				this.webView.run_javascript.end(res);
			}
			catch (Error e)
			{
				error("Something wrong with Javascript.");
			}
			return;
		});	
	}

	private void redrawCircle()
	{
		var js = "
		rangeCircle.setRadius(%d);
		;
		".printf((int)this.scale.get_value());
		this.webView.run_javascript.begin(js, null, () => {
			
		});
	}

	public void loadNearbyLocations()
	{
		var js = "
		document.title = userMarker.getPosition().lat() + \" \" + userMarker.getPosition().lng();
		";
		this.webView.run_javascript.begin(js, null, (obj, res) => {
			string[] values =  webView.get_title().split(" ");

			double latitude = double.parse(values[0]);
			double longitude = double.parse(values[1]);

			new Thread<int>("", () => {
				loadLocationsList(latitude, longitude);
				return 0;
			});
		});
	}
	public override bool delete_event(Gdk.EventAny event)
	{
		this.hide();
		return true;
	} 

	public void loadLocationsList(double latitude, double longitude)
	{
		string response = searchLocation(latitude, longitude, (int)this.scale.get_value());
		List<Location> locationList = parseLocationList(response);

		Idle.add(() => {
			string clearJs = "
			for (var i = 0; i < markers.length; i++) 
			    markers[i].setMap(null);

			markers = [];
			";
			this.webView.run_javascript(clearJs, null, (obj, res) => {
				try
				{
					this.webView.run_javascript.end(res);
				}
				catch (Error e)
				{
					error("Something wrong with Javascript.");
				}
				foreach (Location location in locationList)
					addMarker.begin(location, (obj, res) => {
						addMarker.end(res);
					});	
				
			});
			return false;			
		});
	}
}