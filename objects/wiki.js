exports.Wiki = function Wiki(id_, video_, title_, picture_, desc_, cate_)
{
	this.id = id_;
	this.video = video_;
	this.title = title_;
	this.content = [];
	this.picture = picture_;
	this.description = desc_;
	this.category_id = cate_;

	this.set_content = function(content_) 
	{
		this.content = content_;
	}
}