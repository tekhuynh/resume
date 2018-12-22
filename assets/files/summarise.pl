#!/usr/bin/perl

use strict;

# Function that returns grade for a given mark
sub grade {

    my $mark = shift;

    if ($mark >= 85) {
        return "HD - High Distinction";
    } elsif ($mark >= 75) {
        return "DN - Distinction";
    } elsif ($mark >= 65) {
        return "CR - Credit";
    } elsif ($mark >= 50) {
        return "PS - Pass";
    } elsif ($mark >= 46) {
        return "PC - Pass Conceded";
    } elsif ($mark > 0) {
        return "FL - Fail";
    }

    return "AF - Absent Fail";
}

# Define faculties we are interested in
my %faculties = (
    COMP  => [],
    MMAN  => [],
    MTRN  => [],
    OTHER => [],
);

my @subjects = ();
while (my $line = <STDIN>) {

    my ($period, $faculty, $code, $name, $credit, $mark) =
            $line =~ /(.{7})\s(.{4})(.{4})\s(.{30})\s{3}(\d+...)\s(\d+)/;

    my %subject = (
        period  => $period,
        faculty => $faculty,
        code    => $code,
        name    => $name,
        credit  => $credit,
        mark    => $mark,
    );

    push @subjects, \%subject;
}
@subjects = sort {
    $a->{period}.$a->{faculty}.$a->{code} cmp $b->{period}.$b->{faculty}.$b->{code}
} @subjects;

# Bucketing rules
for my $subject (@subjects) {
    if ($faculties{$subject->{faculty}}) {
        push @{$faculties{$subject->{faculty}}}, $subject;
    } elsif ($subject->{faculty} eq 'MECH' and $faculties{'MMAN'}) {
        push @{$faculties{'MMAN'}}, $subject;
    } else {
        push @{$faculties{OTHER}}, $subject;
    }
}

sub faculty {
    for my $faculty (keys %faculties) {

        print "# Summary for $faculty:\n";
        print "---------------------\n\n";

        my $width = 7 + 8 + 30 + 6 + 4 + 21 + 5*3 + 3;
        printf "| %-7s | %-8s | %-30s | %-5s | %-4s | %-21s |\n",
        "Period", "Code", "Name", "Units", "Mark", "Grade";
        printf "| %-7s | %-8s | %-30s | %-5s | %-4s | %-21s |\n",
        '-' x 7, '-' x 8, '-' x 30, '-' x 5, '-' x 4, '-' x 21;

        my $numsubjects  = 0;
        my $numfailed    = 0;
        my $totalcredits = 0;
        my $totalmarks   = 0;

        my @subjects = @{$faculties{$faculty}};
        for my $subject (@subjects) {
            printf "| %-7s | %-4s%-4s | %-30s | %-5s | %-4s | %-21s |\n",
            $subject->{period},
            $subject->{faculty},
            $subject->{code},
            $subject->{name},
            $subject->{credit},
            $subject->{mark},
            grade($subject->{mark});

            $numsubjects  += 1;
            $numfailed    += 1 if $subject->{mark} < 46;
            $totalcredits += $subject->{credit};
            $totalmarks   += $subject->{mark} * $subject->{credit};


        }

        printf "\n```\n";
        printf "Number of subjects: %d\n", $numsubjects;
        printf "Number of fails   : %d\n", $numfailed;
        printf "Average mark      : %d\n", $totalmarks / $totalcredits;
        printf "Average grade     : %s\n", grade($totalmarks / $totalcredits);
        printf "Units passed      : %s UoC\n", $totalcredits;
        printf "```\n";

        printf "\n\n\n";
    }
}

sub top20 {
    my @sorted = sort {$b->{mark} <=> $a->{mark}} @subjects;
    print "# Top 20 Subjects\n";
    print "-----------------\n\n";

    printf "| n   | %-7s | %-8s | %-30s | %-5s | %-4s | %-21s |\n",
    "Period", "Code", "Name", "Units", "Mark", "Grade";
    printf "| --- | %-7s | %-8s | %-30s | %-5s | %-4s | %-21s |\n",
    '-' x 7, '-' x 8, '-' x 30, '-' x 5, '-' x 4, '-' x 21;

    for my $i (0..19) {

        my $subject = $sorted[$i];

        printf "| %-3s | %-7s | %-4s%-4s | %-30s | %-5s | %-4s | %-21s |\n",
        $i + 1,
        $subject->{period},
        $subject->{faculty},
        $subject->{code},
        $subject->{name},
        $subject->{credit},
        $subject->{mark},
        grade($subject->{mark});
    }
    print "\n\n\n";
}

sub bot20 {
    my @sorted = sort {$a->{mark} <=> $b->{mark}} @subjects;
    print "# Bottom 20 Subjects\n";
    print "--------------------\n\n";

    my $width = 2 + 7 + 8 + 30 + 6 + 4 + 21 + 6*3 + 3;
    printf "| n   | %-7s | %-8s | %-30s | %-5s | %-4s | %-21s |\n",
    "Period", "Code", "Name", "Units", "Mark", "Grade";
    printf "| --- | %-7s | %-8s | %-30s | %-5s | %-4s | %-21s |\n",
    '-' x 7, '-' x 8, '-' x 30, '-' x 5, '-' x 4, '-' x 21;

    for my $i (0..19) {

        my $subject = $sorted[$i];

        printf "| %-3s | %-7s | %-4s%-4s | %-30s | %-5s | %-4s | %-21s |\n",
        $i + 1,
        $subject->{period},
        $subject->{faculty},
        $subject->{code},
        $subject->{name},
        $subject->{credit},
        $subject->{mark},
        grade($subject->{mark});
    }
    print "\n\n\n";
}

sub overall {

    print "# Overall Summary\n";
    print "-----------------\n\n";

    printf "| %-7s | %-8s | %-30s | %-5s | %-4s | %-21s |\n",
    "Period", "Code", "Name", "Units", "Mark", "Grade";
    printf "| %-7s | %-8s | %-30s | %-5s | %-4s | %-21s |\n",
    '-' x 7, '-' x 8, '-' x 30, '-' x 5, '-' x 4, '-' x 21;

    my $numsubjects  = 0;
    my $numfailed    = 0;
    my $totalcredits = 0;
    my $totalmarks   = 0;

    for my $subject (@subjects) {
        printf "| %-7s | %-4s%-4s | %-30s | %-5s | %-4s | %-21s |\n",
        $subject->{period},
        $subject->{faculty},
        $subject->{code},
        $subject->{name},
        $subject->{credit},
        $subject->{mark},
        grade($subject->{mark});

        $numsubjects  += 1;
        $numfailed    += 1 if $subject->{mark} < 46;
        $totalcredits += $subject->{credit};
        $totalmarks   += $subject->{mark} * $subject->{credit};


    }

    printf "\n```\n";
    printf "Number of subjects: %d\n", $numsubjects;
    printf "Number of fails   : %d\n", $numfailed;
    printf "Average mark      : %d\n", $totalmarks / $totalcredits;
    printf "Average grade     : %s\n", grade($totalmarks / $totalcredits);
    printf "Units passed      : %s UoC\n", $totalcredits;
    printf "```\n";

    printf "\n\n\n";
}
top20();
bot20();
overall();
faculty();
