package Gears::App;

use v5.40;
use Mooish::Base -standard;

use Gears qw(load_component get_component_name);
use Gears::X;

extends 'Gears::Component';

has param 'controllers_base' => (
	isa => Str,
	builder => 1,
);

has param 'router' => (
	isa => InstanceOf ['Gears::Router'],
);

has param 'config' => (
	isa => InstanceOf ['Gears::Config'],
);

has field 'controllers' => (
	isa => ArrayRef [InstanceOf ['Gears::Controller']],
	writer => -hidden,
);

# we are the app
has extended 'app' => (
	default => sub ($self) { $self },
);

sub _build_controllers_base ($self)
{
	return (ref $self) . '::Controller';
}

sub _build_controller ($self, $class)
{
	return $class->new(app => $self);
}

sub set_controllers ($self, @list)
{
	my $base = $self->controllers_base;
	my @controllers;

	foreach my $name (@list) {
		my $class = get_component_name($name, $base);
		push @controllers, $self->_build_controller(load_component($class));
	}

	$self->_set_controllers(\@controllers);
	return;
}

