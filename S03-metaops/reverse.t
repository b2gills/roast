use v6;
use Test;

plan 46;

=begin pod

=head1 DESCRIPTION

This test tests the C<R...> reverse metaoperator.

=end pod

# Try mulitple versions of Rcmp, as it is one of the more
# more useful reversed ops, and if it works, probably
# most of the others will work as well.

is 4 Rcmp 5, 5 cmp 4, "4 Rcmp 5";
isa-ok 4 Rcmp 5, (5 cmp 4).WHAT, "4 Rcmp 5 is the same type as 5 cmp 4";
is 4.3 Rcmp 5, 5 cmp 4.3, "4.3 Rcmp 5";
isa-ok 4.3 Rcmp 5, (5 cmp 4.3).WHAT, "4.3 Rcmp 5 is the same type as 5 cmp 4.3";
is 4.3 Rcmp 5.Num, 5.Num cmp 4.3, "4.3 Rcmp 5.Num";
isa-ok 4.3 Rcmp 5.Num, (5.Num cmp 4.3).WHAT, "4.3 Rcmp 5.Num is the same type as 5.Num cmp 4.3";
is 4.3i Rcmp 5.Num, 5.Num cmp 4.3i, "4.3i Rcmp 5.Num";
isa-ok 4.3i Rcmp 5.Num, (5.Num cmp 4.3i).WHAT, "4.3i Rcmp 5.Num is the same type as 5.Num cmp 4.3i";

# Try to get a good sampling of math operators

is 4 R+ 5, 5 + 4, "4 R+ 5";
isa-ok 4 R+ 5, (5 + 4).WHAT, "4 R+ 5 is the same type as 5 + 4";
is 4 R- 5, 5 - 4, "4 R- 5";
isa-ok 4 R- 5, (5 - 4).WHAT, "4 R- 5 is the same type as 5 - 4";
is 4 R* 5, 5 * 4, "4 R* 5";
isa-ok 4 R* 5, (5 * 4).WHAT, "4 R* 5 is the same type as 5 * 4";
is 4 R/ 5, 5 / 4, "4 R/ 5";
isa-ok 4 R/ 5, (5 / 4).WHAT, "4 R/ 5 is the same type as 5 / 4";
is 4 Rdiv 5, 5 div 4, "4 Rdiv 5";
isa-ok 4 Rdiv 5, (5 div 4).WHAT, "4 Rdiv 5 is the same type as 5 div 4";
is 4 R% 5, 5 % 4, "4 R% 5";
isa-ok 4 R% 5, (5 % 4).WHAT, "4 R% 5 is the same type as 5 % 4";
is 4 R** 5, 5 ** 4, "4 R** 5";
isa-ok 4 R** 5, (5 ** 4).WHAT, "4 R** 5 is the same type as 5 ** 4";

# and a more or less random sampling of other operators

is 4 R< 5, 5 < 4, "4 R< 5";
isa-ok 4 R< 5, (5 < 4).WHAT, "4 R< 5 is the same type as 5 < 4";
is 4 R> 5, 5 > 4, "4 R> 5";
isa-ok 4 R> 5, (5 > 4).WHAT, "4 R> 5 is the same type as 5 > 4";
is 4 R== 5, 5 == 4, "4 R== 5";
isa-ok 4 R== 5, (5 == 4).WHAT, "4 R== 5 is the same type as 5 == 4";
is 4 Rcmp 5, 5 cmp 4, "4 Rcmp 5";
isa-ok 4 Rcmp 5, (5 cmp 4).WHAT, "4 Rcmp 5 is the same type as 5 cmp 4";

# precedence tests!
is 3 R/ 9 + 5, 8, 'R/ gets precedence of /';
is 4 R- 5 R/ 10, -2, "Rop gets the precedence of op";
is (9 R... 1, 3), (1, 3, 5, 7, 9), "Rop gets list_infix precedence correctly";

# RT #93350
throws-like '("a" R~ "b") = 1', X::Assignment::RO, 'Cannot assign to return value of R~';

# RT #77114
{
    throws-like '1 R= my $x', X::Syntax::CannotMeta, "R doesn't handle assignment";
}

# RT #118793
{
    throws-like { EVAL q[my $x; 5 R:= $x] }, Exception,
        message => 'Cannot reverse the args of := because list assignment operators are too fiddly',
        'adequate error message on trying to metaop-reverse binding (:=)';
}

# RT #116649
{
    my $y = 5;
    is $y [R/]= 1, 1/5, '[R/]= works correctly (1)';
    sub r2cf(Rat $x is copy) {
        gather $x [R/]= 1 while ($x -= take $x.floor) > 0
    }
    is r2cf(1.4142136).join(" "), '1 2 2 2 2 2 2 2 2 2 6 1 2 4 1 1 2',
        '[R/]= works correctly (2)';
}

{
    my $foo = "foo";
    $foo [R~]= "bar";
    is $foo, "barfoo", '[Rop]= works correctly.';
}

# RT #118791
#?rakudo todo 'RT #118791 Rxx does not yet thunk the RHS'
{
    my @a = 5 Rxx rand;
    ok !([==] @a), "Rxx thunks the RHS";
}

throws-like '3 R. foo', X::Syntax::CannotMeta, "R. is too fiddly";
throws-like '3 R. "foo"', X::Obsolete, "R. can't do P5 concat";

is &infix:<R/>(1,2), 2, "Meta reverse R/ can autogen";
is &infix:<RR/>(1,2), 0.5, "Meta reverse RR/ can autogen";

sub infix:<op> ($a,$b) { $a - $b }
{
    sub infix:<op> ($a,$b) { $a ** $b }
    is &infix:<Rop>(2,3), 9, "Meta reverse Rop can autogen with user-defined op";
}
is &infix:<Rop>(2,3), 1, "Meta reverse Rop autogen with user-overridden op stays local to block";

# vim: ft=perl6
