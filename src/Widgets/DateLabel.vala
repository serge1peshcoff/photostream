using PhotoStream.Utils;

public class PhotoStream.Widgets.DateLabel : Gtk.EventBox
{
	public const int TIME_REFRESH_INTERVAL = 10;

	public Gtk.Label dateLabel;
	public DateTime time;

	public DateLabel(DateTime time)
	{
		this.set_valign(Gtk.Align.CENTER);

		this.time = time;
		this.dateLabel = new Gtk.Label("");
		this.dateLabel.set_halign(Gtk.Align.START);
		this.add(dateLabel);

        setRelativeTime();   

        this.set_events(Gdk.EventMask.ENTER_NOTIFY_MASK);
        this.set_events(Gdk.EventMask.LEAVE_NOTIFY_MASK);   

        this.enter_notify_event.connect((event) => {
        	setAbsoluteTime();
        	return false;
        }); 
        this.leave_notify_event.connect((event) => {
        	setRelativeTime();
        	return false;
        });     
	}

	private void setRelativeTime()
	{
		DateTime currentTime = new DateTime.now_local();
		int64 timePassed = currentTime.to_unix() - time.to_unix();
		string units = "second";
		string time = "%lld %s%s ago.".printf(timePassed, units, timePassed == 1 ? "" : "s");

		if (timePassed >= 60)
		{
			timePassed /= 60;
			units = "minute";
			time = "%lld %s%s ago.".printf(timePassed, units, timePassed == 1 ? "" : "s");			
		}
		if (timePassed >= 60 && units == "minute")
		{
			timePassed /= 60;
			units = "hour";
			time = "%lld %s%s ago.".printf(timePassed, units, timePassed == 1 ? "" : "s");			
		}
		if (timePassed >= 24 && units == "hour")
		{
			timePassed /= 24;
			units = "day";
			time = "%lld %s%s ago.".printf(timePassed, units, timePassed == 1 ? "" : "s");			
		}
		if (timePassed >= 31 && units == "day")
		{
			timePassed /= 31;
			units = "month";
			time = "%lld %s%s ago.".printf(timePassed, units, timePassed == 1 ? "" : "s");			
		}
		if (timePassed >= 365 && units == "month")
		{
			timePassed /= 365;
			units = "year";
			time = "%lld %s%s ago.".printf(timePassed, units, timePassed == 1 ? "" : "s");			
		}

		this.dateLabel.set_markup("<i>" + time + "</i>");	

		GLib.Timeout.add_seconds(TIME_REFRESH_INTERVAL, () => {
            setRelativeTime();            
            return false;
        });
	}

	public void setAbsoluteTime()
	{
		this.dateLabel.set_markup("<i>" + time.format("%d.%m.%y %H:%M:%S") + "</i>");
	}
}