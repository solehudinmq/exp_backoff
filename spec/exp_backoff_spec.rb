# frozen_string_literal: true

# required to run : bundle exec ruby app.rb
RSpec.describe ExpBackoff do
  before(:all) do
    Order.delete_all
  end

  it "has a version number" do
    expect(ExpBackoff::VERSION).not_to be nil
  end

  it "return successful due to successful retry" do
    exponential_backoff = ExpBackoff::Retry.new(max_retries: 3, base_interval: 0.5, max_jitter_factor: 0.5)

    result = exponential_backoff.run do
      response = HTTParty.post('http://localhost:4567/orders', 
        body: { 
          user_id: 1,
          total_amount: 20000
        }.to_json,
        headers: { 'Content-Type' => 'application/json' },
        timeout: 3
      )

      response
    end
    
    expect(result[:status]).to be('success')
    expect(result[:data].parsed_response["message"]).to eq('success')
  end

  it 'return failed because 3 times failed to retry' do
    begin
      exponential_backoff = ExpBackoff::Retry.new(max_retries: 3, base_interval: 0.5, max_jitter_factor: 0.5)

      result = exponential_backoff.run do
        response = HTTParty.post('http://localhost:4567/simulation_server_problems', 
          body: { 
            user_id: 1,
            total_amount: 20000
          }.to_json,
          headers: { 'Content-Type' => 'application/json' },
          timeout: 3
        )

        response
      end
    rescue => e
      expect(e.message).to be('The number of retry failures has reached the maximum.')
    end
  end

  it 'return rejected because the status code is invalid for retry' do
    begin
      exponential_backoff = ExpBackoff::Retry.new(max_retries: 3, base_interval: 0.5, max_jitter_factor: 0.5)

      result = exponential_backoff.run do
        response = HTTParty.post('http://localhost:4567/simulation_unauthorized', 
          body: { 
            user_id: 1,
            total_amount: 20000
          }.to_json,
          headers: { 'Content-Type' => 'application/json' },
          timeout: 3
        )

        response
      end
    rescue => e
      expect(e.message).to eq('Your response status code is 401, only status codes 408, 429, 500, 502, 503, 504 can be retried.')
    end
  end
end
