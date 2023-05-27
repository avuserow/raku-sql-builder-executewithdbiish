[![Actions Status](https://github.com/avuserow/raku-sql-builder-executewithdbiish/actions/workflows/test.yml/badge.svg)](https://github.com/avuserow/raku-sql-builder-executewithdbiish/actions)

NAME
====

SQL::Builder::ExecuteWithDBIish - Execute SQL::Builder queries with DBIish

SYNOPSIS
========

```raku
use SQL::Builder::ExecuteWithDBIish;

my $sql = SQL::Builder::ExecuteWithDBIish;
$sql.execute($sql.insert-into('foo').data(:a<b>, :c<d>));

say $sql.all($sql.from('foo').select(:all));
# result: ({"a" => "b", "c" => "d"},)
say $sql.one($sql.from('foo').select(:all));
# result: {"a" => "b", "c" => "d"}
say $sql.scalar($sql.from('foo').select('a'));
# result: "b"
```

DESCRIPTION
===========

SQL::Builder::ExecuteWithDBIish is a minimal wrapper around SQL::Builder that provides some helper methods to execute the resulting queries with DBIish. These methods all take a `SQLStatement` from SQL::Builder as input, which brings the execution and resulting data structure to the front of the statement, making it easier to see what's going on.

It also delegates the main four methods of [SQL::Builder](SQL::Builder) (from, insert-into, update, and delete-from) which create the four types of Builder objects, plus several helper methods to execute the results, so most code can use this object instead of `SQL::Builder` rather than having to keep both around.

METHODS
=======

new(:$db, [:$builder])
----------------------

Constructs an instance of `SQL::Builder::ExecuteWithDBIish`. The `db` named parameter is required and should be the result of `DBIish.connect`. The optional `builder` parameter is an instance of `SQL::Builder`, and allows you to configure said instance.

execute(SQLStatement $s)
------------------------

Builds and executes the provided SQLStatement, returning the DBIish result object. Typically this is used for statements which don't return rows, such as insert/update/delete (without a `returning` clause).

all(SQLStatement $s)
--------------------

Builds and executes the provided SQLStatement, returning an array of hashes resulting from this statement.

```raku
my @data = $sql.all($sql.from('table').select('a', 'b'));
```

one(SQLStatement $s)
--------------------

Builds and executes the provided SQLStatement, returning a hash of the resulting data. Ensures that there is exactly one row returned. If no rows are returned, then a `NoResults` Exception is raised, and if more than one row is returned, a `TooManyResults` Exception is raised.

```raku
my $row = $sql.one($sql.from('table').select('a', 'b'));
# raises an exception if there is not exactly one result
```

scalar(SQLStatement $s)
-----------------------

Builds and executes the provided SQLStatement, returning a single value of resulting data. Ensures that there is exactly one row returned, with exactly one field. If no rows are returned, then a `NoResults` Exception is raised, and if more than one row is returned, a `TooManyResults` Exception is raised. If the resulting row has more than one column, then `TooManyColumns` Exception is raised.

```raku
my $count = $sql.scalar($sql.from('table').select(Fn.new('count', 'a')));
```

from
----

Proxy method for `SQL::Builder.from`. See [SQL::Builder](SQL::Builder).

insert-into
-----------

Proxy method for `SQL::Builder.insert-into`. See [SQL::Builder](SQL::Builder).

update
------

Proxy method for `SQL::Builder.update`. See [SQL::Builder](SQL::Builder).

delete-from
-----------

Proxy method for `SQL::Builder.delete-from`. See [SQL::Builder](SQL::Builder).

SEE ALSO
========

[SQL::Builder](SQL::Builder)

[DBIish](DBIish)

AUTHOR
======

Adrian Kreher <avuserow@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2023 Adrian Kreher

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

