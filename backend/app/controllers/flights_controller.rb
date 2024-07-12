class FlightsController < ApplicationController
  rescue_from ProviderOneService::FetchDataError, with: :handle_fetch_data_error
  rescue_from ProviderTwoService::FetchDataError, with: :handle_fetch_data_error

  def fetch_flights_from_provider_1
    service = ProviderOneService.new
    url = ProviderOneService::BASE_URL

    while url
      result = service.fetch_data(url)
      if result[:status] != :ok
        render json: { error: result[:error] }, status: result[:status]
        return
      end

      parsed_response = result[:data]
      flights = parsed_response.dig("FlightStatusResource", "Flights", "Flight")
      meta = parsed_response.dig("FlightStatusResource", "Meta")

      if flights.nil?
        Rails.logger.error("No flights data found in response")
        render json: { error: "No flights data found" }, status: :unprocessable_entity
        return
      end

      FlightProcessor.process_flights_provider_1(flights)

      url = service.next_link(meta)
    end
  end

  def fetch_flights_from_provider_2
    service = ProviderTwoService.new
    result = service.fetch_data

    if result[:status] != :ok
      render json: { error: result[:error] }, status: result[:status]
      return
    end

    flights = result[:data]
    if flights.nil?
      Rails.logger.error("No flights data found in response")
      render json: { error: "No flights data found" }, status: :unprocessable_entity
      return
    end

    FlightProcessor.process_flights_provider_2(flights)
  end

  def fetch_flights
    fetch_flights_from_provider_1
    fetch_flights_from_provider_2

    render json: { message: 'Flights fetched, merged and stored successfully' }
  end

  
  def index
    flights = Flight.all
    enriched_flights = enrich_flights(flights)
    render json: enriched_flights
  end

  def search
    begin
      flights = Flight.where(destination: params[:destination])

      if params[:airlines].present?
        airline_codes = params[:airlines].split(',')
        flights = flights.where(airline: airline_codes)

        if params[:include_marketing_flights] == 'true'
          marketing_flights = Flight.where(destination: params[:destination])
                                    .where(airline_codes.map { |code| "marketing_flights LIKE '%\"airline\":\"#{code}\"%'" }.join(' OR '))
          flights = flights.or(marketing_flights)
        end
      end

      enriched_flights = enrich_flights(flights)
      render json: enriched_flights
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  private

  def enrich_flights(flights)
    airport_codes = flights.pluck(:origin, :destination).flatten.uniq
    airline_codes = flights.pluck(:airline).uniq

    airports = fetch_airports(airport_codes)
    airlines = fetch_airlines(airline_codes)

    flights.map do |flight|
      flight.attributes.merge(
        origin: airports[flight.origin],
        destination: airports[flight.destination],
        airline: airlines[flight.airline]
      )
    end
  end

  def fetch_airports(codes)
    codes.each_with_object({}) do |code, hash|
      hash[code] = Rails.cache.fetch("airport_#{code}", expires_in: 1.week) do
        Airport.find_by(code: code)
      end
    end
  end

  def fetch_airlines(codes)
    codes.each_with_object({}) do |code, hash|
      hash[code] = Rails.cache.fetch("airline_#{code}", expires_in: 1.week) do
        Airline.find_by(code: code)
      end
    end
  end

  def handle_fetch_data_error(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
