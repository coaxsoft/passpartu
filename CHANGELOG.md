# Changelog
All notable changes to this project will be documented in this file.


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
