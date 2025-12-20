package Gears::Router::Pattern;

use v5.40;
use Mooish::Base -standard;

has param 'location' => (
	isa => InstanceOf ['Gears::Router::Location'],
	weak_ref => 1,
);

sub compare ($self, $request_path)
{
	my $pattern = $self->location->pattern;

	# it is a bridge if it has children
	if ($self->location->locations->@*) {
		return $request_path =~ m/^\Q$pattern\E/;
	}
	else {
		return $request_path eq $pattern;
	}

}

sub build ($self, @more_args)
{
	return $self->location->pattern;
}

