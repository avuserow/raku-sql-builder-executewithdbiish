unit class SQL::Builder::ExecuteWithDBIish;

use SQL::Builder;
use DBDish;

has DBDish::Connection $.db is required;
has SQL::Builder $.builder handles <from insert-into update delete-from> = SQL::Builder.new;

class TooManyResults is Exception {
    method message() {"Query returned multiple rows but only one was expected"}
}

class NoResults is Exception {
    method message() {"Query returned no rows but one was expected"}
}

class TooManyColumns is Exception {
    has $.count;

    method message() {
        "Query returned $.count columns but a single one was expected";
    }
}

method execute($s) {
    given $s.build {
        $!db.execute(.sql, |.bind);
    }
}

method all($s) {
    self.execute($s).allrows(:array-of-hash);
}

method one($s) {
    my $sth = self.execute($s);
    my $r = $sth.row(:hash);

    die NoResults.new unless $r;
    die TooManyResults.new if $sth.row;

    return $r;
}

method scalar($s) {
    my $sth = self.execute($s);
    my $r = $sth.row;
    die NoResults.new unless $r;
    die TooManyResults.new if $sth.row;

    die TooManyColumns.new(:count($r.elems)) if $r.elems != 1;

    return $r[0];
}

=begin pod

=head1 NAME

SQL::Builder::ExecuteWithDBIish - Execute SQL::Builder queries with DBIish

=head1 SYNOPSIS

=begin code :lang<raku>

use SQL::Builder::ExecuteWithDBIish;

my $sql = SQL::Builder::ExecuteWithDBIish;
$sql.execute($sql.insert-into('foo').data(:a<b>, :c<d>));
# result: True

say $sql.all($sql.from('foo').select(:all));
# result: ({"a" => "b", "c" => "d"},)
say $sql.one($sql.from('foo').select(:all));
# result: {"a" => "b", "c" => "d"}
say $sql.scalar($sql.from('foo').select('a'));
# result: "b"

=end code

=head1 DESCRIPTION

SQL::Builder::ExecuteWithDBIish is a wrapper around SQL::Builder that provides some helper methods
to execute the resulting queries with DBIish.

It also delegates the main four methods of L<SQL::Builder> (from, insert-into, update, and
delete-from) which create the four types of Builder objects, plus several helper methods to execute
the results, so most code can use this object instead of C<SQL::Builder> rather than having to keep
both around.

=head1 AUTHOR

Adrian Kreher <avuserow@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2023 Adrian Kreher

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
