# frozen_string_literal: true

Mime::Type.register 'text/markdown', :md unless Mime::Type.lookup_by_extension(:md)

Redmine::Plugin.register :redmine_markdown_export do
  name 'Redmine Markdown Export'
  author 'Wellbia'
  description 'Adds Markdown export format to issues (list and detail views)'
  version '1.0.0'
  url 'https://github.com/wellbia/redmine_markdown_export'
  requires_redmine version_or_higher: '5.0'
end

Rails.application.config.after_initialize do
  require_dependency File.expand_path('../lib/redmine_markdown_export/formatting_helper', __FILE__)
  require_dependency File.expand_path('../lib/redmine_markdown_export/issues_controller_patch', __FILE__)
  require_dependency File.expand_path('../lib/redmine_markdown_export/hooks', __FILE__)

  ActionView::Base.include RedmineMarkdownExport::FormattingHelper
  IssuesController.prepend RedmineMarkdownExport::IssuesControllerPatch
end
