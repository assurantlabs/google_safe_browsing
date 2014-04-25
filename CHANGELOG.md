# Changelog

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
