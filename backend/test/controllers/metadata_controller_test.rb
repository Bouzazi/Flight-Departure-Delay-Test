require 'test_helper'

class MetadataControllerTest < ActionDispatch::IntegrationTest
  setup do
    @airport1 = Airport.create!(code: 'JFK', label: 'John F. Kennedy International Airport')
    @airport2 = Airport.create!(code: 'LAX', label: 'Los Angeles International Airport')
    @airport3 = Airport.create!(code: 'SFO', label: 'San Francisco International Airport')

    @airline1 = Airline.create!(code: 'AA', label: 'American Airlines')
    @airline2 = Airline.create!(code: 'DL', label: 'Delta Airlines')
  end

  test "should get all airports" do
    get '/api/airports'
    assert_response :success
    airports = JSON.parse(response.body)
    assert_equal 3, airports.size
    assert_includes airports.map { |a| a['code'] }, 'JFK'
    assert_includes airports.map { |a| a['code'] }, 'LAX'
    assert_includes airports.map { |a| a['code'] }, 'SFO'
  end

  test "should search airports by code" do
    get '/api/airports', params: { search: 'JFK' }
    assert_response :success
    airports = JSON.parse(response.body)
    assert_equal 1, airports.size
    assert_equal 'JFK', airports.first['code']
  end

  test "should search airports by label" do
    get '/api/airports', params: { search: 'John' }
    assert_response :success
    airports = JSON.parse(response.body)
    assert_equal 1, airports.size
    assert_equal 'JFK', airports.first['code']
  end

  test "should get all airlines" do
    get '/api/airlines'
    assert_response :success
    airlines = JSON.parse(response.body)
    assert_equal 2, airlines.size
    assert_includes airlines.map { |a| a['code'] }, 'AA'
    assert_includes airlines.map { |a| a['code'] }, 'DL'
  end
end
