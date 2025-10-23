# frozen_string_literal: true

# required to run : bundle exec ruby app.rb
RSpec.describe ExpBackoff do
  it "has a version number" do
    expect(ExpBackoff::VERSION).not_to be nil
  end

  it "return successful due to successful retry" do
    result = call_retry('http://localhost:4567/orders', { 
      user_id: 1,
      total_amount: 20000
    }.to_json, { 'Content-Type' => 'application/json' })
    
    expect(result[:status]).to be('success')
    expect(result[:data].parsed_response["message"]).to eq('success')
  end

  it 'return failed because 3 times failed to retry' do
    result = call_retry('http://localhost:4567/simulation_server_problems', { 
      user_id: 1,
      total_amount: 20000
    }.to_json, { 'Content-Type' => 'application/json' })
    
    expect(result[:status]).to be('fail')
    expect(result[:error_message]).to be('The number of retry failures has reached the maximum.')
  end

  it 'return rejected because the status code is invalid for retry' do
    result = call_retry('http://localhost:4567/simulation_unauthorized', { 
      user_id: 1,
      total_amount: 20000
    }.to_json, { 'Content-Type' => 'application/json' })

    
    expect(result[:status]).to be('fail')
    expect(result[:error_message]).to be('Retry is not allowed for this status code.')
  end
end
