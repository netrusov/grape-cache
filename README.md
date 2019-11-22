## Grape::Cache - Yet another caching solution for Grape framework

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grape-cache', github: 'netrusov/grape-cache'
```

And then execute:
```
bundle install
```

## Configuration

By default `Grape::Cache` uses `ActiveSupport::Cache::MemoryStore` as backend. You can use any compatible store though.

```ruby
Grape::Cache.configure do |config|
  config.backend = Rails.cache
end
```

## Usage

```ruby
class API < Grape::API
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
      present :users, Searches::Users.new(permitted_params[:filters]).result, with: Grape::Presenters::Presenter
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
          present :posts, User.find(params[:id]).posts, with: Grape::Presenters::Presenter
        end
      end
    end
  end

  helpers do
    def permitted_params
      @permitted_params ||= declared(params, include_missing: false)
    end
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/netrusov/grape-cache.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
