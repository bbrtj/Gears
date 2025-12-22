package Gears::Router;

use v5.40;
use Mooish::Base -standard;

use Gears::Router::Match;

with qw(Gears::Router::Proto);

# this is the router
has extended 'router' => (
	init_arg => undef,
	default => sub ($self) { $self },
);

sub pattern ($self)
{
	return '';
}

sub _build_location ($self, %args)
{
	...;
}

sub _build_match ($self, $loc, $match_data)
{
	return Gears::Router::Match->new(
		location => $loc,
		matched => $match_data,
	);
}

sub _match_level ($self, $locations, @args)
{
	my @matched;
	foreach my $loc ($locations->@*) {
		next unless my $match_data = $loc->compare(@args);
		my $match = $self->_build_match($loc, $match_data);

		my $children = $loc->locations;
		if ($children->@* > 0) {
			push @matched, [$match, $self->_match_level($children, @args)];
		}
		else {
			push @matched, $match;
		}
	}

	return @matched;
}

sub match ($self, @args)
{
	return [$self->_match_level($self->locations, @args)];
}

sub flatten ($self, $matches)
{
	my @flat_matches;
	foreach my $match ($matches->@*) {
		if (ref $match eq 'ARRAY') {
			push @flat_matches, $self->flatten($match);
		}
		else {
			push @flat_matches, $match;
		}
	}

	return @flat_matches;
}

sub clear ($self)
{
	$self->locations->@* = ();
	return $self;
}

