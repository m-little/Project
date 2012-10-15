var login = require('./login.js');

// Handling GET and POST data...
// req.query.blah = the GET variable named blah
// req.body.blah = the POST variable named blah

exports.index = function(req, res)
{
	if (req.body.logout == '1')
	{
		global.session.logged_in = 0;
		req.session.logged_in = 0;
		global.session.destroy();
		res.redirect(req.body.location);
	}

	res.render('index', { title: website_title });
};

exports.login = function(req, res)
{
	var success = -1; //-1 = hasn't tried logging in yet; 0 = fail; 1 = pass;

	function result(success, user, group, location)
	{
		if (success == 1)
		{
			if (location == undefined)
				res.redirect('/');
			else
				res.redirect(location);
		}
		else
			res.render('login', { title: website_title, logged_in: success});
	}

	if (req.body.username != undefined || req.body.password != undefined)
	{
		// location argument allows us to return to the page we were on when we tried to logon.
		login.check_credentials(req.body.username, req.body.password, result, req.body.location);
	}
	else //user hasn't tried to login yet. logged_in should = -1 still
		result(success);
};

exports.sign_up = function(req, res)
{
	res.render('sign_up', { title: website_title, miss: req.query.miss });
};