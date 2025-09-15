require 'exp_backoff'
require 'byebug'

def api_call_simulation(success_rate = 0.2)
  if rand < success_rate
    puts "Operasi berhasil! 🎉"
    
    {
      "data": {
        "id": 1,
        "title": "Post 15 Name",
        "content": "Post 15 Content",
        "created_at": "2025-09-12T02:04:29.034Z",
        "updated_at": "2025-09-12T02:04:29.034Z"
      }
    }
  else
    puts "Operasi gagal. 😞"
    raise "Kesalahan sementara (Transient Error)."
  end
end

begin
  exponential_backoff = ExpBackoff::Retry.new(3, 0.5, 0.5)

  result = exponential_backoff.run do
    api_call_simulation[:data]
  end

  puts "result : #{result}"
rescue => e
  puts "Error retry : #{e.message}"
end

# bundle exec ruby test.rb