use v5.40;
use Test2::V1 -ipP;
use Gears::Logger;

################################################################################
# This tests whether the basic logger works
################################################################################

package Gears::Test::Logger {
	use Mooish::Base -standard;

	extends 'Gears::Logger';

	has param 'log_dest' => (
		isa => ArrayRef,
	);

	sub _log_message ($self, $message)
	{
		push $self->log_dest->@*, $message;
	}
}

subtest 'should output string messages' => sub {
	my @logs;
	my $logger = Gears::Test::Logger->new(log_dest => \@logs);

	$logger->message(error => 'custom test');
	is scalar @logs, 1, 'message logged';
	like $logs[0], qr{^\[.+\] \[error\] custom test$}, 'message ok';
};

subtest 'should output ref messages' => sub {
	my @logs;
	my $logger = Gears::Test::Logger->new(log_dest => \@logs);

	$logger->message(error => ['test1', 'test2']);
	is scalar @logs, 1, 'message logged';
	like $logs[0], qr{^\[.+\] \[error\] \$VAR1 = \[\v\s*'test1'}, 'message ok';
};

done_testing;

