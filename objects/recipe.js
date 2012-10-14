exports.Recipe = function Recipe(id_, owner_, public_, name_, cate_, serv_, prep_, ready_, dir_, date_added_, date_edited_)
{
	this.id = id_;
	this.owner = owner_;
	this.public = public_;
	this.name = name_;
	this.date_added = new Date(date_added_);
	this.date_edited = new Date(date_edited_);
	this.category = cate_;
	this.directions = dir_;
	this.pictures = [];
	this.ingredients = [];
	this.comments = [];
	this.flat_comments = [];
	this.serving_size = serv_;
	this.prep_time = "";
	this.ready_time = "";
	this.rank = 0;
	this.rank_count = 0;

	var prep_time_array = [parseInt(prep_.substring(0, 2)), prep_.substring(3, 5), prep_.substring(6, 8)];
	if (prep_time_array[0] > 0)
		this.prep_time += prep_time_array[0].toString() + ":";
	this.prep_time += prep_time_array[1] + ":";
	this.prep_time += prep_time_array[2];

	var ready_time_array = [parseInt(ready_.substring(0, 2)), ready_.substring(3, 5), ready_.substring(6, 8)];
	if (ready_time_array[0] > 0)
		this.ready_time += ready_time_array[0].toString() + ":";
	this.ready_time += ready_time_array[1] + ":";
	this.ready_time += ready_time_array[2];

	this.set_pictures = function(pics_)
	{
		this.pictures = pics_;
	}

	// this is used when the jade file first needs an image to show.
	this.get_picture = function(pos)
	{
		if (pos < 0 || pos >= this.pictures.length)
			if (this.pictures.length > 0)
				return this.pictures[0];
			else
				return {location: 'unknown.png', caption: 'No Picture', id: 1};
		else
			return this.pictures[pos];
	}

	// this returns a client side javascript happy array to use when cycling through pictures.
	this.pictures_string = function()
	{
		var locations = [];
		for (var i = 0; i < this.pictures.length; i++)
			locations.push("{location: '" + this.pictures[i].location + "', caption: '" + this.pictures[i].caption + "'}");
		return locations;
	}

	this.set_ingredients = function(ing_)
	{
		this.ingredients = ing_;
	}

	this.set_comments = function(comments_)
	{
		this.comments = comments_;
	}

	this.flatten_comments = function()
	{
		this.flat_comments = [];
		for(var i = 0; i < this.comments.length; i ++)
		{
			this.flat_comments.push(this.comments[i]);
			var next_flat = this.comments[i].flatten_comments(0);
			for(var n = 0; n < next_flat.length; n++)
				this.flat_comments.push(next_flat[n]);
		}
		return this.flat_comments;
	}

	this.set_rank = function(rank_, count_)
	{
		this.rank = rank_;
		this.rank_count = count_;
	}
}