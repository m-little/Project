var sys = require('sys');
var exec = require('child_process').exec;

exports.email = function(to, subject, plain, body, callback)
{
	var from = 'cooking-site.notreply@cookingwebsite.com';
	var content_type = 'text/html';
	if (plain)
		content_type = 'text/plain';

	var child = exec("echo -e 'FROM : " + from + "\nTo : " + to + "\nSubject : " + subject + "\nContent-Type : " + content_type + "\n" + body + "' | sendmail -t", output);

	function output(error, stdout, stderr)
	{
		if (error !== null)
		{
			callback(false);
			console.error("Could not send email.");
			console.error(error);
		}
		else
			callback(true);
	}
}