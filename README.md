[![Build Status](https://travis-ci.org/Zloy/credits_api.svg)](https://travis-ci.org/Zloy/credits_api)
[![Coverage Status](https://coveralls.io/repos/Zloy/credits_api/badge.png)](https://coveralls.io/r/Zloy/credits_api)

# CreditsApi

Being interviewed for RAILS  developer job I was asked to write an app as a test.

This is my solution. It includes ready to use application and Rspec tests.


## Application requirements

Implement JSON HTTP API to:

* deposit/withdraw bonus points (concurrent requests affecting a user's balance are possible)
* get users list (name and current balance)
* get history of deposits/withdrawals for given user

Also
* ruby framework doesn't matter
* data to be stored in relational DB
* tests should be provided

That simple, I like it )

## Assumptions

* As I'm free to use any framework, I choose Rails 4
* Rails mountable engine seems to be suitable
* A user model is ActiveRecord::Base subclass in host application
* A user model could be namespaced and could be named differently, e.g. Player
* A user has a name as model attribute, name could be referred differently, e.g. as :login, or :email 

### Routes

At some prefix, say '/api'

```
POST /api/users/:id/deposit/:amount
POST /api/users/:id/withdraw/:amount
GET  /api/users
GET  /api/users/:id/statement
```

### Disclaimer

* I know, POST parameters should be passed in request body. I pass them in url just for fun
* TODO concurrent requests in pending spec
* I realized that bonus_points more suitable gem name after I had written some code, so it was pain to change it then


## Installation

```
cd <your application folder>
mkdir -p vendor/gems
cd vendor/gems
git clone https://github.com/Zloy/credits_api
cd -
echo gem "credits_api", path: "vendor/gems/credits_api" >> Gemfile
bundle install
bundle exec rake credits_api:install:migrations
bundle exec rake db:migrate
```

## Using

As user model is defined in host application, the gem should be informed of the user model class and user name model attribute.

To do that create a new initializer config/initializers/credits_api.rb 

```ruby
CreditsApi.user_class = User # put here your actual user model class
CreditsApi.name_attr = :name # again, put here actual name attribute
```

Add to your user model class

```include CreditsApi```

Add to your routes

```mount CreditsApi::Engine, at: "/api"```

Now you got in your application additional routes and all underlying logic
  
```
POST /api/users/:id/deposit/:amount
POST /api/users/:id/withdraw/:amount
GET  /api/users
GET  /api/users/:id/statement
```

## Testing

As I packed the solution as Rails engine gem, I supplied it with test Rails application in test/dummy folder

```
cd test/dummy
bundle install
edit config/database.yml, specify right db params
bundle exec rake credits_api:install:migrations
RAILS_ENV=test bundle exec rake db:create
RAILS_ENV=test bundle exec rake db:migrate
bundle exec rspec
```

## Abusing (race conditions testing)

Get dummy up and running

```
cd vendor/gems/credits_api/test/dummy
edit config/database.yml, specify right db params
rake db:setup
rails s -p 4000
```
  
Open a browser and navigate to http://localhost:4000/api/users
you should see 

```
[{"name":"Arnold Schwarzenegger","balance":0.0},
 {"name":"Bruce Willis","balance":1000.0},
 {"name":"Robert De Niro","balance":1998.0},
 {"name":"Samuel L. Jackson","balance":111.0}]
```

Check the balance of Mr. Jackson, it should be <b>111.0</b>

```
echo " " > post_data
ab -n 1000 -c 100 -p post_data http://localhost:4000/api/users/1/withdraw/1
```

Open a browser and navigate again to http://localhost:4000/api/users
now you should see 
  
```
[{"name":"Arnold Schwarzeneger","balance":0.0},
 {"name":"Bruce Willis","balance":1000.0},
 {"name":"Robert De Niro","balance":1998.0},
 {"name":"Samuel L. Jackson","balance":-889.0}]
```
  
Notice the balance of Mr. Jackson was changed, it should be now <b>-889</b>

Thus, despite there were performed a lot of concurrent requests, the balance was changed by the right value: ```111 - 1000 = -889```
