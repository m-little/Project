exports.Wiki = function Wiki(id_, video_, title_)
{
	this.id = id_;
	this.video = video_;
	this.title = title_;
	this.content = [];

	this.set_content = function(content_) 
	{
		this.content = content_;
	}
}