module FlightUtilities 
    def self.remove_duplicates(arr)
      arr.uniq { |hash| [hash[:airline], hash[:flight_number]] }
    end
  end
  