class MessageSent < ApplicationRecord
  acts_as_tenant :organization
  belongs_to :contact
  scope :this_month, -> { where("created_at >= ?", Time.now.beginning_of_month) }
end
