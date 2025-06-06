class MessageReceived < ApplicationRecord
    acts_as_tenant :organization
end
