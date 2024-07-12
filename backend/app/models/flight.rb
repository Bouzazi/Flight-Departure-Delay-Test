class Flight < ApplicationRecord
  before_create :generate_uuid

  validates :flight_number, presence: true
  validates :airline, presence: true
  validates :origin, presence: true
  validates :destination, presence: true
  validates :scheduled_departure_at, presence: true
  validates :scheduled_arrival_at, presence: true

  serialize :marketing_flights, coder: JSON
  serialize :delays, coder: JSON

  private

  def generate_uuid
    self.id = SecureRandom.uuid
  end
end
