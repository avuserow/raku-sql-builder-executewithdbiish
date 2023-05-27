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

say $sql.all($sql.from('foo').select(:all));
# result: ({"a" => "b", "c" => "d"},)
say $sql.one($sql.from('foo').select(:all));
# result: {"a" => "b", "c" => "d"}
say $sql.scalar($sql.from('foo').select('a'));
# result: "b"

=end code

=head1 DESCRIPTION

SQL::Builder::ExecuteWithDBIish is a minimal wrapper around SQL::Builder that provides some helper
methods to execute the resulting queries with DBIish. These methods all take a C<SQLStatement> from
SQL::Builder as input, which brings the execution and resulting data structure to the front of the
statement, making it easier to see what's going on.

It also delegates the main four methods of L<SQL::Builder> (from, insert-into, update, and
delete-from) which create the four types of Builder objects, plus several helper methods to execute
the results, so most code can use this object instead of C<SQL::Builder> rather than having to keep
both around.

=head1 METHODS

=head2 new(:$db, [:$builder])

Constructs an instance of C<SQL::Builder::ExecuteWithDBIish>. The C<db> named parameter is required
and should be the result of C<DBIish.connect>. The optional C<builder> parameter is an instance of
C<SQL::Builder>, and allows you to configure said instance.

=head2 execute(SQLStatement $s)

Builds and executes the provided SQLStatement, returning the DBIish result object. Typically this is
used for statements which don't return rows, such as insert/update/delete (without a C<returning>
clause).

=head2 all(SQLStatement $s)

Builds and executes the provided SQLStatement, returning an array of hashes resulting from this
statement.

=begin code :lang<raku>
my @data = $sql.all($sql.from('table').select('a', 'b'));
=end code

=head2 one(SQLStatement $s)

Builds and executes the provided SQLStatement, returning a hash of the resulting data. Ensures that
there is exactly one row returned. If no rows are returned, then a C<NoResults> Exception is raised,
and if more than one row is returned, a C<TooManyResults> Exception is raised.

=begin code :lang<raku>
my $row = $sql.one($sql.from('table').select('a', 'b'));
# raises an exception if there is not exactly one result
=end code

=head2 scalar(SQLStatement $s)

Builds and executes the provided SQLStatement, returning a single value of resulting data. Ensures that
there is exactly one row returned, with exactly one field. If no rows are returned, then a
C<NoResults> Exception is raised, and if more than one row is returned, a C<TooManyResults>
Exception is raised. If the resulting row has more than one column, then C<TooManyColumns> Exception
is raised.

=begin code :lang<raku>
my $count = $sql.scalar($sql.from('table').select(Fn.new('count', 'a')));
=end code

=head2 from

Proxy method for C<SQL::Builder.from>. See L<SQL::Builder>.

=head2 insert-into

Proxy method for C<SQL::Builder.insert-into>. See L<SQL::Builder>.

=head2 update

Proxy method for C<SQL::Builder.update>. See L<SQL::Builder>.

=head2 delete-from

Proxy method for C<SQL::Builder.delete-from>. See L<SQL::Builder>.

=head1 SEE ALSO

L<SQL::Builder>

L<DBIish>

=head1 AUTHOR

Adrian Kreher <avuserow@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2023 Adrian Kreher

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
