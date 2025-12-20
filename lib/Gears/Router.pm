package Gears::Router;

use v5.40;
use Mooish::Base -standard;

has param 'location_impl' => (
	isa => Str,
	default => 'Gears::Router::Location::Match',
);

with qw(Gears::Router::Proto);

sub pattern ($self)
{
	return '';
}

sub match ($self, $request_path)
{
	my @locations = $self->locations->@*;
	my @matched;

	while (@locations > 0) {
		my $loc = shift @locations;
		next unless $loc->pattern_obj->compare($request_path);
		push @matched, $loc;
		unshift @locations, $loc->locations->@*;
	}

	return @matched;
}

sub clear ($self)
{
	$self->locations->@* = ();
}

