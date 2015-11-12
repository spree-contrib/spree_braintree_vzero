# Braintree v.zero extension for Spree Commerce

[![Code Climate](https://codeclimate.com/repos/560308aa6956801375000a4e/badges/9874199a656054d613cd/gpa.svg)](https://codeclimate.com/repos/560308aa6956801375000a4e/feed)  [![Circle CI](https://circleci.com/gh/spark-solutions/spree_braintree_vzero.svg?style=svg&circle-token=3171e5c1f53e64db0b323332e573533a3bdde115)](https://circleci.com/gh/spark-solutions/spree_braintree_vzero)

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
