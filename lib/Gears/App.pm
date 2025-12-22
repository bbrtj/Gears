package Gears::App;

use v5.40;
use Mooish::Base -standard;

use Gears qw(load_package get_component_name);
use Gears::X;

has param 'controllers_base' => (
	isa => Str,
	writer => 1,
	builder => 1,
);

has field 'controllers' => (
	isa => ArrayRef [InstanceOf ['Gears::Controller']],
	writer => -hidden,
);

has param 'router' => (
	isa => InstanceOf ['Gears::Router'],
);

sub _build_controllers_base ($self)
{
	return (ref $self) . '::Controller';
}

sub set_controllers ($self, @list)
{
	my $base = $self->controllers_base;
	my @controllers;

	foreach my $name (@list) {
		my $class = get_component_name($name, $base);
		push @controllers, load_package($class)->new(app => $self);
	}

	$self->_set_controllers(\@controllers);
	return;
}

sub BUILD ($self, $)
{
	$self->build;
}

sub build ($self)
{
}

