# Doorman



Doorman makes policies great again (works awesome with Pundit).

Instead of this:
```ruby
class PostPolicy < ApplicationPolicy
  def update?
    user.super_admin? || user.admin? || user.manager? || user.supervisor?
  end
end
```

just this:
```ruby
class PostPolicy < ApplicationPolicy
  def update?
    user.can?(:post, :update)
  end
end
```
## Usage

Keep all your policies in one place.
Create `./config/doorman.yml` and start writing your policies.
#### Example
```yml
# ./config/doorman.yml

admin:
  post:
    create: false
    update: true
    delete: true 
  order:
    create: true
    edit: true
    delete: true
  product:
    create: false
    edit: true
    delete: true  
manager:
  order:
    create: true
    edit: true
    delete: false
  product:
    create: true
    edit: true
    delete: false

```

Your `User` model must respond to `role` method that returns string or symbol!

## Configuration

You can configure Doorman by creating `./config/initializers/doorman.rb`.

#### Default configs are:

```ruby
Doorman.configure do |config|
  config.policy_file = './config/doorman.yml'
  config.raise_policy_missed_error = true
  config.policy_class_name = 'User'
end
```
### Policy file
Change default file path to your own

### Raise policy missed errors
By default Doorman will raise an error if policy is missed in `doorman.yml`. Set `config.raise_policy_missed_error = false` in order to return `false` in case when policy is not defined. This is a good approach to write only "positive" policies (only true) and automatically restricts everything that is not metioned in `doorman.yml`

### Policy class name
By default Doorman uses `User` class, but it's possible to set any class name e.g. `Person`


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'doorman'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install doorman



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/OrestF/doorman. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Doorman project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/OrestF/doorman/blob/master/CODE_OF_CONDUCT.md).
