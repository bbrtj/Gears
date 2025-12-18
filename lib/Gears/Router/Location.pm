package Gears::Router::Location;

use v5.40;
use Mooish::Base -standard;

has param 'parent' => (
	isa => ConsumerOf ['Gears::Router::Proto'],
	weak_ref => 1,
);

has param 'path' => (
	isa => Str,
);

has field '_regex' => (
	lazy => 1,
);

with qw(
	Gears::Router::Proto
);

sub _build_router ($self)
{
	return $self->parent->router;
}

# build simple regex that matches the string
sub _build_regex ($self)
{
	my $path = $self->path;

	# it is a bridge if it has children
	if ($self->locations->@*) {
		return qr/^\Q$path\E/;
	}
	else {
		return qr/^\Q$path\E$/;
	}
}

sub matches ($self, $request_path)
{
	return $request_path =~ $self->_regex;
}

around 'match' => sub ($orig, $self, $request_path) {
	if ($self->matches($request_path)) {
		my $result = $orig->($request_path);
		push $result->@*, $self;
		return $result;
	}

	return [];
};

