# Google Safe Browsing Gem

This gem allows easy Google Safe Browsing APIv2 usage with optional integration
into Rails 3 apps.

[![Build
Status](https://travis-ci.org/mobiledefense/google_safe_browsing.png)](https://travis-ci.org//mobiledefense/google_safe_browsing)
[![Code
Climate](https://codeclimate.com/github/mobiledefense/google_safe_browsing.png)](https://codeclimate.com/github/mobiledefense/google_safe_browsing)

It includes:

* a migration generator for database schema
* method to update hash database
* method to lookup a url
* rake tasks to update hash database
* Autonomous updating via Resque and Resque Scheduler (optional)
* Message Authentication Codes (optional; on by default)

----------------------

##Installation

Install the gem

    gem install google_safe_browsing

Or add it to your Gemfile

    #Gemfile

    ...

    gem 'google_safe_browsing'

Then, generate the migration and run it

    $ rails generate google_safe_browsing:install
        create db/migrate/20120227143535_create_google_safe_browsing_tables.rb
    $ rake db:migrate


Add your Google Safe Browsing API key to congif/application.rb
You can get a key from the [Google
Safe Browsing website](http://code.google.com/apis/safebrowsing/key_signup.html)

    #config/application.rb

    ...

    config.google_safe_browsing.api_key = 'MySuperAwesomeKey5124'


## Rake Tasks

You can run an update manually

    $ rake google_safe_browsing:update

> Note: The full database is not guaranteed to be returned after a single update.
  In fact, you aren't likely to have the full database even after several
  updates. You will know that you have the full database when an update does
  not return any new Add or Sub Shavars.

Or, if you have [Resque](https://github.com/defunkt/resque) and
[Resque Scheduler](https://github.com/bvandenbos/resque-scheduler) set up, you
can run an update and automatically schedule another update based on the 'next
polling interval' parameter from the API

    $ rake google_safe_browsing:update_and_reschedule

## Usage

To programatically run an update in your app

    GoogleSafeBrowsing::APIv2.update

Note: This can take a while, especially when first seeding your database. I
wouldn't recommend calling this in a controller for a normal page request.

To check a url for badness

    GoogleSafeBrowsing::APIv2.lookup('http://bad.url.address.here.com.edu/forProfit')

The url string parameter does not have to be any specific format or
Canonicalization the Google Safe Browsing gem will handle all of that for you.
Please report any errors from a weirdly formatted url though. I most likely
have missed some cases.

The `lookup` method returns a string ( either 'malware' or 'phishing' ) for
the name of the black list which the url appears on, or `nil` if the url is
not on Google's list.

----------------

## Contributing

We've already had some [great
contributers](https://github.com/mobiledefense/google_safe_browsing/graphs/contributors).
If you'd like to join us, we'd love to have you. When contributing please

1. [Fork](https://github.com/mobiledefense/google_safe_browsing/fork) the repo
1. Start a topic branch.
1. Write awesome code!
   1. Please break your commits into logical units.
   1. Please add specs when necessary.
1. Open a [Pull
   Request](https://github.com/mobiledefense/google_safe_browsing/pulls)
1. Make sure [Travis
   CI](https://travis-ci.org/mobiledefense/google_safe_browsing)
   builds the PR successfully.
1. See your awesomeness merged in!

### Running specs

We use [Rspec](http://rspec.info/) for unit testing. You can run the specs with
the following command:

    bundle exec rake

Or individual specs/files:

    bundle exec rspec spec/chunk_helper_spec.rb:10


Thanks for helping us make browsing safer!

----------------

### More information

[Google Safe Browsing API Reference](http://code.google.com/apis/safebrowsing/)

----------------

### Inspiration

The interface of this gem is based upon these two gems, which are
based on Safe Browsing v1 API:

https://github.com/koke/malware_api
and
https://github.com/codelux/malware_api

------------------

Thank you for using this gem! Please report any bugs or issues.
