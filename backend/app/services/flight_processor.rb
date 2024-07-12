class FlightProcessor
  def self.process_flights_provider_1(flights)
    flights.each do |flight|
      flight_number = flight.dig("OperatingCarrier", "FlightNumber")
      airline = flight.dig("OperatingCarrier", "AirlineID")
      origin = flight.dig("Departure", "AirportCode")
      destination = flight.dig("Arrival", "AirportCode")
      scheduled_departure_at = flight.dig("Departure", "ScheduledTimeUTC", "DateTime")
      actual_departure_at = flight.dig("Departure", "ActualTimeUTC", "DateTime")
      scheduled_arrival_at = flight.dig("Arrival", "ScheduledTimeUTC", "DateTime")
      actual_arrival_at = flight.dig("Arrival", "ActualTimeUTC", "DateTime")
      estimated_arrival_at = flight.dig("Arrival", "EstimatedTimeUTC", "DateTime")

      marketing_flight = {
        airline: flight.dig("MarketingCarrier", "AirlineID"),
        flight_number: flight.dig("MarketingCarrier", "FlightNumber")
      }

      # Find or create the flight
      new_flight = Flight.find_or_create_by(
        flight_number: flight_number,
        scheduled_departure_at: scheduled_departure_at,
        origin: origin
      )

      Rails.logger.debug("Existing marketing flights before addition: #{new_flight.marketing_flights}")

      # Merge marketing flights ensuring uniqueness
      existing_marketing_flights = new_flight.marketing_flights || []
      unless marketing_flight_exists?(existing_marketing_flights, marketing_flight)
        Rails.logger.debug("Adding marketing flight: #{marketing_flight}")
        existing_marketing_flights << marketing_flight
      else
        Rails.logger.debug("Marketing flight already exists: #{marketing_flight}")
      end
      merged_marketing_flights = remove_duplicates(existing_marketing_flights)

      Rails.logger.debug("Merged marketing flights after removing duplicates: #{merged_marketing_flights}")

      # Update existing flight details
      new_flight.update(
        airline: airline,
        destination: destination,
        scheduled_arrival_at: scheduled_arrival_at,
        actual_departure_at: actual_departure_at,
        actual_arrival_at: actual_arrival_at,
        estimated_arrival_at: estimated_arrival_at,
        marketing_flights: merged_marketing_flights
      )

      if new_flight.persisted?
        Rails.logger.info("Successfully updated flight: #{new_flight}")
      else
        Rails.logger.error("Failed to save flight: #{new_flight.errors.full_messages}")
      end
    end   
  end

  def self.process_flights_provider_2(flights)
    flights.each do |flight|
      flight_number = flight.dig("Flight", "OperatingFlight", "Number")
      airline = flight.dig("Flight", "OperatingFlight", "Airline")
      origin = flight.dig("FlightLegs", 0, "Departure", "Station", "IATA")
      destination = flight.dig("FlightLegs", 0, "Arrival", "Station", "IATA")
      scheduled_departure_at = flight.dig("FlightLegs", 0, "Departure", "ScheduledDepartureTime")
      actual_departure_at = flight.dig("FlightLegs", 0, "Departure", "ActualDepartureTime")
      scheduled_arrival_at = flight.dig("FlightLegs", 0, "Arrival", "ScheduledArrivalTime")
      actual_arrival_at = flight.dig("FlightLegs", 0, "Arrival", "ActualArrivalTime")
      estimated_arrival_at = flight.dig("FlightLegs", 0, "Arrival", "EstimatedArrivalTime")

      marketing_flights = []
      if flight.dig("Flight", "MarketingFlights")
        flight.dig("Flight", "MarketingFlights").each do |mf|
          marketing_flight = {
            airline: mf["Airline"],
            flight_number: mf["Number"]
          }
          unless marketing_flight_exists?(marketing_flights, marketing_flight)
            Rails.logger.debug("Adding marketing flight: #{marketing_flight}")
            marketing_flights << marketing_flight
          else
            Rails.logger.debug("Marketing flight already exists: #{marketing_flight}")
          end
        end
      end

      delays = []
      if flight.dig("FlightLegs", 0, "Departure", "Delay")
        delays_hash = flight.dig("FlightLegs", 0, "Departure", "Delay")
        delays_hash.each do |key, value|
          next if value.nil?
          delays << {
            code: value["Code"],
            time_minutes: value["DelayTime"],
            description: value["Description"]
          }
        end
      end

      # Find or create the flight
      new_flight = Flight.find_or_create_by(
        flight_number: flight_number,
        scheduled_departure_at: scheduled_departure_at,
        origin: origin
      )

      Rails.logger.debug("Existing marketing flights before addition: #{new_flight.marketing_flights}")

      # Merge marketing flights ensuring uniqueness
      existing_marketing_flights = new_flight.marketing_flights || []
      marketing_flights.each do |marketing_flight|
        unless marketing_flight_exists?(existing_marketing_flights, marketing_flight)
          Rails.logger.debug("Adding marketing flight: #{marketing_flight}")
          existing_marketing_flights << marketing_flight
        else
          Rails.logger.debug("Marketing flight already exists: #{marketing_flight}")
        end
      end
      merged_marketing_flights = remove_duplicates(existing_marketing_flights)

      Rails.logger.debug("Merged marketing flights after removing duplicates: #{merged_marketing_flights}")

      # Update existing flight details
      new_flight.update(
        airline: airline,
        destination: destination,
        scheduled_arrival_at: scheduled_arrival_at,
        actual_departure_at: actual_departure_at,
        actual_arrival_at: actual_arrival_at,
        estimated_arrival_at: estimated_arrival_at,
        marketing_flights: merged_marketing_flights,
        delays: delays.presence || new_flight.delays
      )

      if new_flight.persisted?
        Rails.logger.info("Successfully updated flight: #{new_flight}")
      else
        Rails.logger.error("Failed to save flight: #{new_flight.errors.full_messages}")
      end
    end
  end

  def self.marketing_flight_exists?(existing_flights, new_flight)
    existing_flights.any? { |flight| flight['airline'] == new_flight[:airline] && flight['flight_number'] == new_flight[:flight_number] }
  end

  def self.remove_duplicates(arr)
    arr.uniq { |hash| hash.to_a }
  end
end
