#! /usr/bin/env false

use v6.c;

use Config;

unit module IRC::Client::Plugin::Github::WebhookEvents::PullRequest;

our sub IRC::Client::Plugin::Github::WebhookEvents::PullRequest (
	:%payload,
	Config :$config
) is export {
	my Str $user = %payload<sender><login>;
	my Str $repository = %payload<repository><name>;
	my Int $pr-number = %payload<pull_request><number>;
	my Str $title = %payload<pull_request><title>;

	given %payload<action> {
		when "opened" {
			"$user opened PR $repository#$pr-number ($title)";
		}
	}
}
