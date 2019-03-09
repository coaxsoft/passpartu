# Passpartu

Passpartu makes policies great again (works awesome with Pundit).

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
Include `Passpartu` into your policy model.
```ruby
class User
  include Passpartu
end
```
NOTE: Your `User` model must respond to `role` method that returns a string or a symbol!

Keep all your policies in one place.
Create `./config/passpartu.yml` and start writing your policies.

#### Example
```yml
# ./config/passpartu.yml

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


## Configuration

You can configure Passpartu by creating `./config/initializers/passpartu.rb`.

#### Default configs are:

```ruby
Passpartu.configure do |config|
  config.policy_file = './config/passpartu.yml'
  config.raise_policy_missed_error = true
end
```
### Raise policy missed errors
By default Passpartu will raise an PolicyMissedError if policy is missed in `passpartu.yml`. In initializer set  `config.raise_policy_missed_error = false` in order to return `false` in case when policy is not defined. This is a good approach to write only "positive" policies (only true) and automatically restricts everything that is not mentioned in `passpartu.yml`

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'passpartu'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install passpartu



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/OrestF/passpartu. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Passpartu project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/coaxsoft/passpartu/blob/master/CODE_OF_CONDUCT.md).

## Idea
Initially designed and created by [Orest Falchuk](https://github.com/OrestF)
