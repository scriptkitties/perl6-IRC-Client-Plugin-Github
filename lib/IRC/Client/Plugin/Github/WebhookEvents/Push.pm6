#! /usr/bin/env false

use v6.c;

use Bailador;
use Config;
use IRC::Client;
use JSON::Fast;

sub IRC::Client::Plugin::Github::WebhookEvents::Push (
	IRC::Client :$bot,
	Config :$config,
	Bailador::Request :$request
) is export {
	my %body = from-json($request.body);
	my $user = %body<pusher><name>;
	my $commits = %body<commits>.elems;
	my $repo = %body<repository><name>;
	my $branch = %body<ref>.Str.subst("refs/heads", "");
	my $old = %body<before>.Str.substr(0, 7);
	my $new = %body<after>.Str.substr(0, 7);
	my $commitString = "commit";

	if ($commits != 1) {
		$commitString ~= "s";
	}

	$bot.irc.send(
		:where("#scriptkitties")
		:text("$user pushed $commits new $commitString to {$repo}{$branch} ($old..$new)")
		:notice
	);

	"";
}
