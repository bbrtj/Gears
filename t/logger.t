use Test2::V1 -ipP;
use Gears::Logger;

use lib 't/lib';
use Gears::Test::Logger;

use autodie;

################################################################################
# This tests whether the basic logger works
################################################################################

subtest 'should output messages to stdout' => sub {
	my $logger = Gears::Logger->new;

	open my $fake_stdout, '>', \my $output;
	my $old_stdout = \*STDOUT;
	*STDOUT = $fake_stdout;

	$logger->message(info => 'test');

	*STDOUT = $old_stdout;
	close $fake_stdout;

	like $output, qr{^\[.+\] \[info\] test$}, 'message ok';
};

subtest 'should output messages to a custom location (subclass)' => sub {
	my @logs;
	my $logger = Gears::Test::Logger->new(log_dest => \@logs);

	$logger->message(error => 'custom test');
	is scalar @logs, 1, 'message logged';
	like $logs[0], qr{^\[.+\] \[error\] custom test$}, 'message ok';
};

done_testing;

