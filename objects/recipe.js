exports.Recipe = function Recipe(id_, owner_, picture_, name_, cate_, dir_)
{
	this.id = id_;
	this.owner = owner_;
	this.picture = picture_;
	this.name = name_;
	this.category = cate_;
	this.directions = dir_;
	this.ingredients = [];

	this.add_ingredients = function(ing_)
	{
		this.ingredients = ing_;
	}
}