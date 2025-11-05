# ExpBackoff

Exp backoff is a Ruby library that implements a retry mechanism with an exponential backoff and jitter strategy. Its purpose is to exponentially increase the wait time between each failed retry attempt. This ensures the system's resilience to failures and allows the affected service time to fully recover.

With the Exp backoff library, our applications now have the ability to perform retry processes automatically. This retry strategy works well in combination with circuit breakers and rollback mechanisms when the number of retry failures reaches a maximum.

## High Flow

Potential problems when there is no retry mechanism in our system :

![Logo Ruby](https://github.com/solehudinmq/exp_backoff/blob/development/high_flow/Mekanisme%20Retry-problem.jpg)

With the Exponential Backoff and jitter retry mechanism, our system now has the ability to perform retry :

![Logo Ruby](https://github.com/solehudinmq/exp_backoff/blob/development/high_flow/Mekanisme%20Retry-jitter.jpg)

## Requirement

The minimum version of Ruby that must be installed is 3.0.

Requires dependencies to the following gems :
- httparty

## Installation

Add this line to your application's Gemfile :

```ruby
# Gemfile
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

exponential_backoff = ExpBackoff::Retry.new(max_retries: max_retries, base_interval: base_interval, max_jitter_factor: max_jitter_factor)

result = exponential_backoff.run do
  # call api third party here (must use httparty gem)
end
```

description of parameters :
- max_retries (optional) = the maximum number of retries the system will perform ( default value is 5 ).
- base_interval (optional) = this is the base value to start the exponential backoff calculation ( default value is 0.5 ).
- max_jitter_factor (optional) = a random factor added to the wait time to prevent multiple clients from retrying at the same time ( default value is 0.5 ).

For more details, you can see the following example : [example/retry.rb](https://github.com/solehudinmq/exp_backoff/blob/development/example/retry.rb).

## Example Implementation in Your Application

For examples of applications that use this gem, you can see them here : [example](https://github.com/solehudinmq/exp_backoff/tree/development/example).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/solehudinmq/exp_backoff.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
