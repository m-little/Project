function Ingredient(id_, pic_, name_, unit_name_, unit_abrev_, amount_, use_count_, wiki_id_)
{
	this.name = name_;
	this.id = id_;
	this.picture = pic_;
	this.unit_name = unit_name_.toLowerCase();
	this.unit_abrev = unit_abrev_;
	this.amount = amount_;
	this.use_count = use_count_;
	this.wiki_id = wiki_id_;

	this.name = this.name.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase()+txt.substr(1);});
}

exports.Ingredient = Ingredient;