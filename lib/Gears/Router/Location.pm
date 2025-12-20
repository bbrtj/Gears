package Gears::Router::Location;

use v5.40;
use Mooish::Base -standard;

use Gears qw(load_package);

has param 'parent' => (
	isa => ConsumerOf ['Gears::Router::Proto'],
	weak_ref => 1,
);

has param 'pattern' => (
	isa => Str,
);

has field '_pattern_obj' => (
	isa => InstanceOf ['Gears::Router::Pattern'],
	lazy => 1,
);

with qw(
	Gears::Router::Proto
);

sub _build_pattern_obj ($self)
{
	return load_package($self->router->pattern_impl)->new(
		location => $self,
	);
}

sub _build_router ($self)
{
	return $self->parent->router;
}

around match => sub ($orig, $self, $request_path) {
	if ($self->_pattern_obj->compare($request_path)) {
		my $result = $self->$orig($request_path);
		unshift $result->@*, $self;
		return $result;
	}

	return [];
};

sub build ($self, @more_args)
{
	return $self->_pattern_obj->build(@more_args);
}

