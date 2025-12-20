package Gears::Logger;

use v5.40;
use Mooish::Base -standard;

use Data::Dumper;
use Time::Piece;

# apache format
has param 'date_format' => (
	isa => Str,
	default => '%a %b %d %T %Y'
);

# apache-like format
has param 'log_format' => (
	isa => Str,
	default => '[%s] [%s] %s'
);

sub _build_message ($self, $level, $message)
{
	return sprintf $self->log_format,
		localtime->strftime($self->date_format),
		$level,
		ref $message ? Dumper($message) : $message
		;
}

sub _log_message ($self, $message)
{
	say $message;
}

sub message ($self, $level, @messages)
{
	$self->_log_message($self->_build_message($level, $_))
		for @messages;

	return $self;
}

