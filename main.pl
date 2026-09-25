use strict;
use warnings;
use feature 'say';

package Signal;

use strict;
use warnings;

use overload
    '+'   => 'combine',
    '*'   => 'amplify',
    '++'  => 'increment',
    '<=>' => 'compare',
    '""'  => 'to_string',
    'bool' => 'is_alive',
    fallback => 1;

sub new {
    my ($class, $name, $strength) = @_;

    die "Signal name is required\n"
        unless defined $name && length $name;

    die "Signal strength must be numeric\n"
        unless defined $strength
        && $strength =~ /^-?(?:\d+(?:\.\d*)?|\.\d+)$/;

    return bless {
        name     => $name,
        strength => 0 + $strength,
    }, $class;
}

sub name {
    my ($self) = @_;
    return $self->{name};
}

sub strength {
    my ($self) = @_;
    return $self->{strength};
}

sub combine {
    my ($self, $other, $swap) = @_;

    if (ref($other) && $other->isa('Signal')) {
        return Signal->new(
            $self->{name} . '+' . $other->{name},
            $self->{strength} + $other->{strength}
        );
    }

    return Signal->new(
        $self->{name},
        $self->{strength} + $other
    );
}

sub amplify {
    my ($self, $factor, $swap) = @_;

    if (ref($factor) && $factor->isa('Signal')) {
        return Signal->new(
            $self->{name} . '*' . $factor->{name},
            $self->{strength} * $factor->{strength}
        );
    }

    return Signal->new(
        $self->{name},
        $self->{strength} * $factor
    );
}

sub increment {
    my ($self) = @_;

    $self->{strength}++;

    return $self;
}

sub compare {
    my ($self, $other, $swap) = @_;

    my $other_strength =
        ref($other) && $other->isa('Signal')
        ? $other->{strength}
        : $other;

    return $swap
        ? $other_strength <=> $self->{strength}
        : $self->{strength} <=> $other_strength;
}

sub to_string {
    my ($self) = @_;

    return sprintf(
        "%s[%.2f]",
        $self->{name},
        $self->{strength}
    );
}

sub is_alive {
    my ($self) = @_;
    return $self->{strength} > 0;
}

package Garden;

use strict;
use warnings;

sub new {
    my ($class) = @_;

    return bless {
        signals => [],
    }, $class;
}

sub plant {
    my ($self, @signals) = @_;

    push @{$self->{signals}}, @signals;

    return $self;
}

sub strongest {
    my ($self) = @_;

    return undef unless @{$self->{signals}};

    my $strongest = $self->{signals}[0];

    for my $signal (@{$self->{signals}}[1 .. $#{$self->{signals}}]) {
        $strongest = $signal if $signal > $strongest;
    }

    return $strongest;
}

sub total {
    my ($self) = @_;

    return undef unless @{$self->{signals}};

    my $total = $self->{signals}[0];

    for my $signal (@{$self->{signals}}[1 .. $#{$self->{signals}}]) {
        $total = $total + $signal;
    }

    return $total;
}

sub pulse {
    my ($self) = @_;

    say "Signal Garden";
    say "=" x 50;

    for my $signal (@{$self->{signals}}) {
        my $state = $signal ? "alive" : "silent";

        printf "%-30s %s\n", "$signal", $state;
    }

    say "=" x 50;

    my $strongest = $self->strongest;
    my $total = $self->total;

    say "Strongest: $strongest" if defined $strongest;
    say "Combined:  $total" if defined $total;
}

package main;

my $kernel = Signal->new("kernel", 4.2);
my $network = Signal->new("network", 3.7);
my $database = Signal->new("database", 2.8);
my $container = Signal->new("container", 3.3);
my $silence = Signal->new("silence", 0);

say "Individual signals";
say "-" x 50;
say $kernel;
say $network;
say $database;
say $container;
say $silence;

say "\nCombining signals";
say "-" x 50;

my $infrastructure = $kernel + $network;
say "Infrastructure: $infrastructure";

my $backend = $database + $container;
say "Backend:        $backend";

my $system = $infrastructure + $backend;
say "System:         $system";

say "\nAmplification";
say "-" x 50;

my $amplified = $network * 2.5;
say "Network x2.5:   $amplified";

my $boosted = $kernel + 5;
say "Kernel +5:      $boosted";

say "\nMutation through ++";
say "-" x 50;

say "Before: $container";
$container++;
say "After:  $container";

say "\nComparison";
say "-" x 50;

say $kernel > $database
    ? "$kernel is stronger than $database"
    : "$database is stronger than $kernel";

say "\nBoolean overload";
say "-" x 50;

say $kernel
    ? "$kernel is alive"
    : "$kernel is silent";

say $silence
    ? "$silence is alive"
    : "$silence is silent";

say "\nGarden pulse";
say "-" x 50;

my $garden = Garden->new;

$garden->plant(
    $kernel,
    $network,
    $database,
    $container,
    $amplified
);

$garden->pulse;

say "\nSynthetic signal";
say "-" x 50;

my $synthetic =
    ($kernel + $network + $container) * 1.5;

say $synthetic;

say "\nThe garden continues.";
