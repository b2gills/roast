use v6;

use MONKEY-TYPING;

use Test;

plan 59;

=begin description

Enum tests from L<S12/Enumerations>

=end description

# L<S12/Enumerations/keys are specified as a parenthesized list>
enum day <Sun Mon Tue Wed Thu Fri Sat>;

is day.gist, '(day)', 'enum itself stringififes';
ok day.WHAT === day,  'enum.WHAT returned a value';
ok day.perl, 'enum.perl returned a value';

#?DOES 12
sub test_stuff($x) {
  #?niecza skip 'No candidates for dispatch to infix:<does>'
  does-ok $x, day::Tue,    "basic enum mixing worked ($x-2)";
  is $x.day, 2,            "automatically created accessor worked ($x)";
  is day::Tue, 2,          "enum provided a correct mapping ($x)";
  ok $x ~~ day,            "smartmatch worked correctly ($x-1)";
  ok $x ~~ Tue,            "smartmatch worked correctly ($x-2)";
  ok $x ~~ day::Tue,       "smartmatch worked correctly ($x-3)";
  ok $x !~~  Wed,          "smartmatch worked correctly ($x-4)";
  #?niecza skip 'No candidates for dispatch to infix:<does>'
  ok $x.does(Tue),         ".does worked correctly ($x-1)";
  #?niecza skip 'No candidates for dispatch to infix:<does>'
  does-ok $x, day,         ".does worked correctly ($x-2)";
  ok $x.Tue,               ".Tue() worked correctly ($x)";
  ok $x.Tue.WHAT === day,  '$obj.Tue.WHAT returns the proper type object';
  ok $x.Tue.perl,          '$obj.Tue.perl returns a true valuee';
}

#?rakudo skip 'NYI RT #124829'
{
  my $x = 1;
  is $x, 1, "basic sanity (1)";
  # L<S12/Enumerations/on the right side of a but or does.>
  #?niecza skip 'No candidates for dispatch to infix:<does>'
  ok $x does day(Tue), "basic enum mixing worked (1-1)";
  test_stuff($x);
}


#?rakudo skip 'does day::Tue RT #124830'
{
  my $x = 3;
  is $x, 3, "basic sanity (3)";
  ok $x does day::Tue, "basic enum mixing worked (3-1)";
  test_stuff($x);
}

#?rakudo skip 'does &day::("Tue") RT #124831'
{
  my $x = 4;
  is $x, 4, "basic sanity (4)";
  # L<S12/Enumerations/Mixing in the full enumeration type produces a
  # read-write attribute>
  ok $x does day,            "basic enum mixing worked (4-0)";
  ok $x.day = &day::("Tue"), "basic enum mixing worked (4-1)";
  test_stuff($x);
}

# used to be Rakudo regression, RT #64098
{
    augment class Mu {
        method f { 'inMu' };
    }

    augment class Bool {
        method f { 'inBool' };
    }
    is True.f, 'inBool', 'method on short name pick up the one from the enum';
    is Bool::True.f, 'inBool', 'method on long name pick up the one from the enum';
}

ok True.perl ~~/^ 'Bool::True'/, 'True.perl';
ok Bool::True.perl ~~/^ 'Bool::True'/, 'Bool::True.perl';

{
    enum Negation << :isnt<isnt> :arent<arent> :amnot<amnot> :aint<aint> >>;
    my Negation $foo;
    lives-ok { $foo = Negation::isnt }, 'simple assignment from enum';
    is $foo, Negation::isnt, 'assignment from enum works';
}

# RT #66886
{
    enum RT66886 <b>;
    throws-like 'RT66886::c', Exception, 'accessing non-value of enum dies proper-like';
}

# RT #65658
{
    enum RT65658 <Todo Bug Feature Ticket>;
    is RT65658(2), RT65658::Feature, 'can index enum by number';
    is RT65658((Todo + 3.2).Int), RT65658::Ticket, 'enum and math and index';
}

# RT #71196
{
    #?niecza skip 'Two terms in a row'
    eval-lives-ok 'enum X is export <A B C>', 'marking enum export does not die';
}

# RT #101900
#?rakudo todo 'RT #101900'
{
    throws-like 'enum rt_101900 < a b >; class A { }; say A but rt_101900::a',
        Exception,
        "Cannot mixin an enum into a class";
}

# RT #125445
{
    my enum Bar <A B C>;
    ok B.can("value"), '.can(...) on an enum';
    ok B.^can("value"), '.^can(...) on an enum';
}

# vim: ft=perl6
