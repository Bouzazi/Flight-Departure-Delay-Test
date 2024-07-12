class CreateAirlines < ActiveRecord::Migration[7.1]
  def up
    create_table :airlines, id: false do |t|
      t.string :code, primary_key: true
      t.string :label
    end

    Airline.create!([
      { code: 'OS', label: 'Austrian Airlines' },
      { code: 'TK', label: 'Turkish Airlines' },
      { code: 'EW', label: 'Eurowings' },
      { code: 'BT', label: 'Air Baltic' },
      { code: 'LH', label: 'Lufthansa' },
      { code: 'BA', label: 'British Airways' },
      { code: 'AY', label: 'Finnair' },
      { code: 'EI', label: 'Aer Lingus' },
      { code: 'AC', label: 'Air Canada' },
      { code: 'SK', label: 'Scandinavian Airlines' },
      { code: 'MS', label: 'EgyptAir' },
      { code: 'OU', label: 'Croatia Airlines' },
      { code: 'LO', label: 'LOT Polish Airlines' },
      { code: 'UA', label: 'United Airlines' }
    ])
  end

  def down
    drop_table :airlines
  end
end
