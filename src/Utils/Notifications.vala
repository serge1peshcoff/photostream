using PhotoStream.Utils;
using Gdk;

public void displayNewsNotifications(List<NewsActivity> activityList)
{
	int64 lastCheckedDate = loadDate();

	activityList.reverse();
	foreach (NewsActivity activity in activityList)
	{
		if (activity.time.to_unix() < lastCheckedDate)
			continue;

		var actions = new Gee.HashMap<string, string>();
		actions["follow"] = "followed you.";
		actions["like"] = "liked your photo";
		actions["mention"] = "mentioned you in a comment:";
		actions["comment"] = "left a comment on your photo:";
		actions["tagged-in-photo"] = "took a picture of you.";

		string summary = "@" + activity.username + " " + actions[activity.activityType];
		string body = (activity.activityType == "follow" || activity.activityType == "like") ? "" : activity.comment;
		Pixbuf icon;

		var avatarFileName = PhotoStream.App.CACHE_AVATARS + getFileName(activity.userProfilePicture);
		File file = File.new_for_path(avatarFileName);
        if (!file.query_exists()) // avatar not downloaded, download
        	try
        	{
        		downloadFile(activity.userProfilePicture, avatarFileName);
        	}
        	catch (Error e)
        	{
        		return; // not loading avatar, to fix.
        	}

		try
		{
			icon = new Pixbuf.from_file(avatarFileName);
		}
		catch (Error e)
		{
			error("Something wrong with file loading.");
		}

		Notify.Notification notification = new Notify.Notification(summary, body, null);
		notification.set_image_from_pixbuf(icon);

		try
		{
			notification.show();
		}
		catch (Error e)
		{
			error("Something wrong with notification displaying.");
		}		
	}
	setCurrentDate();
}