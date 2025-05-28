class Contact < ApplicationRecord
  acts_as_tenant :organization
  has_many :message_sents, dependent: :destroy
  has_many :contact_seasons, dependent: :destroy
  has_many :seasons, through: :contact_seasons

  validates :number, uniqueness: true, presence: true

  after_create_commit :to_e164

  enum :opted_in_status, [ :was_not_asked, :opted_in, :opted_out ]

  def to_e164
    phone = self.phone
    phone.gsub!(/[^0-9]/, "")
    phone = "+1#{phone[0..2]}#{phone[3..5]}#{phone[6..9]}" if phone.length === 10
    phone = "+1#{phone[1..3]}#{phone[4..6]}#{phone[7..10]}" if phone.length === 11
    self.update_column(:phone, phone)
  end

  def self.opt_all_in
    Contact.update_all(opted_in_status: 1)
  end
end
