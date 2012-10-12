var obj_dao = require('../objects/database');
var obj_wiki = require('../objects/wiki');
var obj_video = require('../objects/video');
var obj_picture = require('../objects/picture');

exports.display_view = function(req, res)
{
	var dao = new obj_dao.DAO();
	var new_wiki = new obj_wiki();	
	
	dao.query("SELECT wiki_title FROM wiki WHERE wiki_id = 1", output);
	
	function output(success, result, fields)
	{
		console.log(result);
		for(var i in result) 
		{
			var row = result[i];
			new_wiki.title = row.wiki_title;
		}
		
		
	}

	
	res.render('wiki/wiki_view', { title: website_title, wiki: new_wiki});
}

