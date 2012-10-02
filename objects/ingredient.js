function Ingredient(id_, pic_id_, name_, unit_name_, unit_abrev_, amount_)
{
	this.name = name_;
	this.id = id_;
	this.picture_id = pic_id_;
	this.unit_name = unit_name_.toLowerCase();
	this.unit_abrev = unit_abrev_;
	this.amount = amount_;
}

exports.Ingredient = Ingredient;