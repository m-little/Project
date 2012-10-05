var _mysql = require('mysql');
var obj_wiki = require('../objects/wiki');
var obj_video = require('../objects/video');
var obj_picture = require('../objects/picture');

exports.display_view = function(req, res)
{
	var _stuff = new Array();
	_stuff[0] = 'baa';
	_stuff[1] = 'baa baa';
	res.render('wiki/wiki_view', { title: website_title, stuff: _stuff});
}