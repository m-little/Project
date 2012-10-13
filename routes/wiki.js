var obj_dao = require('../objects/database');
var obj_wiki = require('../objects/wiki');
var obj_video = require('../objects/video');
var obj_picture = require('../objects/picture');

exports.display_view = function(req, res)
{
	if (req.query.w_id == undefined)
	{
		res.redirect('/');
		return;
	}

	var dao = new obj_dao.DAO();	
	
	dao.query("SELECT w.video_id, wiki_title, v.name, v.caption, v.address FROM wiki w JOIN video v ON w.video_id = v.video_id WHERE wiki_id =" + req.query.w_id, output);
	
	function output(success, result, fields)
	{
		if (result.length == 0) 
		{
			res.redirect('/');
			return;
		}

		var row = result[0];
		
		var new_video = new obj_video.Video(row.video_id, row.name, row.caption, row.address);
		var new_wiki = new obj_wiki.Wiki(req.query.w_id, new_video, row.wiki_title);
		
		finished(new_wiki);
	}

	function finished(new_wiki) {
		res.render('wiki/wiki_view', { title: website_title, wiki: new_wiki});
	}
}

