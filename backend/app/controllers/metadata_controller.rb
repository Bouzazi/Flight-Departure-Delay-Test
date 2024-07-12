class MetadataController < ApplicationController
  def airports
    if params[:search].present?
      search_term = "%#{sanitize_sql_like(params[:search])}%"
      airports = Airport.where('label LIKE ? OR code LIKE ?', search_term, search_term)
    else
      airports = Airport.all
    end
    render json: airports
  end

  def airlines
    airlines = Airline.all
    render json: airlines
  end

  private

  # Method to sanitize user input for SQL LIKE queries
  def sanitize_sql_like(string)
    ActiveRecord::Base.sanitize_sql_like(string)
  end
end
