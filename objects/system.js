var sys = require('sys');
var exec = require('child_process').exec;

exports.email = function(to, subject, plain, body, callback)
{
	var from = 'cooking-site.notreply@cookingwebsite.com';
	var content_type = 'text/html';
	if (plain)
		content_type = 'text/plain';

	var child = exec("echo 'FROM : " + from + "\nTo: " + to + "\nSubject : " + subject + "\nContent-Type : " + content_type + "\n" + body + "\n\n.' > .temp_email.txt; cat .temp_email.txt | sendmail -t; rm .temp_email.txt;", output);
	// var child = exec("../system/email.sh " + to + " " + subject + " " + content_type + " " + body, output);
	// console.log("echo -e 'FROM : " + from + "\\nTO: " + to + "\\nSubject : " + subject + "\\nContent-Type : " + content_type + "\\n" + body + "\\n\\n.' | sendmail -t");

	function output(error, stdout, stderr)
	{
		console.log(stdout);
		console.error(stderr);

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