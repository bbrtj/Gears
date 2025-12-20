package Gears::Router;

use v5.40;
use Mooish::Base -standard;

has param 'location_impl' => (
	isa => Str,
	default => 'Gears::Router::Location',
);

has param 'pattern_impl' => (
	isa => Str,
	default => 'Gears::Router::Pattern',
);

with qw(Gears::Router::Proto);

has extended 'router' => (
	default => sub ($self) { return $self },
);

sub pattern ($self)
{
	return '';
}

