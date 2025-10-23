# frozen_string_literal: true

# required to run : bundle exec ruby app.rb
RSpec.describe ExpBackoff do
  def success_simulation
    { message: "Data received successfully!" }
  end

  it "has a version number" do
    expect(ExpBackoff::VERSION).not_to be nil
  end

  it "retry successful on first try, with default parameters" do
    eb = ExpBackoff::Retry.new
    result = eb.run do 
      success_simulation
    end

    expect(result[:status]).to be('success')
    expect(result[:data][:message]).to be('Data received successfully!')
  end

  it "retry successful on first try, with external parameters" do
    eb = ExpBackoff::Retry.new(max_retries: 3, base_interval: 0.5, max_jitter_factor: 0.5)
    result = eb.run do 
      success_simulation
    end

    expect(result[:status]).to be('success')
    expect(result[:data][:message]).to be('Data received successfully!')
  end

  it 'retry failed on first try, with default parameters & status code is 503' do
    eb = ExpBackoff::Retry.new
    result = eb.run do
      call_retry('http://localhost:4567/simulation_server_problems', { 
        user_id: 1,
        total_amount: 20000
      }.to_json, { 'Content-Type' => 'application/json' })
    end
    
    expect(result[:status]).to be('fail')
    expect(result[:error_message]).to be('The number of retry failures has reached the maximum.')
  end
end
