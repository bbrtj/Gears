package Gears::Test::Logger;

use v5.40;
use Mooish::Base -standard;

extends 'Gears::Logger';

has param 'log_dest' => (
	isa => ArrayRef,
);

sub _log_message ($self, $message)
{
	push $self->log_dest->@*, $message;
}

