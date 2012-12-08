var obj_picture = require('../objects/picture');
var obj_preview = require('../objects/preview');
var obj_dao = require('../objects/database');


exports.search_results = function(req, res)
{
	// initalize data base access object
	var dao = new obj_dao.DAO();

	if (req.query.t == 'w') {
		dao.query("select w.wiki_id, w.wiki_title, p.picture_id, p.caption, p.location, w.description from wiki w join wiki_content wc, picture p where (MATCH(w.wiki_title) AGAINST(\"" + dao.safen(req.query.q) + "\" IN NATURAL LANGUAGE MODE) OR (MATCH(wc.title,wc.content) AGAINST(\"" + dao.safen(req.query.q) + "\" IN NATURAL LANGUAGE MODE) AND wc.wiki_id=w.wiki_id )) AND w.picture_id=p.picture_id GROUP BY w.wiki_id;", output1);
	}
	else if (req.query.t == 'r') {
		dao.query("select r.recipe_id, r.recipe_name, r.description, p.picture_id, p.caption, p.location from recipe r JOIN recipe_ingredient ri, ingredient i, recipe_picture rp, picture p where (MATCH(r.recipe_name) AGAINST(\"" + dao.safen(req.query.q) + "\" IN NATURAL LANGUAGE MODE) OR MATCH(i.ingr_name) AGAINST(\"" + dao.safen(req.query.q) + "\" IN NATURAL LANGUAGE MODE)) AND i.ingr_id = ri.ingr_id AND r.recipe_id = ri.recipe_id AND r.public = 1 AND rp.recipe_id = r.recipe_id AND p.picture_id=rp.picture_id GROUP BY r.recipe_id;", output2);

	}
	else {
		dao.die();
		res.redirect('/500error');
		return;
	}

	function output1(success, result, fields)
	{
		if (!success)
		{
			dao.die();
			res.redirect('/500error');
			return;
		}		

		var preview_array = new Array();

		// get the first row (should be the only row) from the results returned by the database
		for(var i in result)
		{	
			var row = result[i];
			var new_picture = new obj_picture.Picture(row.picture_id, row.caption, row.location);
			var new_prev = new obj_preview.preview(row.wiki_id,row.wiki_title, row.description);
			new_prev.set_picture(new_picture);
			preview_array.push(new_prev);
		}
		
		//console.log(preview_array);
		dao.die();
		finished(preview_array, 'w');
	}

	function output2(success, result, fields)
	{
		if (!success)
		{
			dao.die();
			res.redirect('/500error');
			return;
		}

		var preview_array = new Array();


		// get the first row (should be the only row) from the results returned by the database
		for(var i in result)
		{
			console.log(result);
			var row = result[i];
			var new_picture = new obj_picture.Picture(row.picture_id, row.caption, row.location);
			var new_prev = new obj_preview.preview(row.recipe_id,row.recipe_name, row.description);
			new_prev.set_picture(new_picture);

			preview_array.push(new_prev);

		}

		//dao.query("SELECT p.location, p.picture_id, p.caption FROM recipe_picture rp JOIN picture p WHERE rp.picture_id = p.picture_id AND rp.recipe_id =" + preview_array[i].id + " LIMIT 1;", output3, preview_array, 0, preview_array.length);
		
		console.log(preview_array);
		dao.die();
		finished(preview_array, 'r');
	}

	function finished(new_results, t) 
	{
		//console.log(new_results);
		res.render('search/query', { title: website_title, results: new_results, type: t});

	}

}