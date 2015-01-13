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
	public static const int ZOOM_INITIAL = 13;
	public static const int RANGE_INITIAL = 1000;
	public static const double LATITUDE_INITIAL = 55.75;
	public static const double LONGITUDE_INITIAL = 37.36;
	public Location location;
	public List<Location> locationList;
	public string prevTitle = "";

	private int currentNumber = 0;

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

        checkTitle();
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

		loadGeolocation.begin(() => {
			loadMap.begin(() => {
				mapsJs += "
				userMarker = new google.maps.Marker({
					position: userMarkerLocation,
				    map: map,
				    draggable: %s,
				    title: \"%s\"
				});		

				".printf(this.location == null ? "true" : "false", 
						this.location == null ? "User marker" : this.location.name.replace("\"", "\\\""));
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
		});
	}

	private async void loadMap()
	{
		string mapsJs = "

		var mapOptions = {
          center: userMarkerLocation,
          zoom: %d,
          mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        map = new google.maps.Map(document.getElementById(\"map_canvas\"),
            mapOptions);".printf(ZOOM_INITIAL);
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

	private async void loadGeolocation()
	{
		string loadGeoJs = " 

		var userMarkerLocation = new google.maps.LatLng(%f, %f);
		var userMarker;
		var map;

		if(navigator.geolocation) 
		{
		    navigator.geolocation.getCurrentPosition(function(position) 
		    {
		        userMarkerLocation = new google.maps.LatLng(position.coords.latitude,
		                                         position.coords.longitude);
				userMarker.setPosition(userMarkerLocation);
				map.setCenter(userMarkerLocation);
			}, function() {
		      // stub, not doing anything and using (0, 0) as coords
		      alert(\"Cannot load location, using the default one.\");
		    });
		}".printf(this.location == null ? LATITUDE_INITIAL : this.location.latitude, 
				  this.location == null ? LONGITUDE_INITIAL : this.location.longitude);	

		this.webView.run_javascript.begin(loadGeoJs, null, (obj, res) => {
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

		google.maps.event.addListener(marker, \"dblclick\", function (e) { 
               document.title = \"open \" +  %d;
            });

		markers.push(marker);	

		".printf(location == null ? 50.0 : location.latitude, 
				location == null ? 30.0 : location.longitude, 
				location == null ? "true" : "false", 
				location == null ? "User marker" : location.name.replace("\"", "\\\""), 
				currentNumber);
		currentNumber++;

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
		document.title = \"location \" + userMarker.getPosition().lat() + \" \" + userMarker.getPosition().lng();
		";
		this.webView.run_javascript.begin(js, null, (obj, res) => {
			try
			{
				this.webView.run_javascript.end(res);
			}
			catch (Error e)
			{
				error("Something wrong with Javascript.");
			}
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
		try
		{
			locationList = parseLocationList(response);
		}
		catch (Error e)
		{
			error("Something wrong with parsing: %s.", e.message);
		}
		currentNumber = 0;

		Idle.add(() => {
			string clearJs = "
			for (var i = 0; i < markers.length; i++) 
			    markers[i].setMap(null);

			markers = [];
			";
			this.webView.run_javascript.begin(clearJs, null, (obj, res) => {
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
	

	private void checkTitle()
	{
		if (webView.title != null && prevTitle != webView.title)
		{
			prevTitle = webView.title;
			parseTitle();
		}

		GLib.Timeout.add(500, () => {
			checkTitle();
			return false;
		});
	}
	public void parseTitle()
	{
		string[] values =  webView.get_title().split(" ");

		if (values[0] == "location")
		{
			double latitude = double.parse(values[1]);
			double longitude = double.parse(values[2]);

			new Thread<int>("", () => {
				loadLocationsList(latitude, longitude);
				return 0;
			});
		}
		else if (values[0] == "open")
		{
			var locationOpened = locationList.nth(int.parse(values[1])).data;
			if (locationOpened.id != "0")
				locationLoaded(locationOpened);
		}
		else
			error("Should've not reached here: %s", values[0]);
	}
}