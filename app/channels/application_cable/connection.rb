module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_organization

    def connect
      self.current_organization = find_verified_organization
    end

    private

    def find_verified_organization
      # env['warden'] is how you access the Warden proxy that Devise uses
      # .user(scope) gets the authenticated user for the given scope.
      # If your Devise model is Organization, the scope is likely :organization.
      verified_organization = env["warden"].user

      if verified_organization
        # puts "Devise/Warden found verified organization: #{verified_organization.name} (ID: #{verified_organization.id})"
        verified_organization
      else
        # puts "Devise/Warden did not find an authenticated organization. Rejecting connection."
        reject_unauthorized_connection
      end
    end
  end
end
