using Html;
using PhotoStream.Utils;

/* news structure:
html -> body -> div -> lots of ul
*/

public List<NewsActivity> parseNews(string message)
{
	List<NewsActivity> returnList = new List<NewsActivity>();

	Html.Doc* doc = Doc.read_doc (message, "");
	Xml.Node* root = doc->get_root_element ();
    if (root == null)
        error("Response is empty.");
    
    var bodyElement = getChildWithName(root, "body");
    var divElement = getChildWithName(bodyElement, "div");

    for (Xml.Node* iter = divElement->children; iter != null; iter = iter->next) // foreach ul.activity
    	if (iter->name != "text")
    		for (Xml.Node* liElement = iter->children; liElement != null; liElement = liElement->next) 
    			if (liElement->name != "text" && liElement->get_prop("class").index_of("show-more") == -1)
    				returnList.append(parseActivity(liElement)); // li as argument

    return returnList;
}

public NewsActivity parseActivity(Xml.Node* liElement)
{
	var activity = new NewsActivity();
	var usernameElement = getChildWithClass(liElement, "profile-pic");

	// getting activity type
	if (liElement->get_prop("class").index_of("follow") != -1) // follow activity
		activity.activityType = "follow";
	else if (liElement->get_prop("class").index_of("like") != -1) // like activity
		activity.activityType = "like";
	else if (liElement->get_prop("class").index_of("mention") != -1) // mention activity
		activity.activityType = "mention";
	else if (liElement->get_prop("class").index_of("comment") != -1) // comment activity
		activity.activityType = "comment";
	else if (liElement->get_prop("class").index_of("tagged-in-photo") != -1) // comment activity
		activity.activityType = "tagged-in-photo";
	else if (liElement->get_prop("class").index_of("fb-contact-joined") != -1) // comment activity
		activity.activityType = "fb-contact-joined";
	else
		error("Should've not reached here: %s.", liElement->get_prop("class"));


	var indexUrl = usernameElement->get_prop("href").index_of("=") + 1; // getting username
	activity.username = usernameElement->get_prop("href").substring(indexUrl, usernameElement->get_prop("href").length - indexUrl);

	var imageElement = usernameElement->children; // first and only child
	activity.userProfilePicture = imageElement->get_prop("src");

	var divWrapperElement = getChildWithName(liElement, "div");
	var dateElement =  getChildWithClass(divWrapperElement, "timestamp");
	activity.time = new DateTime.from_unix_local(int64.parse(dateElement->get_prop("data-timestamp")));

	if (activity.activityType == "follow") // haven't got a post, return as it
		return activity;
	if (activity.activityType == "fb-contact-joined")
	{
		var pElement = divWrapperElement->children->next;
		var username = getChildWithName(pElement, "a")->get_content();
		activity.comment = pElement->get_content().replace(username, "@" + username);
		return activity;
	}

	// loading post info

	Xml.Node* postElement ;
	if (activity.activityType == "tagged-in-photo")
		postElement = getChildWithClass(liElement, "single-image");		
	else
		postElement = getChildWithClass(liElement, "gutter");

	indexUrl = postElement->get_prop("href").index_of("=") + 1; // getting post ID
	activity.postId = postElement->get_prop("href").substring(indexUrl, postElement->get_prop("href").length - indexUrl);

	activity.imagePicture = postElement->children->get_prop("src");



	if (activity.activityType == "like" || activity.activityType == "tagged-in-photo") // like image, nothing to do here
		return activity;

	//getting mentioned comment
	// <p> we are looking for is second child, but use next 3 times instead because of 'text' node between them
	var commentElement = divWrapperElement->children->next->next->next;
	activity.comment = commentElement->get_content().substring(1, commentElement->get_content().length - 2);

	if (activity.activityType == "mention") // comments are handled differently
		return activity;

	var usernameCommentElement = divWrapperElement->children->next; // first element, see higher why using next
	indexUrl = usernameCommentElement->get_content().index_of(":") + 1;
	activity.comment = usernameCommentElement->get_content().substring(indexUrl, usernameCommentElement->get_content().length - indexUrl - 1).strip();

	return activity;
}

public Xml.Node* getChildWithId(Xml.Node* node, string id)
{
	for (Xml.Node* iter = node->children; iter != null; iter = iter->next)
		if (iter->get_prop("id") == id)
			return iter;	

	return null;

}
public Xml.Node* getChildWithName(Xml.Node* node, string name)
{
	for (Xml.Node* iter = node->children; iter != null; iter = iter->next)
		if (iter->name == name)
			return iter;	

	return null;
}
public Xml.Node* getChildWithClass(Xml.Node* node, string classNeeded)
{
	for (Xml.Node* iter = node->children; iter != null; iter = iter->next)
	{
		if (iter->name == "text")
			continue;
		if (iter->get_prop("class") != null && iter->get_prop("class").index_of(classNeeded) != -1)
			return iter;	
	}

	return null;
}
public Xml.Node* getChildWithNameAttr(Xml.Node* node, string name)
{
	for (Xml.Node* iter = node->children; iter != null; iter = iter->next)
		if (iter->get_prop("name") == name)
			return iter;	

	return null;

}

public PhotoStream.Utils.Settings parseSettings(string message)
{
	var settings = new PhotoStream.Utils.Settings();
	string emailPattern = "<input type=\"email\" name=\"email\" value=\"";
	string phonePattern = "<input type=\"tel\" name=\"phone_number\" value=\"";

	var startIndex = message.index_of(emailPattern) + emailPattern.length;
	var endIndex = message.index_of("\"", startIndex + 1);
	settings.email = message.substring(startIndex, endIndex - startIndex);

	startIndex = message.index_of(phonePattern) + phonePattern.length;
	if (message.index_of(phonePattern) != -1) 
	{
		endIndex = message.index_of("\"", startIndex + 1);
		settings.phoneNumber = message.substring(startIndex, endIndex - startIndex);
	}
	else // not found, means phone is not present
		settings.phoneNumber = "";

	if (message.index_of("<option value=\"1\" selected=\"selected\"") != -1) 
		settings.sex = "male";
	else if (message.index_of("<option value=\"2\" selected=\"selected\"") != -1) 
		settings.sex = "female";
	else
		settings.sex = "";

	if (message.index_of("id=\"chaining_enabled\"
    checked") != -1)
		settings.recommend = true;
	else
		settings.recommend = false;

	//print(message.index_of("id=\"chaining_enabled\"").to_string() + "\n");
	//print(message.substring(message.index_of("id=\"chaining_enabled\""), 50) + "\n");

	return settings;
}
