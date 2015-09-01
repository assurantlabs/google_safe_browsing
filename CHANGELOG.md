# Changelog

## v0.6.5

  * Limit full hash index key length to prevent MySQL errors when adding the
  key.

  Thanks to John Mullins for
  [reporting](https://github.com/mobiledefense/google_safe_browsing/issues/25).

## v0.6.4

  * Update vulnerable dependencies and added explicit support for Ruby 2.2.x.

  Thanks to [Jacob Chae](https://github.com/jbcden) and [Brandon
  Siegel](https://github.com/bsiegel) for
  [contributing](https://github.com/mobiledefense/google_safe_browsing/pull/22).

## v0.6.3

  * Fix no extension on generated migration in Rails 4.

  Thanks to Eric Fiterman for
  [reporting](https://github.com/mobiledefense/google_safe_browsing/issues/18).

## v0.6.2

  * Handle Full Hash requests which return a 204.  This is expected behavior if
  the local database is not updated and prefixes have been delted, a request
  for full hashes will return a 204.

  Thanks to Alin Irimie for
  [reporting](https://github.com/mobiledefense/google_safe_browsing/issues/16).

  * Fix undefined methods when deleting shavar chunks

  Thanks to Alin Irimie for
  [reporting](https://github.com/mobiledefense/google_safe_browsing/issues/15).

## v0.6.1

  * Fix PostgreSQL syntax when deleting shavars

  Thanks to Trey Keifer for
  [reporting](https://github.com/mobiledefense/google_safe_browsing/issues/10).

## v0.6.0

  * Increase support for PostgreSQL

  Thanks to Trey Keifer for
  [reporting](https://github.com/mobiledefense/google_safe_browsing/issues/9).

--------------

Versions prior to 0.6.0 do not have changes recoreded in thie changelog. Sorry.
