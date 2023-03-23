# Changelog

All notable changes to this project will be documented in this file.

## [1.1.1] - 2023-03-23

- Remove byebug dependency

## [1.1.0] - 2022-04-28

### Added

- Add `role_access_method` config to change role method
- Add method `policy_hash` - policy will be read from it instead of passpartu.yml

### Improvements

## [1.0.3] - 2022-03-14

### Improvements

- Checked to support ruby v3.1.1
- Updated code blocks according to RuboCop
- Optimized tests

## [1.0.2] - 2020-08-12

### Improvements

- Optimized and secured policy hash for check_waterfall = true

## [1.0.1] - 2020-04-05

### Fixed

- Set raise_policy_missed_error to false if check_waterfall == true

## [1.0.0] - 2020-04-05

### Added

#### Waterfall check

- Allow or restrict absolutely everything for particular role or/and particular domain.

```ruby
# ./config/initializers/passpartu.rb

Passpartu.configure do |config|
  config.check_waterfall = true
end
```

```yml
# ./config/passpartu.yml

super_admin: true
super_looser: false
medium_looser:
  orders:
    create: true
    delete: false
  products: true
```

```ruby
user_super_admin.can?(:do, :whatever, :want) # true
user_super_loser.can?(:do, :whatever, :want) # false
user_medium_loser.can?(:orders, :create) # true
user_medium_loser.can?(:orders, :delete) # false
user_medium_loser.can?(:products, :create) # true
user_medium_loser.can?(:products, :create, :and_delete) # true
```

## [0.6.0] - 2019-04-01

### Added

- Only roles attribute to verifier

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

## [0.5.5] - 2019-03-23

### Added

- `Skip` alias to `except`

```ruby
  user_agent.can?(:orders, :edit, except: [:admin, :manager]) { user_agent.orders.include?(order) }
  # equals to
  user_agent.can?(:orders, :edit, skip: [:admin, :manager]) { user_agent.orders.include?(order) }
```

## [0.5.0] - 2019-03-20

### Added

- Per roles methods

```ruby
    # check if user admin AND returns true if policy true
    user_admin.admin_can?(:orders, :edit) # true
    
    # check if user admin AND returns true if policy true
    user_admin.manager_can?(:orders, :edit) # false
```

- Code blocks

```ruby
  # check rules as usual AND code in the block   
  user_agent.can?(:orders, :edit, except: [:admin, :manager]) { user_agent.orders.include?(order) }
  
  # OR   
  user_agent.agent_can?(:orders, :edit, except: [:admin, :manager]) { user_agent.orders.include?(order) }
```

## [0.4.0] - 2019-03-20

### Added

- Except roles attribute to verifier

```ruby
    user_admin.can?(:orders, :edit) # check policy for admin and returns true if policy true
    user_admin.can?(:orders, :edit, except: :admin) # returns false because user is admin and we excluded admin
    
```

It's possible to give an array as except attribute

```ruby
  user_admin.can?(:orders, :edit, except: [:admin, :manager]) # returns false
  user_manager.can?(:orders, :edit, except: [:admin, :manager]) # returns false
```
