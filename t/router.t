use Test2::V1 -ipP;
use Gears::Router;

################################################################################
# This tests whether the basic router works
################################################################################

my $r = Gears::Router->new;

subtest 'router should produce valid locations' => sub {
	$r->clear;
	my $loc1 = $r->add('/test');
	my $loc2 = $loc1->add('/deep');

	is $loc1->pattern, '/test', 'bridge ok';
	is $loc2->pattern, '/test/deep', 'location ok';

	is $loc2->build, '/test/deep', 'build method works';
};

subtest 'router should match locations' => sub {
	$r->clear;

	my $t1 = $r->add('/test1');
	my $t1l1 = $t1->add('/1');
	my $t1l2 = $t1->add('/11');
	my $t1l3 = $t1->add('/12');

	my $t2 = $r->add('/test2');
	my $t2l1 = $t2->add('');
	my $t2l2 = $t2->add('/1');

	my $t2f = $r->add('/test2/1');

	is [$r->match('/test')], [], 'bad match ok';
	is [$r->match('/test1')], [map { exact_ref $_ } $t1], 'match bridge ok';
	is [$r->match('/test1/1')], [map { exact_ref $_ } $t1, $t1l1], 'match full path ok';
	is [$r->match('/test1/123')], [map { exact_ref $_ } $t1], 'match too long path ok';

	is [$r->match('/test2')], [map { exact_ref $_ } $t2, $t2l1], 'match empty subpath ok';
	is [$r->match('/test2/1')], [map { exact_ref $_ } $t2, $t2l2, $t2f], 'match across locations ok';
};

done_testing;

