Bcdatabase
==========

*Bcdatabase* is a library and utility which provides database
configuration parameter management for Ruby on Rails applications.  It
provides a simple mechanism for separating database configuration
attributes from application source code so that there's no temptation
to check passwords into the version control system.  And it
centralizes the parameters for a single server so that they can be
easily shared among multiple applications and easily updated by a
single administrator.

## Installing bcdatabase

    $ gem install bcdatabase

## Using bcdatabase to configure the database for a Rails application

A bog-standard Rails application's `config/database.yml` file looks like this:

    development:
      adapter: oracle_enhanced
      database: //localhost/XE
      username: cfg_animal
      password: not-important

    test:
      adapter: oracle_enhanced
      database: //localhost/XE
      username: cfg_animal_test
      password: who-cares

    production:
      adapter: oracle_enhanced
      database: //super/prod
      username: cfg_animal
      password: very-secret

Rails allows this file to contain [ERB][].  `bcdatabase` uses ERB to
replace an entire configuration block.  If you wanted to replace, say,
just the production block in this example, you would transform it like
so:

    <%
      require 'bcdatabase'
      bcdb = Bcdatabase.load
    %>

    development:
      adapter: oracle_enhanced
      database: //localhost/XE
      username: cfg_animal
      password: not-important

    test:
      adapter: oracle_enhanced
      database: //localhost/XE
      username: cfg_animal_test
      password: who-cares

    <%= bcdb.production :prod, :cfg_animal %>

This means "create a YAML block for the *production* environment from
the configuration entry named *cfg_animal* in
/etc/nubic/db/*prod*.yml."  The method called can be anything:

    <%= bcdb.development :local, :cfg_animal %>
    <%= bcdb.staging 'stage', 'cfg_animal' %>
    <%= bcdb.automated :dev, :cfg_animal_hudson %>

[ERB]: http://www.ruby-doc.org/stdlib/libdoc/erb/rdoc/

## Directly accessing configuration parameters from bcdatabase

More rarely, you might need to access the actual configuration hash,
instead of the YAMLized version.  You can access it by invoking
`Bcdatabase.load` as shown earlier, then using the bracket operator to
specify the configuration you want:

    bcdb[:local, :cfg_animal]

The resulting hash is suitable for passing to
`ActiveRecord::Base.establish_connection`, for instance.

## Central configuration files

The database configuration properties for all the applications on a
server are stored in one or more files under `/etc/nubic/db` (by
default; see "File locations" below).  Each one is a standard YAML
file, similar to Rails' `database.yml` but with a few enhancements:

* Each file can have a defaults entry which provides attributes which
  are shared across all configurations in the file
* Each entry defaults its "username" attribute to the name of the
  entry (useful for Oracle)
* Each entry defaults its "database" attribute to the name of the
  entry (useful for PostgreSQL)

Since each file can define a set of default properties which are
shared by all the contained configurations, it makes sense to group
databases which have some shared configuration elements.

### Example

If you have an `/etc/nubic/db/stage.yml` file that looks like this:

    defaults:
      adapter: oracle_enhanced
      database: //mondo/stage
    cfg_animal:
      password: secret
    personnel:
      username: pers
      password: more-secret

You have defined two configuration entries.  `:stage, :cfg_animal`:

    adapter:  oracle_enhanced
    username: cfg_animal
    password: secret
    database: //mondo/stage

and `:stage, :personnel`:

    adapter:  oracle_enhanced
    username: pers
    password: more-secret
    database: //mondo/stage

## Obscuring passwords

Bcdatabase supports storing encrypted passwords instead of the
plaintext ones shown in the previous example.  Encrypted passwords are
defined with the key `epassword` instead of `password`.  The library
will decrypt the `epassword` value and expose it to the calling code
(usually Rails) unencrypted under the `password` key.  The
`bcdatabase` command line utility handles encrypting passwords; see
the next section.

While the passwords are technically encrypted, the master key must be
stored on the same machine so that they can be decrypted on demand.
That means this feature only obscures passwords &mdash; it will not
deter a determined attacker.

## `bcdatabase` command line utility

The gem includes a command line utility (also called `bcdatabase`)
which assists with creating `epassword` entries.  It has online help;
after installing the gem, try `bcdatabase help` to read it:

    $ bcdatabase help
    Tasks:
      bcdatabase encrypt [INPUT [OUTPUT]]  # Encrypt every password in a bcdatabase YAML file
      bcdatabase epass [-]                 # Generate epasswords from database passwords
      bcdatabase gen-key [-]               # Generate the bcdatabase shared key
      bcdatabase help [TASK]               # Describe available tasks or one specific task

## File locations

`/etc/nubic/db` is the default place the library will look for the
central configuration files.  It may be overridden with the
environment variable `BCDATABASE_PATH`.  For instance, if you wanted
to keep these files in your home directory on your development machine
&mdash; perhaps so that editing them doesn't require elevated
privileges &mdash; you could add this to `~/.bashrc`:

    export BCDATABASE_PATH=${HOME}/nubic/db

Similarly, the file containing the encryption password has a sensible
default location, but that location can be overridden by setting
`BCDATABASE_PASS`.

## DataMapper

Bcdatabase was originally designed for use with ActiveRecord in Rails
applications. Since [DataMapper][dm]'s programmatic configuration mechanism
(`Datamapper.setup`) accepts hashes which are very similar to
ActiveRecord configuration hashes, Bcdatabase can easily be used with
DataMapper as well. Example:

    bcdb = Bcdatabase.load(:transforms => [:datamapper]))
    DataMapper.setup(:default, bcdb[:stage, :personnel])

The `:datamapper` transform passed to `Bcdatabase.load` in this
example permits sharing of one set of Bcdatabase configurations
between ActiveRecord and DataMapper-based apps. Specifically, for
those cases where the ActiveRecord adapter and the DataMapper adapter
have different names, it allows you to specify a separate
`datamapper_adapter` in your Bcdatabase configuration. For example,
say you had these contents in `stage.yml`:

    defaults:
      adapter: postgresql
      datamapper_adapter: postgres
    personnel:
      password: foo

When loaded without the `:datamapper` transform, the effective
database configuration hash for `:stage, :personnel` would be

    adapter: postgresql
    datamapper_adapter: postgres # ignored by AR
    database: personnel
    username: personnel

With the `:datamapper` transform, the result would be instead:

    adapter: postgres
    database: personnel
    username: personnel

And so your DM and AR apps can live side-by-side and neither needs to
embed its own database credentials.

[dm]: http://datamapper.org/

## Platforms

Bcdatabase works on MRI 1.8.7 and MRI 1.9.2. It will also work on
JRuby (tested on 1.6+), provided that `jruby-openssl` is also
installed. It is [continuously tested][ci] on all three of these
platforms.

[ci]: https://public-ci.nubic.northwestern.edu/job/bcdatabase/

## Credits

`bcdatabase` was developed at and for the [Northwestern University
Biomedical Informatics Center][NUBIC].

[NUBIC]: http://www.nucats.northwestern.edu/centers/nubic/index.html

### Copyright

Copyright (c) 2009 Rhett Sutphin. See LICENSE for details.
