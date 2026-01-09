use v5.40;
use Test2::V1 -ipP;
use Gears::Generator;
use Path::Tiny qw(path);

################################################################################
# This tests whether generator copies templates correctly
################################################################################

subtest 'should copy a template' => sub {
	my $generator = Gears::Generator->new(
		base_dir => 't',
		content_filters => [
			sub ($content) {
				return $content =~ s{TO_REMOVE\s*}{}r;
			},
		],
		name_filters => [
			sub ($name) {
				return $name =~ s{myapp}{generatedapp}r;
			}
		],
	);

	my $template = $generator->get_template('generator');
	is $template, [
		path('t/generator/myapp.pl'),
		path('t/generator/flat.txt'),
		path('t/generator/dir/nested.txt'),
		],
		'template files ok';

	my $tmp_dir = Path::Tiny->tempdir;
	$generator->generate('generator', $tmp_dir);

	ok !$tmp_dir->child('myapp.pl')->exists, 'old name changed ok';
	is $tmp_dir->child('generatedapp.pl')->slurp({binmode => ':encoding(UTF-8)'}),
		"some perl app\n", 'app content ok';
	is $tmp_dir->child('flat.txt')->slurp({binmode => ':encoding(UTF-8)'}),
		"file content\n", 'file content ok';
	is $tmp_dir->child('dir/nested.txt')->slurp({binmode => ':encoding(UTF-8)'}),
		"zażółć gęślą jaźń\n", 'unicode file content ok';
};

done_testing;

