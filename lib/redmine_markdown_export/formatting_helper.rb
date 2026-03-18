# frozen_string_literal: true

module RedmineMarkdownExport
  module FormattingHelper
    def md_cell(value)
      value.to_s.gsub('|', '\\|').gsub(/\r?\n/, ' ').html_safe
    end

    def md_text(value)
      value.to_s.html_safe
    end

    def md_filesize(bytes)
      if bytes >= 1_048_576
        format('%.1f MB', bytes / 1_048_576.0)
      elsif bytes >= 1_024
        format('%.1f KB', bytes / 1_024.0)
      else
        "#{bytes} B"
      end
    end
  end
end
