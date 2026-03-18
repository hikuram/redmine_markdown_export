# frozen_string_literal: true

module RedmineMarkdownExport
  module IssuesControllerPatch
    def self.prepended(base)
      base.before_action :render_markdown_export, only: [:index, :show]
    end

    private

    def render_markdown_export
      return unless request.format.symbol == :md

      case action_name
      when 'index'
        retrieve_default_query(true)
        retrieve_query(IssueQuery, true)

        unless @query.valid?
          head :unprocessable_entity
          return
        end

        @issues = @query.issues(limit: Setting.issues_export_limit.to_i)
        send_data(
          render_to_string(template: 'issues/index', formats: [:md], layout: false),
          type: 'text/markdown; charset=utf-8',
          filename: "#{filename_for_export(@query, 'issues')}.md"
        )
      when 'show'
        @journals = @issue.visible_journals_with_index
        @journals.reverse! if User.current.wants_comments_in_reverse_order?

        send_data(
          render_to_string(template: 'issues/show', formats: [:md], layout: false),
          type: 'text/markdown; charset=utf-8',
          filename: "#{@project.identifier}-#{@issue.id}.md"
        )
      end
    end
  end
end
