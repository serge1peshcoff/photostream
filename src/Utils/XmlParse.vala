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

    for (Xml.Node* iter = divElement->children; iter != null; iter = iter->next)
    	if (iter->name != "text")
    		returnList.append(parseActivity(iter)); // ul class="activity" as argument

    return returnList;
}

public NewsActivity parseActivity(Xml.Node* element)
{
	NewsActivity activity = new NewsActivity();


	var liElement = getChildWithName(element, "li");
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
	else
		error("Should've not reached here.");

	var indexUrl = usernameElement->get_prop("href").index_of("=") + 1; // getting username
	activity.username = usernameElement->get_prop("href").substring(indexUrl, usernameElement->get_prop("href").length - indexUrl);

	var imageElement = usernameElement->children; // first and only child
	activity.userProfilePicture = imageElement->get_prop("src");

	var divWrapperElement = getChildWithName(liElement, "div");
	var dateElement =  getChildWithClass(divWrapperElement, "timestamp");
	activity.time = new DateTime.from_unix_local(int64.parse(dateElement->get_prop("data-timestamp")));

	if (activity.activityType == "follow") // haven't got a post, return as it
		return activity;

	// loading post info

	var postElement = getChildWithClass(liElement, "gutter");
	indexUrl = postElement->get_prop("href").index_of("=") + 1; // getting post ID
	activity.postId = postElement->get_prop("href").substring(indexUrl, postElement->get_prop("href").length - indexUrl);

	//print(postElement->children->name + "\n");
	activity.imagePicture = postElement->children->get_prop("src");

	if (activity.activityType == "like") // like image, nothing to do here
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