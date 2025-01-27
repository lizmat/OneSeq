use ForwardIterables:ver<0.0.3+>:auth<zef:lizmat>;
use ReverseIterables:ver<0.0.1+>:auth<zef:lizmat>;

my sub infix:«>>>»(**@iterables) is export is assoc<list> is equiv(&[~]) {
    Seq.new: ForwardIterables.new(@iterables)
}

my sub infix:«<<<»(**@iterables) is export is assoc<list> is equiv(&[~]) {
    Seq.new: ReverseIterables.new(@iterables)
}

=begin pod

=head1 NAME

OneSeq - turn two or more Iterables into a single Seq

=head1 SYNOPSIS

=begin code :lang<raku>

use OneSeq;

my @a = ^5;
my @b = <a b c d e>;
my @c = @a >>> @b;
say @c;  # [0 1 2 3 4 a b c d e]

my @d = @a <<< @b;
say @d;  # [e d c b a 4 3 2 1 0]

# as a meta-op
my %h = a => [0,1,2], b => [3,4,5], c => [6,7,8,9];
my @e;
@e[$_] = $_ + 1 for [>>>] %h.values;
say @e;  # [1 2 3 4 5 6 7 8 9 10]

=end code

=head1 DESCRIPTION

C<OneSeq> is a module that provides two infix operators: C«>>>» and
C«<<<», each of which produces a single C<Seq> object from the
given arguments.

Their functionality is similar to the L<C<flat>|https://docs.raku.org/routine/flat>
method, but with the important distinction that it does B<NOT> look
at the containerization of the arguments.  So any iterable such as
a C<Array> or C<List> inside a C<Hash> or an C<Array>, B<will>
produce all of its values.

And it also does B<NOT> recurse into any C<Iterable> values that it
encounters, so in that aspect it is B<NOT> like C<flat> at all.

=head2 infix >>>

The infix C«>>>» operator takes any number of arguments (usually
C<Iterable> objects), takes the B<first> argument and calls the
C<.iterator> method on it, then then produces the values for that
iterator until exhausted, and then switches to the next argument.
Until there are no arguments left.

=head2 infix <<<

The infix C«<<<» operator takes any number of arguments (usually
C<Iterable> objects), takes the B<last> argument and calls the
C<.iterator> method on it, then then produces the values for that
iterator until exhausted B<in reverse order>, and then switches
to the previous argument.  Until there are no arguments left.

=head2 PERFORMANCE

Depending on the situation, the use of these infix operators can
be anywhere to 1.5x to 3x as fast as the equivalent code using
C<.flat>.

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/OneSeq . Comments and
Pull Requests are welcome.

If you like this module, or what I'm doing more generally, committing to a
L<small sponsorship|https://github.com/sponsors/lizmat/>  would mean a great
deal to me!

=head1 COPYRIGHT AND LICENSE

Copyright 2024 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
