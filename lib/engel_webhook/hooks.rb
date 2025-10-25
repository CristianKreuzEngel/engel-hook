require 'net/http'
require 'uri'
require 'json'
require 'openssl'

module EngelWebhook
  class Hooks < Redmine::Hook::Listener

    # Quando uma issue é criada
    def controller_issues_new_after_save(context = {})
      send_event('created', context[:issue], context[:journal])
    end

    # Quando uma issue é atualizada
    def controller_issues_edit_after_save(context = {})
      issue = context[:issue]
      journal = context[:journal]
      send_event('updated', issue, journal)
    end

    private

    def send_event(event_type, issue, journal = nil)
      api_url = Setting.plugin_engel_webhook['api_url']
      custom_headers_json = Setting.plugin_engel_webhook['webhook_custom_headers']
      return if api_url.blank?

      issue_old, issue_new, changed_fields, note_text = build_issue_diff(issue, journal)

      payload = {
        event: event_type,
        issue_id: issue.id,
        project: issue.project.name,
        subject: issue.subject,
        changed_fields: changed_fields,
        issue_old: issue_old,
        issue_new: issue_new,
        notes: note_text
      }

      uri = URI.parse(api_url)
      headers = { 'Content-Type' => 'application/json' }

      begin
        if custom_headers_json.present?
          custom_headers = JSON.parse(custom_headers_json)
          custom_headers.each { |k, v| headers[k.to_s] = v.to_s }
        end
      rescue JSON::ParserError => e
        Rails.logger.error "[engel_webhook] Erro ao processar headers JSON: #{e.message}"
      end

      json_body = payload.to_json
      json_body.force_encoding('UTF-8')

      Thread.new do
        begin
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = (uri.scheme == 'https')
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == 'https'
          request = Net::HTTP::Post.new(uri.request_uri, headers)
          request.body = json_body
          response = http.request(request)
          Rails.logger.info "[engel_webhook] Enviado evento '#{event_type}' para #{api_url} | Status: #{response.code}"
        rescue => e
          Rails.logger.error "[engel_webhook] Falha ao enviar webhook: #{e.class} - #{e.message}"
        end
      end
    end

def build_issue_diff(issue, journal)
  return [{}, issue_to_hash(issue), [], nil] if journal.nil?

  old_data = {}
  new_data = {}
  changed_fields = []

  journal.details.each do |detail|
    field_name =
      case detail.property
      when 'attr'
        case detail.prop_key
        when 'status_id'
          'Status'
        when 'priority_id'
          'Prioridade'
        when 'assigned_to_id'
          'Atribuído a'
        else
          detail.prop_key
        end
      when 'cf'
        custom_field = CustomField.find_by_id(detail.prop_key)
        custom_field ? custom_field.name : "CustomField##{detail.prop_key}"
      else
        detail.prop_key
      end

    changed_fields << field_name
    old_data[field_name] = translate_value(detail.prop_key, detail.old_value)
    new_data[field_name] = translate_value(detail.prop_key, detail.value)
  end

  note_text = journal.user&.name.to_s + ': ' + (journal.notes.presence || '')

  [old_data, new_data, changed_fields.uniq, note_text]
end


    def translate_value(prop_key, value)
      return nil if value.nil?

      case prop_key
      when 'status_id'
        IssueStatus.find_by_id(value)&.name || value
      when 'priority_id'
        IssuePriority.find_by_id(value)&.name || value
      when 'assigned_to_id'
        User.find_by_id(value)&.name || value
      else
        value
      end
    end

    def issue_to_hash(issue)
      {
        id: issue.id,
        subject: issue.subject,
        status: issue.status.name,
        tracker: issue.tracker.name,
        priority: issue.priority.name,
        author: issue.author.name,
        assigned_to: issue.assigned_to&.name,
        project: issue.project.name,
        updated_on: issue.updated_on,
        created_on: issue.created_on,
        custom_fields: issue.custom_field_values.each_with_object({}) do |cv, h|
          h[cv.custom_field.name] = cv.value
        end
      }
    end
  end
end
