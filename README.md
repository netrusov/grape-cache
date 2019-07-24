## Grape::Cache - Yet another caching solution for Grape framework

### Note

This gem is still heavily tied with Rails and not production ready

### Installation

Add gem to your Gemfile

```ruby
gem 'grape-cache', github: 'netrusov/grape-cache'
```

Then install

```
bundle install
```

### Usage

```ruby
class API::Routes < Grape::API
  namespace :users do
    cache do
      key { params.sort }
      expires_in 1.minute
      cache_control public: true
    end

    params do
      optional :filters, type: Hash
    end

    get do
      present :users, UserSearch.new(permitted_params[:filters]).result, with: API::Entities::User
    end

    route_param :id do
      before do
        authenticate!
        authorize!
      end

      resource :posts do
        cache do
          key { [current_user.id, params.sort] }
          expires_in 1.hour
          cache_control public: false, max_age: 10.minutes
        end

        params do
          optional :filters, type: Hash
        end

        get do
          present :posts, User.find(params[:id]).posts, with: API::Entities::Post
        end
      end
    end
  end
end
```
