# Passpartu v0.7.0 - [changelog](https://github.com/coaxsoft/passpartu/blob/master/CHANGELOG.md)

Passpartu makes policies great again (works awesome with [Pundit](https://rubygems.org/gems/pundit)).

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

#### Example of `passpartu.yml`
```yml
# ./config/passpartu.yml
manager: &manager
  order:
    create: true
    edit: true
    delete: false
  product:
    create: true
    edit: true
    delete: false

# yaml files supports inheritance!
admin:
  <<: *manager
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
  items:
    crud: true
    delete: false
```

## Features
#### Waterfall rules
To enable feature change waterfall_rules to `true` in config/initializers/passpartu.rb
```ruby
  Passpartu.configure do |config|
    config.waterfall_rules = true
  end
```
If policy rule is missed, but the key above value equals true - positive policy (true).
It work with any number of keys!
```yml
  admin:
  <<: *manager
  post:
    create: false
    update: true
    delete: true
  order: true
```

```ruby
  admin_user.can?(:order, :whatever) # true
```

#### CRUD
It's possible to use `crud` key to set values for `create`, `read`, `update`, `delete` at once.
`create`, `read`, `update`, `delete` has higher priority than `crud`
In case `crud: true` and `delete: false` - result `false`

#### Only
It's possible to include specific roles to checks
```ruby
    user_admin.can?(:orders, :edit) # check policy for admin and returns true if policy true
    user_admin.can?(:orders, :edit, only: :admin) # returns true because the user is an admin and we included only admin
    user_manager.can?(:orders, :edit, only: :admin) # returns false because user is manager and we included only admin
```
It's possible to give an array as only attribute

```ruby
  user_admin.can?(:orders, :edit, only: [:admin, :manager]) # returns true
  user_manager.can?(:orders, :edit, only: [:admin, :manager]) # returns true
```

Note: `only` has higher priority than `except/skip`. Do not use both.
```ruby
  user_admin.can?(:orders, :edit, only: :admin, except: :admin) # returns true
```


#### Skip (except)
It's possible to exclude roles from checks
```ruby
    user_admin.can?(:orders, :edit) # check policy for admin and returns true if policy true
    user_admin.can?(:orders, :edit, except: :admin) # returns false because user is admin and we excluded admin

```
It's possible to give an array as except attribute

```ruby
  user_admin.can?(:orders, :edit, except: [:admin, :manager]) # returns false
  user_manager.can?(:orders, :edit, except: [:admin, :manager]) # returns false
```

`skip` alias to `except`

Note: `expect` has higher priority than `skip`. Do not use both.
```ruby
  user_agent.can?(:orders, :edit, except: [:admin, :manager]) { user_agent.orders.include?(order) }
  # equals to
  user_agent.can?(:orders, :edit, skip: [:admin, :manager]) { user_agent.orders.include?(order) }
```

#### Per role methods
Check user roles AND policy rule
```ruby
    # check if user admin AND returns true if policy true
    user_admin.admin_can?(:orders, :edit) # true

    # check if user manager AND returns true if policy true
    user_admin.manager_can?(:orders, :edit) # false
```

#### Code blocks
```ruby
  # check rules as usual AND code in the block
  user_agent.can?(:orders, :edit, except: [:admin, :manager]) { user_agent.orders.include?(order) }

  # OR
  user_agent.agent_can?(:orders, :edit, except: [:admin, :manager]) { user_agent.orders.include?(order) }
```

##### Real life example
You need to check custom rule for agent
```yml
# ./config/passpartu.yml

admin:
  order:
    create: true
    edit: true
    delete: true
manager:
  order:
    create: true
    edit: true
    delete: false
agent:
  order:
    create: true
    edit: true
    delete: false
```

```ruby
    user.can?(:order, :edit, except: :agent) || user.agent_can?(:order, :edit) { user.orders.include?(order) }
```

1. This code returns `true` if user is `admin` or `manager`
1. This code returns `true` if user is `agent` AND if agent policy set to `true` AND if given block returns true

## Configuration

You can configure Passpartu by creating `./config/initializers/passpartu.rb`.

#### Default configs are:

```ruby
Passpartu.configure do |config|
  config.policy_file = './config/passpartu.yml'
  config.raise_policy_missed_error = true
  config.waterfall_rules = false
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

Bug reports and pull requests are welcome on GitHub at https://github.com/coaxsoft/passpartu. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Passpartu project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/coaxsoft/passpartu/blob/master/CODE_OF_CONDUCT.md).

## Idea
Initially designed and created by [Orest Falchuk](https://github.com/OrestF)
