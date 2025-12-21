package Gears::Router::Pattern::SigilMatch;

use v5.40;
use Mooish::Base -standard;

use Gears::X;

extends 'Gears::Router::Pattern';

has extended 'location' => (
	handles => [
		qw(
			checks
			defaults
		)
	],
);

has field '_regex' => (
	isa => RegexpRef,
	lazy => 1,
);

has field 'tokens' => (
	isa => ArrayRef,
	default => sub { [] },
);

# helpers for matching different types of wildcards
my sub noslash ($sigil)
{
	return 1 == grep { $sigil eq $_ } ':', '?';
}

my sub matchall ($sigil)
{
	return 1 == grep { $sigil eq $_ } '*', '>';
}

my sub optional ($sigil)
{
	return 1 == grep { $sigil eq $_ } '?', '>';
}

sub _rep_regex
{
	my ($self, $char, $switch, $token, $out) = @_;
	my $qchar = quotemeta $char;
	my $re;

	push $self->tokens->@*, {
		sigil => $switch,
		label => $token,
	};

	my ($prefix, $suffix) = ("(?<$token>", ')');
	if (noslash($switch)) {
		$re = $qchar . $prefix . ($self->checks->{$token} // '[^\/]+') . $suffix;
	}
	elsif (matchall($switch)) {
		$re = $qchar . $prefix . ($self->checks->{$token} // '.+') . $suffix;
	}

	if (optional($switch)) {
		$re = "(?:$re)" if $char eq '/';
		$re .= '?';
	}

	push $out->@*, $re;
	return '{}';
}

sub _build_regex ($self)
{
	my $pattern = $self->pattern;

	my $placeholder_pattern = qr{
		( [^\0]? ) # preceding char, may change behavior of some placeholders
		( [:*?>] ) # placeholder sigil
		( \w+ )    # placeholder label
	}x;

	# Curly braces and brackets are only used for separation.
	# We replace all of them with \0, then convert the pattern
	# into a regular expression. This way if the regular expression
	# contains curlies, they won't be removed.
	$pattern =~ s/[{}]/\0/g;

	my @rep_regex_parts;
	$pattern =~ s{
		$placeholder_pattern
	}{
		$self->_rep_regex($1, $2, $3, \@rep_regex_parts)
	}egx;

	# Now remove all curlies remembered as \0 - We will use curlies again for
	# special behavior in a moment
	$pattern =~ s/\0//g;

	# remember if the pattern has a trailing slash before we quote it
	my $trailing_slash = $pattern =~ m{/$};

	# _rep_regex reused curies for {} placeholders, so we want to split the
	# string by that (and include them in the result by capturing the
	# separator)
	my @parts = split /(\Q{}\E)/, $pattern, -1;

	# If we have a placeholder, replace it with next part. If not, quote it to
	# avoid misusing regex in patterns.
	foreach my $part (@parts) {
		if ($part eq '{}') {
			$part = shift @rep_regex_parts;
		}
		else {
			$part = quotemeta $part;
		}
	}

	$pattern = join '', @parts;
	if ($self->is_bridge) {

		# bridge must be followed by a slash or end of string, so that:
		# - /test matches
		# - /test/ matches
		# - /test/something matches
		# - /testsomething does not match
		# if the bridge is already followed by a trailing slash, it's not a
		# concern
		$pattern .= '(?:/|$)' unless $trailing_slash;
	}
	else {

		# regular pattern must end immediately
		$pattern .= quotemeta('/') . '?' unless $trailing_slash;
		$pattern .= '$';
	}

	return qr{^$pattern};
}

sub BUILD ($self, $)
{
	$self->_regex;    # ensure tokens are created
}

sub compare ($self, $request_path)
{
	return undef unless $request_path =~ $self->_regex;

	# initialize the named parameters hash and its default values
	my %named = ($self->defaults->%*, %+);

	# transform into a list of parameters
	return [map { $named{$_->{label}} } $self->tokens->@*];
}

sub build ($self, %args)
{
	my $pattern = $self->pattern;
	my $checks = $self->checks;
	%args = ($self->defaults->%*, %args);

	foreach my $token ($self->tokens->@*) {
		my $value = $args{$token->{label}};
		my $optional = optional $token->{sigil};

		Gears::X->raise("no value for placeholder $token->{sigil}$token->{label}")
			unless defined $value || $optional;

		my $to_replace = qr{
			\Q$token->{sigil}\E
			$token->{label}
		}x;

		if (defined $value) {
			my $check = $checks->{$token->{label}};
			Gears::X->raise("bad value for placeholder $token->{sigil}$token->{label}")
				if $check && $value !~ /^$check$/;

			$pattern =~ s{\{?$to_replace\}?}{$value};
		}
		else {
			# slash should be removed as well for optional placeholders (if no brackets)
			$pattern =~ s{/$to_replace|\{?$to_replace\}?}{};
		}
	}

	return $pattern;
}

