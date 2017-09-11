#! /usr/bin/env false

use v6.c;

use Bailador;
use Config;
use IRC::Client;
use JSON::Fast;

sub IRC::Client::Plugin::Github::WebhookEvents::Push (
	IRC::Client :$irc,
	Config :$config,
	Bailador::Request :$request
) is export {
	my %body = from-json($request.body);
	my Str $repository = %body<repository><full_name>;
	my Str $config-key = "github.webhook.repos.{$repository.subst("/", "-")}";
	my %repo-config = $config.get($config-key, {});

	if (!%repo-config) {
		if ($config.get("debug", False)) {
			say "No configuration found for $repository ($config-key)";
		}

		return "";
	}

	my Str $user = %body<pusher><name>;
	my Int $commits = %body<commits>.elems;
	my Str $branch = %body<ref>.Str.subst("refs/heads", "");
	my Str $old = %body<before>.Str.substr(0, 7);
	my Str $new = %body<after>.Str.substr(0, 7);
	my Str $commitString = "commit";

	if ($commits != 1) {
		$commitString ~= "s";
	}

	for %repo-config<channels>.unique {
		$irc.send(
			:where($_)
			:text("$user pushed $commits new $commitString to {$repository}{$branch} ($old..$new)")
			:notice
		);
	}

	"";
}
