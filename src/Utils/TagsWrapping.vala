public string wrapInTags(string original)
{
	string res;

	try
	{
		Regex hashtagRegex = new Regex("#([\\p{L}0-9_]+)");
		res = hashtagRegex.replace_eval (original, -1, 0, 0, (mi, s) => {
            s.append_printf ("<a href=\"%s\">%s</a>", mi.fetch (0), mi.fetch (0));
            return false;
        });

		Regex usernameRegex = new Regex("@([a-zA-Z0-9_]+)");
		res = usernameRegex.replace_eval (res, -1, 0, 0, (mi, s) => {
                s.append_printf ("<a href=\"%s\">%s</a>", mi.fetch (0), mi.fetch (0));
                return false;
            });



		Regex urlRegex = new Regex("([a-zA-Z0-9_-]+\\.)+([a-zA-Z]{2,6})(/[a-zA-Z0-9_-]+)*/?");
		res = urlRegex.replace_eval (res, -1, 0, 0, (mi, s) => {
                s.append_printf ("<a href=\"%s\">%s</a>", mi.fetch (0), mi.fetch (0));
                return false;
            });
	}
	catch(Error e)
	{
		error("Something wrong with regexes: " + e.message + ".\n");
	}
	return res;
}