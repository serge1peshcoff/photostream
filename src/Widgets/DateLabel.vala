using PhotoStream.Utils;

public class PhotoStream.Widgets.DateLabel : Gtk.EventBox
{
	public const int TIME_REFRESH_INTERVAL = 10;

	public Gtk.Label dateLabel;
	public DateTime time;
	public DateLabel(DateTime time)
	{
		this.time = time;
		this.dateLabel = new Gtk.Label("");
		this.dateLabel.set_halign(Gtk.Align.START);
		this.add(dateLabel);

        updateTime();            
	}

	private void updateTime()
	{
		DateTime currentTime = new DateTime.now_local();
		int64 timePassed = currentTime.to_unix() - time.to_unix();
		string time = "%lld second%s ago.".printf(timePassed, timePassed == 1 ? "" : "s");

		if (timePassed >= 60)
		{
			timePassed /= 60;
			time = "%lld minute%s ago.".printf(timePassed, timePassed == 1 ? "" : "s");
		}
		if (timePassed >= 60)
		{
			timePassed /= 60;
			time = "%lld hour%s ago.".printf(timePassed, timePassed == 1 ? "" : "s");
		}
		if (timePassed >= 24)
		{
			timePassed /= 24;
			time = "%lld day%s ago.".printf(timePassed, timePassed == 1 ? "" : "s");
		}
		if (timePassed >= 31)
		{
			timePassed /= 31;
			time = "%lld month%s ago.".printf(timePassed, timePassed == 1 ? "" : "s");
		}
		if (timePassed >= 365)
		{
			timePassed /= 365;
			time = "%lld year%s ago.".printf(timePassed, timePassed == 1 ? "" : "s");
		}

		this.dateLabel.set_markup("<i>" + time + "</i>");	

		GLib.Timeout.add_seconds(TIME_REFRESH_INTERVAL, () => {
            updateTime();            
            return false;
        });
	}
}