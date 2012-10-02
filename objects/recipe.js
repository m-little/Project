exports.Recipe = function Recipe(id_, owner_, name_, dir_)
{
	this.id = id_;
	this.owner = owner_;
	this.name = name_;
	this.directions = dir_;
	this.ingredients = [];

	this.add_ingredients = function(ing_)
	{
		this.ingredients = ing_;
	}
}