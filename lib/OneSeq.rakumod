# Hopefully part of Raku core at some point
use nqp;

my class ForwardIterators does Iterator {
    has $!iterables is built;
    has $!current;

    method new(@iterables) {
        if @iterables.elems {  # reifies
            my $iterables := nqp::getattr(@iterables,List,'$!reified');
            my $self      := nqp::create(self);
            nqp::bindattr($self,self,'$!iterables',$iterables);
            nqp::bindattr($self,self,'$!current',
              nqp::shift($iterables).iterator);
            $self
        }
        else {
            ().iterator
        }
    }

    method pull-one() is raw {
        my $pulled := $!current.pull-one;
        if nqp::eqaddr($pulled,IterationEnd) && nqp::elems($!iterables) {
            $!current := nqp::shift($!iterables).iterator;
            return self.pull-one;  # recurse to handle exhaustion
        }

        $pulled
    }

    method push-all(\target --> IterationEnd) {
        $!current.push-all(target);

        my $iterables := $!iterables;
        nqp::while(
          nqp::elems($iterables),
          nqp::shift($iterables).iterator.push-all(target)
        );
    }
}

my class ReverseIterator does Iterator {
    has     $!reified;
    has int $!i;

    method new($iterable) {
        $iterable.iterator.push-all(
          my $reified := nqp::create(IterationBuffer)
        );

        my $self := nqp::create(self);
        nqp::bindattr(  $self,self,'$!reified',$reified);
        nqp::bindattr_i($self,self,'$!i',nqp::elems($reified));
        $self
    }

    method pull-one() is raw {
        $!i
          ?? nqp::atpos($!reified,--$!i)
          !! IterationEnd
    }

    method push-all(\target --> IterationEnd) {
        my $reified = $!reified;
        my int $i   = $!i;

        target.push($reified.AT-POS(--$i)) while $i;
    }
}

my class ReverseIterators does Iterator {
    has $!iterables;
    has $!current;

    method new(@iterables) {
        if @iterables.elems {  # reifies
            my $iterables := nqp::getattr(@iterables,List,'$!reified');
            my $self      := nqp::create(self);
            nqp::bindattr($self,self,'$!iterables',$iterables);
            nqp::bindattr($self,self,'$!current',$self!next);
            $self
        }
        else {
            ().iterator
        }
    }

    method !next() { ReverseIterator.new(nqp::pop($!iterables)) }

    method pull-one() is raw {
        my $pulled := $!current.pull-one;
        if nqp::eqaddr($pulled,IterationEnd) && nqp::elems($!iterables) {
            $!current := self!next;
            return self.pull-one;  # recurse to handle exhaustion
        }

        $pulled
    }

    method push-all(\target --> IterationEnd) {
        $!current.push-all(target);

        my $iterables := $!iterables;
        nqp::while(
          nqp::elems($iterables),
          self!next.push-all(target)
        );
    }
}

my sub infix:«>>>»(**@iterables) is export is assoc<list> is equiv(&[~]) {
    Seq.new: ForwardIterators.new(@iterables)
}

my sub infix:«<<<»(**@iterables) is export is assoc<list> is equiv(&[~]) {
    Seq.new: ReverseIterators.new(@iterables)
}

=begin pod

=head1 NAME

OneSeq - turn two or more Iterables into a single Seq

=head1 SYNOPSIS

=begin code :lang<raku>

use OneSeq;

my @a = ^5;
my @b = @a >>> @a;
say @b;  # (0 1 2 3 4 0 1 2 3 4)

my @c = @a <<< @a;
say @c;  # (4 3 2 1 0 4 3 2 1 0)

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

And it does B<NOT> recurse into any C<Iterable> values that it
encounters, so in that aspect it is B<NOT> like C<flat>.

=head2 >>>

The infix C«>>>» operator takes any number of arguments (usually
C<Iterable> objects), takes the B<first> argument and calls the
C<.iterator> method on it, then then produces the values for that
iterator until exhausted, and then switches to the next argument.
Until there are no arguments left.

=head2 <<<

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
