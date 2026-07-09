# frozen_string_literal: true

module RedmineMarkdownExport
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_body_bottom(context = {})
      controller = context[:controller]
      return '' unless controller.is_a?(IssuesController)
      return '' unless controller.action_name == 'show'

      <<~'HTML'.html_safe
        <style>
        a.markdown-copy-button {
          background-image: none;
          border: 1px solid #999;
          border-radius: 4px;
          color: #555 !important;
          display: inline-block;
          font-size: 1.2rem;
          line-height: 1.4;
          margin-left: 6px;
          padding: 4px 10px;
          text-decoration: none;
        }
        a.markdown-copy-button:hover {
          background-color: #eee;
          color: #222 !important;
          text-decoration: none;
        }
        a.markdown-copy-button.is-success {
          border-color: #3a7;
          color: #275 !important;
        }
        a.markdown-copy-button.is-error {
          border-color: #c66;
          color: #933 !important;
        }
        </style>
        <script>
        (function() {
          'use strict';

          if (document.getElementById('markdown-copy-button')) return;

          var match = window.location.pathname.match(/^(.*\/issues\/[0-9]+)(?:\..*)?$/);
          if (!match) return;

          var target = document.querySelector('#content > .contextual') ||
                       document.querySelector('.other-formats');
          if (!target) return;

          var button = document.createElement('a');
          button.id = 'markdown-copy-button';
          button.className = 'markdown-copy-button';
          button.href = '#';
          button.rel = 'nofollow';
          button.textContent = 'Markdown Copy';

          target.appendChild(button);

          function setButtonState(text, className) {
            button.textContent = text;
            button.classList.remove('is-success', 'is-error');
            if (className) button.classList.add(className);
          }

          function copyWithFallback(text) {
            if (navigator.clipboard && window.isSecureContext) {
              return navigator.clipboard.writeText(text);
            }

            var textarea = document.createElement('textarea');
            textarea.value = text;
            textarea.setAttribute('readonly', 'readonly');
            textarea.style.position = 'fixed';
            textarea.style.left = '-9999px';
            textarea.style.top = '0';
            document.body.appendChild(textarea);
            textarea.focus();
            textarea.select();

            try {
              document.execCommand('copy');
              return Promise.resolve();
            } catch (error) {
              return Promise.reject(error);
            } finally {
              document.body.removeChild(textarea);
            }
          }

          button.addEventListener('click', function(event) {
            event.preventDefault();

            var markdownUrl = match[1] + '.md';
            setButtonState('Building Markdown...', null);

            fetch(markdownUrl, {
              credentials: 'same-origin',
              headers: {
                'Accept': 'text/markdown, text/plain, */*'
              }
            })
              .then(function(response) {
                if (!response.ok) {
                  throw new Error('HTTP ' + response.status);
                }
                return response.text();
              })
              .then(function(markdown) {
                return copyWithFallback(markdown);
              })
              .then(function() {
                setButtonState('Copied', 'is-success');
                window.setTimeout(function() {
                  setButtonState('Markdown Copy', null);
                }, 2000);
              })
              .catch(function(error) {
                console.error(error);
                setButtonState('Copy Failed', 'is-error');
                window.alert('Failed to copy Markdown. Check issue visibility, the /issues/:id.md response, and browser clipboard permission.');
                window.setTimeout(function() {
                  setButtonState('Markdown Copy', null);
                }, 3000);
              });
          });
        })();
        </script>
      HTML
    end
  end
end
