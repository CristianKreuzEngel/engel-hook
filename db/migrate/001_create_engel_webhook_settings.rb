class CreateEngelWebhookSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :engel_webhook_settings do |t|
      t.string :api_url, null: false
      t.timestamps
    end
  end
end
