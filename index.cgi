#!/usr/bin/perl

use CGI;
use Date::Manip;
use Data::Dumper;
use List::Util 'shuffle';
use File::Basename;
my $Q = new CGI;
my $webroot = '/data/vhosts/stefan.cog-ent.com/comics/htdocs';
my $today = UnixDate(ParseDate('now'), '%Y%m%d');
my $date = $Q->path_info() || $today; $date =~ s@^/@@;
my $prev = UnixDate(DateCalc($date, "- 1 day"), '%Y%m%d');
my $first = '20030720';
my $random = basename ((shuffle(grep { -d $_ } glob("$webroot/2*")))[0]);
my $next = UnixDate(DateCalc($date, "+ 1 day"), '%Y%m%d');
my ($y,$m,$d) = ($date =~ /^(\d{4})(\d{2})(\d{2})$/);
my $datefull = UnixDate(ParseDate($date), '%A, %B %d, %Y');

my $comics = [
	{
		n => [qw/baby_blues babyblues/],
		name => "Baby Blues",
		link => "http://www.babyblues.com",
	},
	{
		n => [qw/beetle_bailey beetlebailey/],
		name => "Beetle Bailey",
		link => "http://beetlebailey.com/comics/december-$d-$y/",
	},
	{
		n => [qw/zits/],
		name => "Zits",
		link => "http://zitscomics.com/comics/december-$d-$y/",
	},
	{
		n => [qw/dilbert/],
		name => "Dilbert",
		link => "http://www.dilbert.com/$y-$m-$d",
	},
	{
		n => [qw/fox_trot foxtrot ft/],
		name => "Fox Trot",
		link => "http://www.gocomics.com/foxtrot/$y/$m/$d",
	},
	{
		n => [qw/frazz/],
		name => "Frazz",
		link => "http://www.gocomics.com/frazz/$y/$m/$d",
	},
	{
		n => [qw/get_fuzzy getfuzzy gf/],
		name => "Get Fuzzy",
		link => "http://www.gocomics.com/getfuzzy/$y/$m/$d",
	},
	{
		n => [qw/pearls_before_swine pearlsbeforeswine pearls pbs/],
		name => "Pearls Before Swine",
		link => "http://www.gocomics.com/pearls_before_swine/$y/$m/$d",
	},
];

print $Q->header, $Q->start_html('Comics');
if ( $download = $Q->param('download') ) {
	print qx{$webroot/comics.sh $download}, br;
}
my $stat = scalar localtime((stat("$webroot/$date"))[9]);
my $r = 0;
my $t = scalar @$comics;

my @comics;
foreach my $comic ( @$comics ) {
	my @img = grep { -f $_ && -s _ } map { glob("$webroot/$date/$_.*") } @{$comic->{n}};
	$r++ if $img[0];
	$img[0] =~ s/^$webroot//;
	push @comics, {
		n => $comic->{n}->[0],
		img => $img[0],
		name => $comic->{name},
		link => $comic->{link},
	};
}
	
print "Comics Date: <a href=\"/index.cgi/$date?download=$date\">$datefull</a>, click to redownload for this date<br />\n";
print "$r/$t comics last updated $stat<br /><br />\n";
my $menu = [
	[$first => "First Day"],
	[$random => "Random Day"],
	[$prev => "Previous Day"],
	[$next => "Next Day"],
	[$today => "Today"],
];
print join " | ", map { "<a href=/index.cgi/$_->[0]>$_->[1]</a>"} grep { -d "$webroot/$_->[0]" } @$menu;
print "<br /><br />\n";
print "<center>\n";
foreach ( @comics ) {
	if ( $_->{img} ) {
		print "<a href=\"$_->{link}\">" if $_->{link};
		print "<img src=\"$_->{img}\"><br /><br />\n";
		print "</a>" if $_->{link};
	} else {
		print "<a href=\"$_->{link}\">$_->{name}</a>" if $_->{link};
		print "<br />\n";
	}
}
print "</center>\n";
print join " | ", map { "<a href=/index.cgi/$_->[0]>$_->[1]</a>"} grep { -d "$webroot/$_->[0]" } @$menu;
