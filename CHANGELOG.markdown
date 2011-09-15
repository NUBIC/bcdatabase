Bcdatabase history
==================

1.2.2
-----

1.2.1
-----
- Generalize `datamapper_adapter` and `jruby_adapter` transforms to
  work with any similarly prefixed keys. (#15)

1.2.0
-----
- Add automatic transform for `jruby_adapter` when running under
  JRuby. (#14)

1.1.0
-----
- Introduce "transforms" -- a way to attach behavior to modify entries
  on load. See {Bcdatabase.load} for details.
- Add `:datamapper` built-in transform to support sharing one set of
  entries between ActiveRecord and DataMapper. (#10)
- Rework command-line interface for better testability. It's now
  compatible with MRI 1.9. (#11, #7)
- Provide a better message when working with encrypted passwords and
  the keyfile is not readable. (#1)
- Improve `bcdatabase encrypt` so that it will work with a wider
  variety of input passwords and YAML files. The remaining limitations
  are documented in its online help. (#12)
- Interpret empty stanzas as entries made up entirely of defaults. (#13)

1.0.6
-----
- Use `ENV['RAILS_ENV']` instead of the unreliable `RAILS_ENV` constant.

1.0.5
-----
- Loosen highline dependency so that bcdatabase can be used in buildr buildfiles.

1.0.4
-----
- Fix command line utilities that were broken in 1.0.3 due to
  inadequate test coverage.  (GH-4)

1.0.3
-----
- Support ActiveSupport 3.  ActiveSupport 2 continues to work.

1.0.2
-----
- Tighten up gemspec gem deps.  Bcdatabase does not currently work
  with ActiveSupport 3.

1.0.1
-----
- Update some old syntax for ruby 1.9 compatibility (David Yip)

1.0.0
-----
- Split out from NUBIC internal `bcdatabase` project.
  (Changelog entries below reflect the relevant changes & version numbers from that project.)

0.4.1
-----
- Fix `bcdatabase encrypt` so that it doesn't re-encrypt already encrypted
  epassword entries.

0.4.0
-----
- Use the YAML entry name as the "database" value if no other value is
  provided.  This is to DRY up PostgreSQL configurations where the username
  (already defaulted) and the database name are the same.

0.2.0
-----
- Change default encrypted secret password location

0.1.0
-----
- Support encrypted passwords
- Command-line utility (also called bcdatabase) for creating encrypted passwords
- Gem distribution

0.0.0
-----
Original release.
