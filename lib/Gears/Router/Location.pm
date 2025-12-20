package Gears::Router::Location;

use v5.40;
use Mooish::Base -standard;

use Gears qw(load_package);

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

