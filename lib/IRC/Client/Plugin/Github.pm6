#! /usr/bin/env false

use v6.c;

use Config;
use IRC::Client;

class IRC::Client::Plugin::Github
{
	has Config $.config;

	method irc-connected($)
	{
		start {
			# Set up the web hook for Github notification POSTs
			post "/" => sub {
				my Str $event = request.headers<X_GITHUB_EVENT>.wordcase;
				my Str $module = "IRC::Client::Plugin::Github::WebhookEvents::$event";

				require ::($module);

				::($module).handle(
					bot => $,
					config => $!config,
					request => request
				);
			};

			# Configure Bailador
			set("host", $!config.get("github.webhook.host", "0.0.0.0"));
			set("port", $!config.get("github.webhook.port", 8000));

			# Start Bailador
			baile();
		};
	}
}
