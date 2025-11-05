require_relative 'retry'
require 'json'

begin
  puts "===================== successful retry scenario =========================="

  # success
  success_result = call_retry('http://localhost:4567/orders', { 
    user_id: 1,
    total_amount: 20000
  }.to_json, { 'Content-Type' => 'application/json' })

  puts "success_result : #{success_result[:data].parsed_response}"
rescue => e
  puts "error_result : #{e.message}"
end

sleep 2

begin
  puts "===================== retry failed scenario =========================="

  # failed
  error_result = call_retry('http://localhost:4567/simulation_server_problems', { 
    user_id: 1,
    total_amount: 20000
  }.to_json, { 'Content-Type' => 'application/json' })
rescue => e
  puts "error_result : #{e.message}"
end

sleep 2

begin
  puts "===================== retry is not allowed scenario =========================="

  # unauthorized
  error_result2 = call_retry('http://localhost:4567/simulation_unauthorized', { 
    user_id: 1,
    total_amount: 20000
  }.to_json, { 'Content-Type' => 'application/json' })
rescue => e
  puts "error_result : #{e.message}"
end

# test retry : 
# bundle exec ruby test.rb 