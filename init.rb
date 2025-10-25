require_relative 'lib/engel_webhook'

Redmine::Plugin.register :engel_webhook do
  name 'Engel Webhook Plugin'
  author 'Cristian Kreuz Engel'
  description 'Dispara eventos para uma API externa em cada alteração de tarefa.'
  version '0.0.1'
  url 'https://github.com/CristianKreuzEngel/engel-hook'
  author_url 'https://github.com/CristianKreuzEngel'
  settings default: { 'api_url' => '', 'webhook_custom_headers' => '' }, partial: 'engel_webhook_settings/index'
end