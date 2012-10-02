var login = require('./login.js');

// Handling GET and POST data...
// req.query.blah = the GET variable named blah
// req.body.blah = the POST variable named blah

exports.index = function(req, res)
{
	if (req.query.logout == '1')
	{
		global.session.logged_in = 0;
		req.session.logged_in = 0;
		global.session.destroy();
	}

	res.render('index', { title: website_title });
};

exports.login = function(req, res)
{
	var success = -1; //-1 = hasn't tried logging in yet; 0 = fail; 1 = pass;

	function result(success, user, group)
	{
		if (success == 1)
			res.redirect('/');
		else
			res.render('login', { title: website_title, logged_in: success});
	}

	if (req.body.username != undefined || req.body.password != undefined)
	{
		login.check_credentials(req.body.username, req.body.password, result);
	}
	else //user hasn't tried to login yet. logged_in should = -1 still
		result(success);
};

exports.sign_up = function(req, res)
{
	res.render('sign_up', { title: website_title, miss: req.query.miss });
};