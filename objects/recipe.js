exports.Recipe = function Recipe(id_, owner_, public_, picture_, name_, cate_, serv_, prep_, dir_)
{
	this.id = id_;
	this.owner = owner_;
	this.public = public_;
	this.picture = picture_;
	this.name = name_;
	this.category = cate_;
	this.directions = dir_;
	this.ingredients = [];
	this.comments = [];
	this.flat_comments = [];
	this.serving_size = serv_;
	this.prep_time = ""
	var prep_time_array = [parseInt(prep_.substring(0, 2)), prep_.substring(3, 5), prep_.substring(6, 8)];
	if (prep_time_array[0] > 0)
		this.prep_time += prep_time_array[0].toString() + ":";
	this.prep_time += prep_time_array[1] + ":";
	this.prep_time += prep_time_array[2];

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
}