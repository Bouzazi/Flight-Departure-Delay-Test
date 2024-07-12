class CreateAirports < ActiveRecord::Migration[7.1]
  def up
    create_table :airports, id: false do |t|
      t.string :code, primary_key: true
      t.string :label
    end

    Airport.create!([
      { code: 'FRA', label: 'Frankfurt Airport' },
      { code: 'MXP', label: 'Milan Malpensa Airport' },
      { code: 'IST', label: 'Istanbul Airport' },
      { code: 'LEJ', label: 'Leipzig/Halle Airport' },
      { code: 'BSL', label: 'EuroAirport Basel-Mulhouse-Freiburg' },
      { code: 'HAJ', label: 'Hannover Airport' },
      { code: 'ZRH', label: 'Zurich Airport' },
      { code: 'STR', label: 'Stuttgart Airport' },
      { code: 'BLQ', label: 'Bologna Guglielmo Marconi Airport' },
      { code: 'TIV', label: 'Tivat Airport' },
      { code: 'CGN', label: 'Cologne Bonn Airport' },
      { code: 'HAM', label: 'Hamburg Airport' },
      { code: 'PMI', label: 'Palma de Mallorca Airport' },
      { code: 'FLR', label: 'Florence Airport' },
      { code: 'RIX', label: 'Riga International Airport' },
      { code: 'MUC', label: 'Munich Airport' },
      { code: 'VCE', label: 'Venice Marco Polo Airport' },
      { code: 'SOF', label: 'Sofia Airport' },
      { code: 'BER', label: 'Berlin Brandenburg Airport' },
      { code: 'DBV', label: 'Dubrovnik Airport' },
      { code: 'LHR', label: 'London Heathrow Airport' },
      { code: 'AMM', label: 'Queen Alia International Airport' },
      { code: 'CAI', label: 'Cairo International Airport' },
      { code: 'HEL', label: 'Helsinki-Vantaa Airport' },
      { code: 'DUB', label: 'Dublin Airport' },
      { code: 'ZAD', label: 'Zadar Airport' },
      { code: 'OSL', label: 'Oslo Airport' },
      { code: 'KRK', label: 'Kraków John Paul II International Airport' },
      { code: 'VIE', label: 'Vienna International Airport' }
    ])
  end

  def down
    drop_table :airports
  end
end
