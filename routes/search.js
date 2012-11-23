var obj_picture = require('../objects/picture');
var obj_preview = require('../objects/wiki_preview');
var obj_dao = require('../objects/database');


exports.search_results = function(req, res)
{
	// initalize data base access object
	var dao = new obj_dao.DAO

	dao.query("select w.wiki_id, w.wiki_title, p.picture_id, p.caption, p.location, w.description from wiki w join wiki_content wc, picture p where MATCH(wc.title,wc.content) AGAINST(\"" + req.query.q + "\") AND wc.wiki_id=w.wiki_id AND w.picture_id=p.picture_id;", output1);

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

	function finished(new_wiki_home) 
	{
		console.log(new_wiki_home);
		res.render('search/query', { title: website_title, home: new_wiki_home});

	}

}