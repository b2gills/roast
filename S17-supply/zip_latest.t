use v6;
use lib 't/spec/packages';

use Test;
use Test::Tap;

plan 8;

for ThreadPoolScheduler.new, CurrentThreadScheduler -> $*SCHEDULER {
    diag "**** scheduling with {$*SCHEDULER.WHAT.perl}";

    {
        my $s1 = Supply.new;
        my $s2 = Supply.new;

        tap_ok $s1.zip-latest($s2, :with( &infix:<~> )),
          [<2a 2b 2c 3c 4c>],
          'zipping taps works with "latest"',
          :after-tap( {
              $s1.more(1);
              $s1.more(2);
              $s2.more('a');
              $s2.more('b');
              $s2.more('c');
              $s1.more(3);
              $s1.done();
              $s1.more(4);
              $s2.done();
          } );
    }

    {
        my $s1 = Supply.new;
        my $s2 = Supply.new;
        my $s3 = Supply.new;

        tap_ok Supply.zip-latest($s1, $s2, $s3, :with( &infix:<~> )),
          [<aaa aab abb bbb bcb bcc bcd>],
          'zipping three supplies works with "latest"',
          :after-tap( {
              $s1.more("ignored");
              $s1.more("ignored");
              $s2.more("ignored");
              $s1.more("ignored");
              $s2.more("a");
              $s1.more("a");
              $s3.more("a");
              $s3.more("b");
              $s2.more("b");
              $s1.more("b");
              $s1.done();
              $s2.more("c");
              $s3.more("c");
              $s2.done();
              $s3.more("d");
              $s3.done();
          } );
    }

    {
        my $s = Supply.for(1..10);
        my $z = Supply.zip-latest($s);
        ok $s === $z, 'zipping one supply is a noop with "latest"';
        tap_ok $z, [1..10], "noop rotor";
    }
}
