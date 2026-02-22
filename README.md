# ExpBackoff

Exp backoff is a Ruby library that implements a retry mechanism with an exponential backoff and jitter strategy. Its purpose is to exponentially increase the wait time between each failed retry attempt. This ensures the system's resilience to failures and allows the affected service time to fully recover.

## High Flow

Potential problems when there is no retry mechanism in our system :

![Logo Ruby](./high_flow/Mekanisme%20Retry-problem.jpg)

With the Exponential Backoff and jitter retry mechanism, our system now has the ability to perform retry :

![Logo Ruby](./high_flow/Mekanisme%20Retry-jitter.jpg)

## Requirement

Minimum software version that must be installed on your device :
- ruby 3.0

Requires dependencies to the following gems :
- httparty

- logger

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
1. implementation in the internal system :
```ruby
require 'exp_backoff'

exp_back = ::ExpBackoff::Jitter.new(strategy: :default, maximum_retry: <your-maximum_retry>, base_delay: <your-base_delay>, max_delay: <your-max_delay>)

begin
  result = exp_back.perform do
    # your logic is here
  end
rescue => e
  # catch error messages here
end
```

description of parameters :
- strategy : retry strategy options, for example : :default.
- maximum_retry : maximum limit for retry, for example : 5.
- base_delay : initial value for calculating the exponential backoff time, for example : 0.5.
- max_delay : initial value for calculating exponential backoff time with jitter, for example : 0.5.

2. implementation to call other systems using rest api :
```ruby
require 'exp_backoff'

exp_back = ::ExpBackoff::Jitter.new(strategy: :rest_api, maximum_retry: <your-maximum_retry>, base_delay: <your-base_delay>, max_delay: <your-max_delay>)

begin
  result = exp_back.perform(url: <your-url>, http_method: <your-http-method>, headers: <your-request-headers>, body: <your-request-body>, timeout: <your-timeout-limit-calling-destination-api> )

  # how to call response code : 
  result.code
  # how to call response body :
  result.body
  # how to call response headers :
  result.headers
rescue => e
  # catch error messages here
end
```

description of parameters :
- strategy : retry strategy options, for example : :rest_api.
- maximum_retry : maximum limit for retry, for example : 5.
- base_delay : initial value for calculating the exponential backoff time, for example : 0.5.
- max_delay : initial value for calculating exponential backoff time with jitter, for example : 0.5.
- url : destination api url, for example : 'https://dummyjson.com/products/1'.
- http_method : the type of http method used to call the target api, for example : :GET / :POST / :PUT / :PATCH / :DELETE.
- headers : request headers, for example : { 'Content-Type': 'application/json' }.
- body : request body, for example : { title: "Produk Dummy Title 1", description: "Produk Dummy Description 1" }.
- timeout : maximum timeout limit in seconds when calling the target api, for example : 10.

For more details, you can see the following example : [example/app.rb](./example/app.rb).

## Example Implementation in Your Application

For examples of applications that use this gem, you can see them here : [example](./example).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/solehudinmq/exp_backoff.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
