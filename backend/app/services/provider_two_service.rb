class ProviderTwoService
    require 'httparty'
  
    BASE_URL = 'https://challenge.usecosmos.cloud/flight_delays.json'
  
    class FetchDataError < StandardError; end
  
    # Suppress HTTParty deprecation warning
    HTTParty::Response.class_eval do
      def warn_about_nil_deprecation
      end
    end
  
    def fetch_data
      response = HTTParty.get(BASE_URL)
      Rails.logger.info("URL: #{BASE_URL}")
  
      if response.code != 200 || response.body.nil? || response.body.empty?
        Rails.logger.error("Failed to fetch data: #{response.message}")
        raise FetchDataError, "Failed to fetch data from #{BASE_URL}"
      end
  
      { data: response.parsed_response, status: :ok }
    end
  end
  