class MessageSent < ApplicationRecord
  scope :this_month, -> { where("created_at >= ?", Time.now.beginning_of_month) }
end
