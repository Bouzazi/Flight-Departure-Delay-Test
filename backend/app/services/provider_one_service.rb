class ProviderOneService
    require 'httparty'
  
    BASE_URL = 'https://challenge.usecosmos.cloud/flight_schedules.json'
  
    class FetchDataError < StandardError; end
  
    # Suppress HTTParty deprecation warning
    HTTParty::Response.class_eval do
      def warn_about_nil_deprecation
      end
    end
  
    def fetch_data(url = BASE_URL)
      response = HTTParty.get(url)
      Rails.logger.info("URL: #{url}")
  
      if response.code != 200 || response.body.nil? || response.body.empty?
        Rails.logger.error("Failed to fetch data: #{response.message}")
        raise FetchDataError, "Failed to fetch data from #{url}"
      end
  
      { data: response.parsed_response, status: :ok }
    end

    def next_link(meta)
      return nil unless meta && meta["Link"]
  
      next_link = meta["Link"].find { |link| link["@Rel"] == "next" }
      next_link ? next_link["@Href"] : nil
    end
  end
  