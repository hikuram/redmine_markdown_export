# frozen_string_literal: true

module RedmineMarkdownExport
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_body_bottom(context = {})
      controller = context[:controller]
      return '' unless controller.is_a?(IssuesController)
      return '' unless %w[index show].include?(controller.action_name)

      <<~HTML.html_safe
        <style>
        .other-formats a.md {
          background-image: none;
          border-radius: 4px;
          padding: 8px 14px;
          font-size: 1.3rem;
          text-decoration: none;
          border: 1px solid #999;
          margin-right: 4px;
          color: #999 !important;
        }
        .other-formats a.md:hover {
          background-color: #999 !important;
          color: #FFFFFF !important;
        }
        </style>
        <script>
        (function() {
          var p = document.querySelector('.other-formats');
          if (!p) return;
          var span = document.createElement('span');
          var a = document.createElement('a');
          a.className = 'md';
          var url = new URL(window.location.href);
          url.searchParams.set('format', 'md');
          url.searchParams.delete('page');
          a.href = url.toString();
          a.rel = 'nofollow';
          a.textContent = 'Markdown';
          span.appendChild(a);
          p.appendChild(span);
        })();
        </script>
      HTML
    end
  end
end
