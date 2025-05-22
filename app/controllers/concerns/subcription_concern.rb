module SubcriptionConcern
  extend ActiveSupport::Concern

  included do
    def is_signed_up?
      false
    end
  end
end
