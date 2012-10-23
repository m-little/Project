exports.Comment = function Comment(id_, owner_, owner_pic_, content_, date_added_, date_edited_, seen_)
{
	this.id = id_;
	this.owner = owner_;
	this.picture = owner_pic_;
	this.content = content_;
	this.date_added = new Date(date_added_);
	this.date_edited = new Date(date_edited_);
	this.replies = [];
	this.flat_replies = [];
	this.indent = 0;
	this.seen = seen_;

	this.add_reply = function(reply)
	{
		this.replies.push(reply);
	}

	this.find_reply = function(reply_id)
	{
		if (this.id == reply_id)
			return this;

		for(var i = 0; i < this.replies.length; i++)
		{
			var r = this.replies[i].find_reply(reply_id);
			if (r != undefined)
				return r;
		}
		return undefined;
	}

	this.flatten_comments = function(indent_level)
	{
		this.flat_replies = [];
		this.indent = indent_level
		for(var i = 0; i < this.replies.length; i ++)
		{
			this.flat_replies.push(this.replies[i]);
			var next_flat = this.replies[i].flatten_comments(indent_level + 1);
			for(var n = 0; n < next_flat.length; n++)
				this.flat_replies.push(next_flat[n]);
		}
		return this.flat_replies;
	}
}