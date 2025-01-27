[![Actions Status](https://github.com/lizmat/OneSeq/actions/workflows/linux.yml/badge.svg)](https://github.com/lizmat/OneSeq/actions) [![Actions Status](https://github.com/lizmat/OneSeq/actions/workflows/macos.yml/badge.svg)](https://github.com/lizmat/OneSeq/actions) [![Actions Status](https://github.com/lizmat/OneSeq/actions/workflows/windows.yml/badge.svg)](https://github.com/lizmat/OneSeq/actions)

NAME
====

OneSeq - turn two or more Iterables into a single Seq

SYNOPSIS
========

```raku
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
```

DESCRIPTION
===========

The `OneSeq` distribution provides two infix operators: `>>>` and `<<<`, each of which produces a single `Seq` object from the given arguments.

Their functionality is similar to the [`flat`](https://docs.raku.org/routine/flat) method, but with the important distinction that it does **NOT** look at the containerization of the arguments. So any iterable such as a `Array` or `List` inside a `Hash` or an `Array`, **will** produce all of its values.

And it also does **NOT** recurse into any `Iterable` values that it encounters, so in that aspect it is **NOT** like `flat` at all.

infix >>>
---------

The infix `>>>` operator takes any number of arguments (usually `Iterable` objects), takes the **first** argument and calls the `.iterator` method on it, then then produces the values for that iterator until exhausted, and then switches to the next argument. Until there are no arguments left.

infix <<<
---------

The infix `<<<` operator takes any number of arguments (usually `Iterable` objects), takes the **last** argument and calls the `.iterator` method on it, then then produces the values for that iterator until exhausted **in reverse order**, and then switches to the previous argument. Until there are no arguments left.

PERFORMANCE
-----------

Depending on the situation, the use of these infix operators can be anywhere to 1.5x to 3x as fast as the equivalent code using `.flat`.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/OneSeq . Comments and Pull Requests are welcome.

If you like this module, or what I'm doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2024, 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

