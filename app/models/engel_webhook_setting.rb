class EngelWebhookSetting < ApplicationRecord
  validates :api_url, presence: true
end
