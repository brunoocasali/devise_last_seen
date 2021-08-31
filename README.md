# devise_last_seen

This devise extension, will ensure that devise will update a flag/timestamp on the model whenever a user is set.
With this kind of feature you could show in your views something like **last seen 3 weeks ago** or **last seen 2 minutes ago**.

[![ruby gem](https://github.com/brunoocasali/devise_last_seen/actions/workflows/gem.yml/badge.svg)](https://github.com/brunoocasali/devise_last_seen/actions/workflows/gem.yml)
[![Test Coverage](https://api.codeclimate.com/v1/badges/056e2b80cbcdb5d7b402/test_coverage)](https://codeclimate.com/github/brunoocasali/devise_last_seen/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/056e2b80cbcdb5d7b402/maintainability)](https://codeclimate.com/github/brunoocasali/devise_last_seen/maintainability)

## Installation

You know, add this line to your application's Gemfile:

```ruby
gem 'devise_last_seen'
```

And then execute:

    $ bundle

## Usage

In your model, add `:lastseenable` module as such:

```rb
# app/models/user.rb

class User < ApplicationRecord
  devise :database_authenticable, ..., :lastseenable
end
```

## Configuration

Besides the column requirement you don't need customizations, but if you want to...

```rb
# config/initializers/devise.rb

Devise.setup do |config|
  ...

  # Interval (in seconds) to update the :last_seen_at_attribute attr
  # config.last_seen_at_interval = 5.minutes

  # Attribute who will be updated every time a user is set by the Warden's after_save callback
  # config.last_seen_at_attribute = :last_seen
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. 

To install this gem onto your local machine, run `bundle exec rake install`. 
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/brunoocasali/devise_last_seen. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the `devise_last_seen` project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/devise_last_seen/blob/master/CODE_OF_CONDUCT.md).


## Hall of fame!

This gem only could be done with help of other gems like:

- @shenoudab [devise_traceable](https://github.com/shenoudab/devise_traceable)
- @devise-security [devise-security](https://github.com/devise-security/devise-security)
- @heartcombo [devise](https://github.com/heartcombo/devise)
- @ctide [devise_lastseenable](https://github.com/ctide/devise_lastseenable)
- @iplan [iplan-devise-lastseenable](https://github.com/iplan/iplan-devise-lastseenable)
