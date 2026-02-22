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
exp_back = ::ExpBackoff::Jitter.new(strategy: :default, maximum_retry: 3, base_delay: 0.3, max_delay: 0.3)
begin
  result = exp_back.perform do
    fibonacci(10)
  end

  puts "Result : #{result}"
rescue => e
  puts "Error : #{e.message}"
end

puts "=================================================================================="
puts "2. retry case for using your internal method, with the final result still failing."
puts "=================================================================================="
exp_back = ::ExpBackoff::Jitter.new(strategy: :default, maximum_retry: 3, base_delay: 0.3, max_delay: 0.3)
begin
  result = exp_back.perform do
    fibonacci(10) + 'b'
  end

  puts "Result : #{result}"
rescue => e
  puts "Error : #{e.message}"
end

puts "===================================================================="
puts "3. retry case to call the target api with :GET method, and it works."
puts "===================================================================="
exp_back = ::ExpBackoff::Jitter.new(strategy: :rest_api, maximum_retry: 3, base_delay: 0.3, max_delay: 0.3)
begin
  result = exp_back.perform(url: "https://dummyjson.com/products/1", http_method: :GET, headers: { 'Content-Type': 'application/json' }, timeout: 5 )

  puts "Result : #{result}"
rescue => e
  puts "Error : #{e.message}"
end

puts "===================================================================="
puts "4. retry case to call the target api with :POST method, and it works."
puts "===================================================================="
exp_back = ::ExpBackoff::Jitter.new(strategy: :rest_api, maximum_retry: 3, base_delay: 0.3, max_delay: 0.3)
begin
  result = exp_back.perform(url: "https://dummyjson.com/products/add", http_method: :POST, headers: { 'Content-Type': 'application/json' }, body: { title: "Produk Dummy Title 1", description: "Produk Dummy Description 1" }, timeout: 5 )

  puts "Result : #{result}"
rescue => e
  puts "Error : #{e.message}"
end

puts "===================================================================="
puts "5. retry case to call the target api with :PUT method, and it works."
puts "===================================================================="
exp_back = ::ExpBackoff::Jitter.new(strategy: :rest_api, maximum_retry: 3, base_delay: 0.3, max_delay: 0.3)
begin
  result = exp_back.perform(url: "https://dummyjson.com/products/1", http_method: :PUT, headers: { 'Content-Type': 'application/json' }, body: { title: "Produk Dummy Title 1 - PUT", description: "Produk Dummy Description 1 - PUT" }, timeout: 5 )

  puts "Result : #{result}"
rescue => e
  puts "Error : #{e.message}"
end

puts "======================================================================"
puts "6. retry case to call the target api with :PATCH method, and it works."
puts "======================================================================"
exp_back = ::ExpBackoff::Jitter.new(strategy: :rest_api, maximum_retry: 3, base_delay: 0.3, max_delay: 0.3)
begin
  result = exp_back.perform(url: "https://dummyjson.com/products/1", http_method: :PATCH, headers: { 'Content-Type': 'application/json' }, body: { title: "Produk Dummy Title 1 - PATCH" }, timeout: 5 )

  puts "Result : #{result}"
rescue => e
  puts "Error : #{e.message}"
end

puts "======================================================================"
puts "7. retry case to call the target api with :DELETE method, and it works."
puts "======================================================================"
exp_back = ::ExpBackoff::Jitter.new(strategy: :rest_api, maximum_retry: 3, base_delay: 0.3, max_delay: 0.3)
begin
  result = exp_back.perform(url: "https://dummyjson.com/products/1", http_method: :DELETE, headers: { 'Content-Type': 'application/json' }, timeout: 5 )

  puts "Result : #{result}"
rescue => e
  puts "Error : #{e.message}"
end

puts "====================================================================="
puts "8. retry case to call the target api with :GET method, and it failed."
puts "====================================================================="
exp_back = ::ExpBackoff::Jitter.new(strategy: :rest_api, maximum_retry: 3, base_delay: 0.3, max_delay: 0.3)
begin
  result = exp_back.perform(url: "https://dummyjson.com/products/1?delay=3000", http_method: :GET, headers: { 'Content-Type': 'application/json' }, timeout: 2 )

  puts "Result : #{result}"
rescue => e
  puts "Error : #{e.message}"
end

# run this command :
# - open terminal
# - cd example
# - bundle install
# - bundle exec ruby app.rb