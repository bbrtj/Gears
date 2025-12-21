package Gears::Router::Location::SigilMatch;

use v5.40;
use Mooish::Base -standard;

use Gears::Router::Pattern::SigilMatch;

extends 'Gears::Router::Location';

has param 'checks' => (
	isa => HashRef,
	default => sub { {} },
);

has param 'defaults' => (
	isa => HashRef,
	default => sub { {} },
);

sub _build_pattern_obj ($self)
{
	return Gears::Router::Pattern::SigilMatch->new(
		location => $self,
	);
}

