package Gears::Router::Proto;

use v5.40;
use Mooish::Base -standard, -role;

use Gears qw(load_package);

requires qw(
	pattern
);

has param 'router' => (
	isa => InstanceOf ['Gears::Router'],
	weak_ref => 1,
);

has field 'locations' => (
	isa => ArrayRef [InstanceOf ['Gears::Router::Location']],
	default => sub { [] },
);

sub add ($self, $pattern, %data)
{
	my $location = load_package($self->router->location_impl)->new(
		%data,
		router => $self->router,
		pattern => $self->pattern . $pattern,
	);

	push $self->locations->@*, $location;
	return $location;
}

sub match ($self, $request_path)
{
	my @matched;
	foreach my $location ($self->locations->@*) {
		push @matched, $location->match($request_path)->@*;
	}

	return \@matched;
}

