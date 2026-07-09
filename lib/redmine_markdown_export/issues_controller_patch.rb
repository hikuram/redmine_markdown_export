# frozen_string_literal: true

module RedmineMarkdownExport
  module IssuesControllerPatch
    def self.prepended(base)
      base.before_action :render_markdown_export, only: [:show]
    end

    private

    def render_markdown_export
      return unless request.format.symbol == :md

      @journals = @issue.visible_journals_with_index
      @journals.reverse! if User.current.wants_comments_in_reverse_order?

      markdown = render_to_string(
        template: 'issues/show',
        formats: [:md],
        layout: false
      )

      render plain: markdown, content_type: 'text/markdown; charset=utf-8'
    end
  end
end
