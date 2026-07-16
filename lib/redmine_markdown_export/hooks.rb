# frozen_string_literal: true

module RedmineMarkdownExport
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_body_bottom(context = {})
      controller = context[:controller]
      return '' unless controller.is_a?(IssuesController)
      return '' unless controller.action_name == 'show'

      javascript_include_tag('redmine_markdown_export', plugin: 'redmine_markdown_export')
    end
  end
end
