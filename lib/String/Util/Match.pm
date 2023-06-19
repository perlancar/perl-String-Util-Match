package String::Util::Match;

use strict;
use warnings;

use Exporter qw(import);

# AUTHORITY
# DATE
# DIST
# VERSION

our @EXPORT_OK = qw(
                       match_array_or_regex
               );

our %SPEC;

$SPEC{':package'} = {
    v => 1.1,
    summary => 'String utilities related to matching',
};

my $_str_or_re = ['any*'=>{of=>['re*','str*']}];

$SPEC{match_array_or_regex} = {
    v => 1.1,
    summary => 'Check whether an item matches (list of) values/regexes',
    description => <<'_',

This routine can be used to match an item against a regex or a list of
strings/regexes, e.g. when matching against an ACL.

Since the smartmatch (`~~`) operator can already match against a list of strings
or regexes, this function is currently basically equivalent to:

    if (ref($haystack) eq 'ARRAY') {
        return $needle ~~ @$haystack;
    } else {
        return $needle =~ /$haystack/;
    }

except that the smartmatch operator covers more cases and is currently
deprecated in the current perl versions and might be removed in future versions.

_
    examples => [
        {args=>{needle=>"abc", haystack=>["abc", "abd"]}, result=>1},
        {args=>{needle=>"abc", haystack=>qr/ab./}, result=>1},
        {args=>{needle=>"abc", haystack=>[qr/ab./, "abd"]}, result=>1},
    ],
    args_as => 'array',
    args => {
        needle => {
            schema => ["str*"],
            pos => 0,
            req => 1,
        },
        haystack => {
            # XXX checking this schema might actually take longer than matching
            # the needle! so when arg validation is implemented, provide a way
            # to skip validating this schema

            schema => ["any*" => {
                of => [$_str_or_re, ["array*"=>{of=>$_str_or_re}]],
            }],
            pos => 1,
            req => 1,
        },
    },
    result_naked => 1,
};
sub match_array_or_regex {
    my ($needle, $haystack) = @_;
    my $ref = ref($haystack);
    if ($ref eq 'ARRAY') {
        for (@$haystack) {
            if (ref $_ eq 'Regexp') {
                return 1 if $needle =~ $_;
            } else {
                return 1 if $needle eq $_;
            }
        }
        return 0;
    } elsif (!$ref) {
        return $needle =~ /$haystack/;
    } elsif ($ref eq 'Regexp') {
        return $needle =~ $haystack;
    } else {
        die "Invalid haystack, must be regex or array of strings/regexes";
    }
}

1;
# ABSTRACT:

=head1 SYNOPSIS

 use String::Util::Match qw(match_array_or_regex);

 match_array_or_regex('bar',  ['foo', 'bar', qr/[xyz]/]); # true, matches string
 match_array_or_regex('baz',  ['foo', 'bar', qr/[xyz]/]); # true, matches regex
 match_array_or_regex('oops', ['foo', 'bar', qr/[xyz]/]); # false


=head1 DESCRIPTION
