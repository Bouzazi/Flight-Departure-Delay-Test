class CreateFlights < ActiveRecord::Migration[7.1]
  def up
    create_table :flights, id: :string do |t|
      t.string :flight_number, null: false
      t.string :airline, null: false
      t.string :origin, null: false
      t.string :destination, null: false
      t.datetime :scheduled_departure_at, null: false
      t.datetime :actual_departure_at
      t.datetime :scheduled_arrival_at, null: false
      t.datetime :actual_arrival_at
      t.datetime :estimated_arrival_at
      t.text :marketing_flights, default: [].to_json
      t.text :delays, default: [].to_json

      t.timestamps
    end

    add_index :flights, [:flight_number, :scheduled_departure_at, :origin], unique: true, name: 'index_flights_on_unique_flight'
  end

  def down
    remove_index :flights, name: 'index_flights_on_unique_flight'
    drop_table :flights
  end
end
