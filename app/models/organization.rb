class Organization < ApplicationRecord
  include SubcriptionConcern
  pay_customer stripe_attributes: :stripe_attributes

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :textgrid_account_sid, presence: true
  validates :textgrid_phone_number, presence: true

  enum :organization_type, [ :school, :shul ]

  has_many :contacts, dependent: :destroy
  has_many :message_sents, dependent: :destroy
  has_many :seasons, dependent: :destroy

  def stripe_attributes(pay_customer)
    {
      address: {
        city: self.city,
        country: self.country
      },
      metadata: {
        id: pay_customer&.id,
        organization_id: id
      }
    }
  end
end
