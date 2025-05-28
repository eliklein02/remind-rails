class ContactSeason < ApplicationRecord
  belongs_to :contact
  belongs_to :season
end
