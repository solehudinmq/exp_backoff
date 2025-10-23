require_relative 'retry'
require 'json'

puts "===================== successful retry scenario =========================="

# success
success_result = call_retry('http://localhost:4567/orders', { 
  user_id: 1,
  total_amount: 20000
}.to_json, { 'Content-Type' => 'application/json' })

puts "success_result : #{success_result[:data].parsed_response}"

sleep 2
puts "===================== retry failed scenario =========================="

# failed
error_result = call_retry('http://localhost:4567/simulation_server_problems', { 
  user_id: 1,
  total_amount: 20000
}.to_json, { 'Content-Type' => 'application/json' })

puts "error_result : #{error_result[:error_message]}"

sleep 2
puts "===================== retry is not allowed scenario =========================="

# unauthorized
error_result2 = call_retry('http://localhost:4567/simulation_unauthorized', { 
  user_id: 1,
  total_amount: 20000
}.to_json, { 'Content-Type' => 'application/json' })

puts "error_result 2 : #{error_result2[:error_message]}"

# test retry : 
# bundle exec ruby test.rb 