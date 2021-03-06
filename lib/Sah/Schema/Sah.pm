package Sah::Schema::Sah;

use 5.010;
use strict;
use warnings;

our $VERSION = '0.9.31'; # VERSION
our $DATE = '2014-10-23'; # DATE

our %SCHEMAS;

$SCHEMAS{sah_type_name} = ['str' => {
    match => '\A[A-Za-z][A-Za-z0-9_]*(::[A-Za-z][A-Za-z0-9_]*)*\z',
}];

$SCHEMAS{sah_str_schema} = ['str' => {
    match => '\A[A-Za-z][A-Za-z0-9_]*(::[A-Za-z][A-Za-z0-9_]*)*\*?\z',
}];

$SCHEMAS{sah_clause_name} = undef; # TODO

$SCHEMAS{sah_clause_set} = [defhash => {
    # tmp
    _prop => {
        # from defhash
        v => {},
        defhash_v => {},
        name => {},
        summary => {},
        description => {},
        tags => {},
        default_lang => {},
        x => {},

        # incomplete
        clause => {
        },
        clset => {
        },
    },
}];

# XXX sah_num_clause_set (based on sah_clause_set)
# XXX sah_

$SCHEMAS{sah_extras} = [defhash => {
    _prop => {
        def => {},
    },
}];

$SCHEMAS{sah_array_schema} = ['array' => {
    elems => [
        'sah_type_name',
        'sah_clause_set',
        'sah_extras',
    ],
    min_len => 1,
}];

$SCHEMAS{sah_schema} = [any => {
    of => [
        'sah_str_schema',
        'sah_array_schema',
    ],
}];

1;
# ABSTRACT: Sah schemas for Sah schema

=pod

=encoding UTF-8

=head1 NAME

Sah::Schema::Sah - Sah schemas for Sah schema

=head1 VERSION

This document describes version 0.9.31 of Sah::Schema::Sah (from Perl distribution Sah), released on 2014-10-23.

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Sah>.

=head1 SOURCE

Source repository is at L<https://github.com/perlancar/perl-Sah>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Sah>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

perlancar <perlancar@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

__END__

# commented temporarily, unfinished refactoring
sub schemas {
    my $re_var_nameU   = '(?:[A-Za-z_][A-Za-z0-9_]*)'; # U = unanchored
    my $re_func_name   = '\A(?:'.$re_var_nameU.'::)*'.$re_var_nameU.'+\z';
    my $reu_var_name   = '(?:[A-Za-z_][A-Za-z0-9_]*)';
    my $re_clause_name = '\A(?:[a-z_][a-z0-9_]*)\z'; # no uppercase
    my $re_cattr_name  = '\A(?:'.$re_var_nameU.'\.)*'.$re_var_nameU.'+\z';
    my $re_clause_key  = ''; # XXX ':ATTR' or 'NAME' or 'NAME:ATTR'

    # R = has req=>1
    my $clause_setR = ['hash' => {
        keys_regex => $re_clause_key,
    }];

    my $str_schemaR = ['str*' => {

        # TODO: is_sah_str_shortcut
        #if => [not_match => $re_type_name, isa_sah_str_shortcut=>1],

        # for now, we don't support string shortcuts
        match => $re_type_name,
    }];

    # TODO: is_expr

    my $array_schemaR = ['array*' => {
        min_len    => 1,
        # the first clause set checks the type
        {
            elems => [$str_schemaR],
        },

        # the second clause set checks the clause set
        {
            # first we discard the type first
            prefilters => ['array_slice($_, 1)'],
            deps       => [
                # no clause sets, e.g. ['int']
                [[array => {len=>1}],
                 'any'], # do nothing, succeed

                # a single clause set, flattened in the array, but there are odd
                # number of elements, e.g. ['int', min=>1, 'max']
                [[array => {elems=>['str*'], check=>'array_len($_) % 2 != 0'}],
                 ['any', fail=>1,
                  err_msg=>'Odd number of elements in clause set']],

                # a single clause set, flattened in the array, with even number
                # of elements, e.g. ['int', min=>1, max=>10]
                [[array => {elems=>['str*']}],
                 $clause_setR],

                # otherwise, all elements must be a clause set
                 ['any',
                  [array => {of => $clause_setR}]],
            ] # END deps
        },

    }];

    # predeclare
    my $hash_schemaR = ['hash*' => undef];

    my $schema => ['any' => {
        of   => [qw/str array hash/],
        deps => [
            ['str*'   => $str_schemaR],
            ['array*' => $array_schemaR],
            ['hash*'  => $hash_schemaR],
        ],
    }];

    my $defR = ['hash*' => {
        keys_of   => ['str*' => {,
                                 # remove optional '?' suffix
                                 prefilters => [q(replace('[?]\z', '', $_))],
                                 match      => $re_type_name,
                             }],
        values_of => $schema,
    }];
