class Place < ActiveRecord::Base
  validates :name, :description, :rating, :address, presence: true
  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }

  geocoded_by :address
  after_validation :geocode, :if => :address_changed?
end
