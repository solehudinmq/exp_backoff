require 'exp_backoff'

def fibonacci(n)
  return n if n <= 1

  a, b = 0, 1
  (n - 1).times do
    a, b = b, a + b
  end
  b
end

puts "==========================================================="
puts "1. retry case for using your internal method, and it works."
puts "==========================================================="
result = ::ExpBackoff::Jitter.new(maximum_retry: 3, base_delay: 0.3, max_delay: 0.3)
result.perform do
  fibonacci(10)
end

puts "=================================================================================="
puts "2. retry case for using your internal method, with the final result still failing."
puts "=================================================================================="
result = ::ExpBackoff::Jitter.new(maximum_retry: 3, base_delay: 0.3, max_delay: 0.3)
begin
  result.perform do
    fibonacci(10) + 'b'
  end
rescue => e
  puts e.message
end

# run this command :
# - open terminal
# - cd example
# - bundle install
# - bundle exec ruby app.rb