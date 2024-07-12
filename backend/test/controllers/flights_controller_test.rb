require 'test_helper'
require 'mocha/minitest'

class FlightsControllerTest < ActionDispatch::IntegrationTest
  # Setup test data
  setup do
    @airport1 = Airport.create!(code: 'JFK', label: 'John F. Kennedy International Airport')
    @airport2 = Airport.create!(code: 'LAX', label: 'Los Angeles International Airport')
    @airline1 = Airline.create!(code: 'AA', label: 'American Airlines')
    @airline2 = Airline.create!(code: 'DL', label: 'Delta Airlines')
    @flight = Flight.create!(
      id: SecureRandom.uuid,
      flight_number: 'AA100',
      airline: 'AA',
      origin: 'JFK',
      destination: 'LAX',
      scheduled_departure_at: '2024-07-12 06:00:00',
      scheduled_arrival_at: '2024-07-12 09:00:00'
    )
  end

  test "should fetch flights from both providers" do
    ProviderOneService.any_instance.stubs(:fetch_data).returns(status: :ok, data: { "FlightStatusResource" => { "Flights" => { "Flight" => [] }, "Meta" => {} } })
    ProviderTwoService.any_instance.stubs(:fetch_data).returns(status: :ok, data: [])

    get '/api/flights/fetch_flights'
    assert_response :success
    assert_equal 'Flights fetched, merged and stored successfully', JSON.parse(response.body)['message']
  end

  test "should handle errors from provider one" do
    ProviderOneService.any_instance.stubs(:fetch_data).raises(ProviderOneService::FetchDataError, "Provider One Error")
    
    get '/api/flights/fetch_flights'
    assert_response :bad_request
    assert_equal 'Provider One Error', JSON.parse(response.body)['error']
  end

  test "should handle errors from provider two" do
    ProviderOneService.any_instance.stubs(:fetch_data).returns(status: :ok, data: { "FlightStatusResource" => { "Flights" => { "Flight" => [] }, "Meta" => {} } })
    ProviderTwoService.any_instance.stubs(:fetch_data).raises(ProviderTwoService::FetchDataError, "Provider Two Error")
    
    get '/api/flights/fetch_flights'
    assert_response :bad_request
    assert_equal 'Provider Two Error', JSON.parse(response.body)['error']
  end

  test "should get index" do
    get '/api/flights'
    assert_response :success
    assert_not_nil JSON.parse(response.body)
  end

  test "should search flights by destination" do
    get '/api/flights/search', params: { destination: 'LAX' }
    assert_response :success
    assert_not_nil JSON.parse(response.body)
  end

  test "should search flights by destination and airlines" do
    get '/api/flights/search', params: { destination: 'LAX', airlines: 'AA,DL' }
    assert_response :success
    assert_not_nil JSON.parse(response.body)
  end

  test "should search flights and include marketing flights" do
    get '/api/flights/search', params: { destination: 'LAX', airlines: 'AA', include_marketing_flights: 'true' }
    assert_response :success
    assert_not_nil JSON.parse(response.body)
  end

  test "should handle search errors" do
    Flight.stubs(:where).raises(StandardError, "Search error")
    
    get '/api/flights/search', params: { destination: 'LAX' }
    assert_response :unprocessable_entity
    assert_equal 'Search error', JSON.parse(response.body)['error']
  end
end
