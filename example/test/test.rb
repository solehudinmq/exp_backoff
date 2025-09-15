require 'exp_backoff'
require 'byebug'
require 'httparty'

exponential_backoff = ExpBackoff::Retry.new(max_retries: 3, base_interval: 0.5, max_jitter_factor: 0.5)

# httparty
result = exponential_backoff.run do
  begin
    HTTParty.get('http://localhost:3000/api/data')
  rescue HTTParty::ResponseError => e
    raise ExpBackoff::HttpError.new(e.message, e.response.code)
  rescue => e
    # error lain yang tidak di kenal anggap sebagai error 500
    raise ExpBackoff::HttpError.new(e.message, 500)
  end
end

puts "result : #{result}"

# bundle exec ruby test.rb