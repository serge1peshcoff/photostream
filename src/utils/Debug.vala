using PhotoStream.Utils;

public void printFeed(List<MediaInfo> list)
{
	foreach(MediaInfo post in list)
    {
    	print("Tags: ");
        foreach (string tag in post.tags)
            print("%s ", tag);

        print("Type: %s\n", post.type == PhotoStream.MediaType.IMAGE ? "image" : "video");
        print("Location: %s\n", post.location == null ? "(null)" : "");
        if (post.location != null)
        {
        	print("\tLatitude: %f\n", post.location.latitude);
			print("\tlongitude: %f\n", post.location.longitude);
			print("\tid: %" + uint64.FORMAT_MODIFIER + "d\n", post.location.id);
			print("\tname: %s\n\n", post.location.name);
        }

        print("Likes: %" + uint64.FORMAT_MODIFIER + "d\n ", post.likesCount);
        foreach (User user in post.likes)
        {
			print("\tusername: %s\n", user.username);
			print("\tprofilePicture: %s\n", user.profilePicture);
			print("\tid: %s\n", user.id);
			print("\tfullName: %s\n\n", user.fullName);
        }

        print("Image: \n");
        print("\turl: %s\n", post.image.url);
        print("\twidth: %" + uint64.FORMAT_MODIFIER + "d\n", post.image.width);
        print("\theight: %" + uint64.FORMAT_MODIFIER + "d\n", post.image.height);

        print("Users in photo: \n");
        foreach (TaggedUser user in post.taggedUsers)
        {
        	print("\tPosition: %f %f\n", user.x, user.y);
        	print("\tUser: \n");
        	print("\t\tusername: %s\n", user.user.username);
			print("\t\tprofilePicture: %s\n", user.user.profilePicture);
			print("\t\tid: %s\n", user.user.id);
			print("\t\tfullName: %s\n\n", user.user.fullName);
        }
        

        print("\nComments:\n ");
        foreach (Comment comment in post.comments)
        {
            print("\tCreation time: %" + uint64.FORMAT_MODIFIER + "d\n", comment.creationTime);
            print("\tText: %s\n", comment.text);      
			print("\tComment ID: %" + uint64.FORMAT_MODIFIER + "d\n", comment.id);
			print("\tUser:\n");
			print("\t\tusername: %s\n", comment.user.username);
			print("\t\tprofilePicture: %s\n", comment.user.profilePicture);
			print("\t\tid: %" + uint64.FORMAT_MODIFIER + "d\n", comment.user.id);
			print("\t\tfullName: %s\n\n", comment.user.fullName);
        }
        print("Filter: %s\n", post.filter);
        print("Creation time: %" + uint64.FORMAT_MODIFIER + "d\n", post.creationTime);
        print("Tagged users: \n");
        print("Title: %s\n", post.title == "" ? "<no title>" : post.title);
        print("User: \n");

        print("\tusername: %s\n", post.postedUser.username);
		print("\tprofilePicture: %s\n", post.postedUser.profilePicture);
		print("\tid: %s\n", post.postedUser.id);
		print("\tfullName: %s\n\n", post.postedUser.fullName);
		print("\tbio: %s\n", post.postedUser.bio);
		print("\twebsite: %s\n\n", post.postedUser.website);

		print("id: %s\n", post.id);
		print("didILikeThis: %s\n\n", post.didILikeThis ? "true" : "false");

    }

}