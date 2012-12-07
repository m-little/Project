var obj_dao = require('../objects/database');
var obj_picture = require('../objects/picture');

exports.preview = function preview(id_,title_, description_)
{
	this.id = id_;
	this.title = title_;
	this.description = description_;
	this.picture;

	this.set_picture = function(pic_)
	{
		this.picture = pic_;
	}

}