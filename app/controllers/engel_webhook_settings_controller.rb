class EngelWebhookSettingsController < ApplicationController
  layout 'admin'
  before_action :require_admin

  def index
    @settings = Setting.plugin_engel_webhook || {}
  end

  def update
    Setting.plugin_engel_webhook = params[:settings]
    flash[:notice] = l(:notice_successful_update)
    redirect_to plugin_settings_path(:engel_webhook)
  end
end
