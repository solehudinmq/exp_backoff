# ExpBackoff

Exp backoff is a Ruby library that implements a retry mechanism with an exponential backoff strategy. Its purpose is to exponentially increase the wait time between each failed retry attempt. This ensures the system's resilience to failures and allows the affected service time to fully recover.

With the Exp backoff library, our applications now have the ability to perform retry processes automatically. This retry strategy works well in combination with circuit breakers and rollback mechanisms when the number of retry failures reaches a maximum.

## High Flow

Potential problems when there is no retry mechanism in our system :
![Logo Ruby](https://github.com/solehudinmq/exp_backoff/blob/development/high_flow/Exp%20Backoff.jpg)

With the Exponential Backoff retry mechanism, our system now has the ability to perform retry :
![Logo Ruby](https://github.com/solehudinmq/exp_backoff/blob/development/high_flow/Exp%20Backoff-solution.jpg)

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

If the server has a problem when calling the service, then call this class with the status code must be 5xx :
```ruby
if e.response.code.to_s.start_with?('5')
  raise ExpBackoff::HttpError.new(e.message, e.response.code)
end
```

Or if there is another unknown error, you can do this (set the second parameter to 500) : 

```ruby
raise ExpBackoff::HttpError.new('Server bermasalah', 500)
```

How to use it in your application :
```ruby
# Gemfile
source "https://rubygems.org"

gem 'exp_backoff', git: 'git@github.com:solehudinmq/exp_backoff.git', branch: 'main'
gem 'httparty'
```

```ruby
# test.rb
require 'exp_backoff'

def api_call(url, header, body)
  HTTParty.post(url,
    body: body.to_json,
    headers: header
  )
end

exponential_backoff = ExpBackoff::Retry.new(max_retries: 3, base_interval: 1, max_jitter_factor: 1)

result = exponential_backoff.run do
  begin
    api_call('http://localhost:4567/sync', { 'Content-Type'=> 'application/json' }, { "user_id": 1, "total_amount": 50000 })
  rescue HTTParty::ResponseError => e
    # if error 5xx call this class to retry.
    if e.response.code.to_s.start_with?('5')
      raise ExpBackoff::HttpError.new(e.message, e.response.code)
    end
  rescue => e
    # if the error is unknown call this class to perform a retry, with the second parameter value set to 500.
    raise ExpBackoff::HttpError.new('Server bermasalah', 500)
  end
end

# cd your_project
# bundle install
# bundle exec ruby test.rb
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/solehudinmq/exp_backoff.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
