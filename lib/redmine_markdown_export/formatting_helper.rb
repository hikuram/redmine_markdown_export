# frozen_string_literal: true

module RedmineMarkdownExport
  module FormattingHelper
    def md_inline(value)
      value.to_s
           .gsub(/\r?\n/, ' ')
           .gsub('\\', '\\\\')
           .gsub('[', '\\[')
           .gsub(']', '\\]')
           .gsub('|', '\\|')
           .strip
           .html_safe
    end

    def md_text(value)
      value.to_s.html_safe
    end

    def md_value(value)
      text = value.to_s.strip
      text.presence || '-'
    end

    def md_filesize(bytes)
      bytes = bytes.to_i

      if bytes >= 1_048_576
        format('%.1f MB', bytes / 1_048_576.0)
      elsif bytes >= 1_024
        format('%.1f KB', bytes / 1_024.0)
      else
        "#{bytes} B"
      end
    end

    def md_absolute_url(path)
      root = Redmine::Utils.relative_url_root.to_s
      root = '' if root == '/'

      full_path = path.start_with?(root) ? path : "#{root}#{path}"

      if defined?(Setting) && Setting.host_name.present?
        protocol = Setting.protocol.to_s.presence || 'http'
        "#{protocol}://#{Setting.host_name}#{full_path}"
      elsif respond_to?(:request) && request
        "#{request.protocol}#{request.host_with_port}#{full_path}"
      else
        full_path
      end
    end

    def md_issue_url(issue)
      md_absolute_url("/issues/#{issue.id}")
    end

    def md_attachment_url(attachment)
      filename = ERB::Util.url_encode(attachment.filename.to_s)
      md_absolute_url("/attachments/download/#{attachment.id}/#{filename}")
    end
  end
end
