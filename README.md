# ExpBackoff

Exp backoff is a Ruby library that implements a retry mechanism with an exponential backoff and jitter strategy. Its purpose is to exponentially increase the wait time between each failed retry attempt. This ensures the system's resilience to failures and allows the affected service time to fully recover.

With the Exp backoff library, our applications now have the ability to perform retry processes automatically. This retry strategy works well in combination with circuit breakers and rollback mechanisms when the number of retry failures reaches a maximum.

## High Flow

Potential problems when there is no retry mechanism in our system :
![Logo Ruby](https://github.com/solehudinmq/exp_backoff/blob/development/high_flow/Mekanisme%20Retry-problem.jpg)

With the Exponential Backoff and jitter retry mechanism, our system now has the ability to perform retry :
![Logo Ruby](https://github.com/solehudinmq/exp_backoff/blob/development/high_flow/Mekanisme%20Retry-jitter.jpg)

## Installation

The minimum version of Ruby that must be installed is 3.0.

Add this line to your application's Gemfile :

```ruby
gem 'exp_backoff', git: 'git@github.com:solehudinmq/exp_backoff.git', branch: 'main'
```

Open terminal, and run this : 
```bash
cd your_ruby_application
bundle install
```

## Usage

In your ruby ​​code, add this :
```ruby
require 'exp_backoff'

exponential_backoff = ExpBackoff::Retry.new(max_retries: 3, base_interval: 1, max_jitter_factor: 1)

result = exponential_backoff.run do
  # call api service here 
end
```

description of parameters :
- max_retries = the maximum number of retries the system will perform ( default value is 5 ).
- base_interval = this is the base value to start the exponential backoff calculation ( default value is 0.5 ).
- max_jitter_factor = a random factor added to the wait time to prevent multiple clients from retrying at the same time ( default value is 0.5 ).

When you want to do a retry, call this class :
```ruby
# usually a retry is performed when the server response is 408, 429, 500, 502, 503 or 504.
raise ExpBackoff::Error::HttpError.new(error_message, status_code)
```

How to use it in your application :
- Gemfile : 
```ruby
# Gemfile
# frozen_string_literal: true

source "https://rubygems.org"

gem "sinatra"
gem 'exp_backoff', git: 'git@github.com:solehudinmq/exp_backoff.git', branch: 'main'
gem "byebug"
gem 'httparty'
gem "activerecord"
gem "sqlite3"
gem "rackup", "~> 2.2"
gem "puma", "~> 7.1"
```

- order.rb : 
```ruby
# order.rb
require 'sinatra'
require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/development.sqlite3'
)

Dir.mkdir('db') unless File.directory?('db')

class Order < ActiveRecord::Base
end

ActiveRecord::Schema.define do
  unless ActiveRecord::Base.connection.table_exists?(:orders)
    create_table :orders do |t|
        t.integer :user_id
        t.date :order_date
        t.decimal :total_amount
        t.string :status, default: :waiting
        t.timestamps
    end
  end
end
```

- app.rb
```ruby
# app.rb
require 'sinatra'
require 'json'
require 'byebug'

require_relative 'order'

before do
  content_type :json
end

# create data order success
post '/orders' do
  begin
    request_body = JSON.parse(request.body.read)

    # save request data to redis queue
    order = Order.new(request_body)
    
    if order.save
      { order_id: order.id, message: 'success' }.to_json
    else
      status 400
      return { error: order.errors.message }.to_json
    end
  rescue => e
    status 500
    return { error: e.message }.to_json
  end
end

# server errors simulations
post '/simulation_server_problems' do
  status 503
  return { error: 'The server is having problems.' }.to_json
end

# unauthorized simulations
post '/simulation_unauthorized' do
  status 401
  return { error: 'Unauthorized' }.to_json
end

# get data orders
get '/orders' do
  begin
    orders = Order.all

    { count: orders.size, orders: orders }.to_json
  rescue => e
    status 500
    return { error: e.message }.to_json
  end
end

# ====== run producer ======
# 1. open terminal
# 2. cd your_project
# 3. bundle install
# 4. bundle exec ruby app.rb
# 5. create data order
# curl --location 'http://localhost:4567/orders' \
# --header 'Content-Type: application/json' \
# --data '{
#     "user_id": 1,
#     "total_amount": 30000
# }'
# 6. get data order
# curl --location 'http://localhost:4567/orders'
```

- retry.rb
```ruby
# retry.rb
require 'exp_backoff'
require 'byebug'
require 'httparty'

def call_retry(url, request_body, headers)
  exponential_backoff = ExpBackoff::Retry.new(max_retries: 3, base_interval: 0.5, max_jitter_factor: 0.5)

  # httparty
  result = exponential_backoff.run do
    response = HTTParty.post(url, 
      body: request_body,
      headers: headers,
      timeout: 3
    )

    status_code = response.code

    if [408, 429, 500, 502, 503, 504].include?(status_code)
      raise ExpBackoff::Error::HttpError.new(response.parsed_response["error"], status_code)
    elsif status_code.to_s.start_with?('2')
      response
    end
  end
  
  result
end
```

- test.rb
```ruby
# test.rb
require_relative 'retry'
require 'json'

puts "===================== successful retry scenario =========================="

# retry successful
success_result = call_retry('http://localhost:4567/orders', { 
  user_id: 1,
  total_amount: 20000
}.to_json, { 'Content-Type' => 'application/json' })

puts "success_result : #{success_result[:data].parsed_response}"

sleep 2
puts "===================== retry failed scenario =========================="

# retry failed
error_result = call_retry('http://localhost:4567/simulation_server_problems', { 
  user_id: 1,
  total_amount: 20000
}.to_json, { 'Content-Type' => 'application/json' })

puts "error_result : #{error_result[:error_message]}"

sleep 2
puts "===================== retry is not allowed scenario =========================="

# no retry allowed
error_result2 = call_retry('http://localhost:4567/simulation_unauthorized', { 
  user_id: 1,
  total_amount: 20000
}.to_json, { 'Content-Type' => 'application/json' })

puts "error_result 2 : #{error_result2[:error_message]}"

# test retry : 
# bundle exec ruby test.rb 
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/solehudinmq/exp_backoff.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
