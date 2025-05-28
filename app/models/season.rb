class Season < ApplicationRecord
  acts_as_tenant :organization
  has_many :contact_seasons, dependent: :destroy
  has_many :contacts, through: :contact_seasons, dependent: :destroy
end
