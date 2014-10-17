public void jsonParse(string message) 
{
	var parser = new Json.Parser ();

	parser.load_from_data (message);
	var root_object = parser.get_root().get_object();
    var response = root_object.get_array_member ("data");
    int64 count = response.get_length ();
    //int64 total = response.get_int_member ("numFound");
    stdout.printf ("got %lld results:\n\n", count);

    foreach (var geonode in response.get_elements ())
    {
    	var geoname = geonode.get_object ();
    	stdout.printf ("%s: %lld likes \n", geoname.get_object_member("user").get_string_member("username"), 
    									  geoname.get_object_member("likes").get_int_member("count"));
    }
}
