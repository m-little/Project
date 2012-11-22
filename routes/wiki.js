var obj_dao = require('../objects/database');
var obj_wiki = require('../objects/wiki');
var obj_video = require('../objects/video');
var obj_picture = require('../objects/picture');
var obj_content = require('../objects/wiki_content')
var obj_preview = require('../objects/wiki_preview')

exports.home_view = function(req, res)
{
	// initalize data base access object
	var dao = new obj_dao.DAO

	dao.query("SELECT w.wiki_id, w.wiki_title, p.picture_id, w.description, p.location, p.caption FROM wiki w JOIN picture p  WHERE w.picture_id = p.picture_id ORDER BY wiki_id DESC LIMIT 5", output1);

	function output1(success, result, fields)
	{
		// if there are no results redirect to the home page
		if (result.length == 0) 
		{
			res.redirect('/');
			return;
		}

		

		var preview_array = new Array();


		// get the first row (should be the only row) from the results returned by the database
		for(var i in result)
		{
			
			var row = result[i];
			var new_picture = new obj_picture.Picture(row.picture_id, row.caption, row.location);
			var new_prev = new obj_preview.preview(row.wiki_id,row.wiki_title, row.description, new_picture);
			preview_array.push(new_prev);

		}
		
		//console.log(preview_array);
		dao.die();
		finished(preview_array);
	}

	function output2(success, result, fields, new_wiki)
	{

	}


	function finished(new_wiki_home) 
	{
		console.log(new_wiki_home);
		res.render('wiki/wiki_home', { title: website_title, home: new_wiki_home});

	}

}

exports.display_view = function(req, res)
{
	// if w_id isnt pressent redirect to the home page
	if (req.query.w_id == undefined)
	{
		res.redirect('/');
		return;
	}

	// initalize data base access object
	var dao = new obj_dao.DAO();	
	
	// first query gets information that belongs to the wiki and video tables from the database and runs the function output1 on completion
	dao.query("SELECT w.video_id, wiki_title, v.name, v.caption, v.address FROM wiki w JOIN video v ON w.video_id = v.video_id WHERE wiki_id =" + req.query.w_id, output1);
	
	function output1(success, result, fields)
	{
		// if there are no results redirect to the home page
		if (result.length == 0) 
		{
			res.redirect('/');
			return;
		}

		// get the first row (should be the only row) from the results returned by the database
		var row = result[0];

		// construct video and wiki objects from the info obtained from the database
		var new_video = new obj_video.Video(row.video_id, row.name, row.caption, row.address);
		var new_wiki = new obj_wiki.Wiki(req.query.w_id, new_video, row.wiki_title);
		
		// second query gets the wiki pages content (i.e. sections of the wiki page and pictures belonging to that section) and runst the function output2 on completion
		dao.query("SELECT content, title, p.picture_id, p.location, p.caption FROM wiki_content wc JOIN picture p ON wc.picture_id = p.picture_id WHERE wc.wiki_id =" + req.query.w_id, output2, new_wiki);
	}

	// this function builds the wiki_content objects and stores them in an array that is then put in the 'wiki' object
	function output2(success, result, fields, new_wiki)
	{
		//console.log(result);

		var content_array = new Array();

		for(var i in result)
		{
			var row = result[i];

			var new_picture = new obj_picture.Picture(row.picture_id, row.caption, row.location);
			var new_content = new obj_content.Wiki_Content(new_picture, row.title, row.content);

			//console.log(new_content);
			content_array.push(new_content);
		}

		new_wiki.set_content(content_array);
		//console.log(new_wiki);
		dao.die();
		finished(new_wiki);
	}

	function finished(new_wiki) {
		res.render('wiki/wiki_view', { title: website_title, wiki: new_wiki});
	}
}