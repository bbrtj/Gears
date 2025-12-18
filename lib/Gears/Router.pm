package Gears::Router;

use v5.40;
use Mooish::Base -standard;

has param 'location_impl' => (
	isa => ClassName->where(q{ $_->isa('Gears::Router::Location') }),
);

with qw(Gears::Router::Proto);

sub _build_router ($self)
{
	# we are the router
	return $self;
}

