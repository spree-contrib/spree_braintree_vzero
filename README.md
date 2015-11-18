# Braintree v.zero extension for Spree Commerce

[![Code Climate](https://codeclimate.com/repos/560308aa6956801375000a4e/badges/9874199a656054d613cd/gpa.svg)](https://codeclimate.com/repos/560308aa6956801375000a4e/feed)  [![Circle CI](https://circleci.com/gh/spark-solutions/spree_braintree_vzero.svg?style=svg&circle-token=3171e5c1f53e64db0b323332e573533a3bdde115)](https://circleci.com/gh/spark-solutions/spree_braintree_vzero)

This is the official Braintree v.zero extension for Spree. It supports:
* [Braintree Drop-in UI](https://github.com/spark-solutions/spree_braintree_vzero/wiki/Drop-in-UI)
* [Braintree Hosted Fields](https://github.com/spark-solutions/spree_braintree_vzero/wiki/Hosted-Fields)
* [Paypal & PayPall Express Checkout](https://www.braintreepayments.com/features/paypal)

Behind-the-scenes, this extension uses [Braintree Ruby SDK](https://github.com/braintree/braintree_ruby).


## Installation

1. Add this extension to your Gemfile with this line:
```ruby
gem 'spree_braintree_vzero ', github: 'spark-solutions/spree_braintree_vzero', branch: 'X-X-stable'
```

The `branch` option is important: it must match the version of Spree you're using.
For example, use `3-0-stable` if you're using Spree `3-0-stable` or any `3.0.x` version.

2. Install the gem using Bundler:

        bundle install

3. Copy & run migrations

        bundle exec rails g spree_braintree_vzero:install

4. Restart your server

If your server was running, restart it so that it can find the assets properly.



## Heroku installation

Additional to migrations the gem adds a cron task (via the [Whenever gem](https://github.com/javan/whenever)) which is needed for updating transaction states from _submited for settlement_ to _settled_ ([Braintree v.zero transaction states](https://developers.braintreepayments.com/guides/transactions/ruby#status)). To run on Heroku you have to add a task to [Heroku Scheduler](https://devcenter.heroku.com/articles/scheduler):

```
rake spree_braintree_vzero:update_states
```

Recommended frequency is every 6 hours.


## Sample application

If you want to see a working instance of Spree with this gem please see our [sample application repository](https://github.com/spark-solutions/spree_braintree_vzero_example)


## Contributing

In the spirit of [free software][1], **everyone** is encouraged to help improve this project.

Here are some ways *you* can contribute:

* by using prerelease versions
* by reporting [bugs][2]
* by suggesting new features
* by writing or editing documentation
* by writing specifications
* by writing code (*no patch is too small*: fix typos, add comments, clean up inconsistent whitespace)
* by refactoring code
* by resolving [issues][2]
* by reviewing patches

Starting point:

* Fork the repo
* Clone your repo
* Run `bundle install`
* Run `bundle exec rake test_app` to create the test application in `spec/dummy`
* Make your changes
* Ensure specs pass by running `bundle exec rspec spec`
* Submit your pull request

[1]: http://www.fsf.org/licensing/essays/free-sw.html
[2]: https://github.com/spark-solutions/spree_braintree_vzero/issues
[3]: https://github.com/spark-solutions/spree_braintree_vzero/blob/master/LICENSE
