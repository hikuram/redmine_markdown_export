(function() {
  'use strict';

  function setupMarkdownCopy() {
    var pageMatch = window.location.pathname.match(/^(.*\/issues\/[0-9]+)(?:\..*)?$/);
    if (!pageMatch) return;

    var markdownUrl = pageMatch[1] + '.md';
    var contextMenus = document.querySelectorAll('#content > .contextual');

    Array.prototype.forEach.call(contextMenus, function(contextMenu) {
      var issueCopyLink = findIssueCopyLink(contextMenu);
      if (!issueCopyLink || issueCopyLink.dataset.markdownCopyPatched === 'true') return;

      var duplicateUrl = issueCopyLink.getAttribute('href');
      if (!duplicateUrl) return;

      addDuplicateIssueLink(contextMenu, issueCopyLink, duplicateUrl);
      patchIssueCopyLink(issueCopyLink, markdownUrl);
    });
  }

  function findIssueCopyLink(contextMenu) {
    var links = contextMenu.querySelectorAll('a[href]');

    for (var i = 0; i < links.length; i += 1) {
      var link = links[i];
      try {
        var url = new URL(link.href, window.location.href);
        if (/\/issues\/[0-9]+\/copy$/.test(url.pathname)) {
          return link;
        }
      } catch (error) {
        // Ignore malformed links.
      }
    }

    return null;
  }

  function addDuplicateIssueLink(contextMenu, issueCopyLink, duplicateUrl) {
    var menuItems = contextMenu.querySelector('.drdn .drdn-items');
    if (!menuItems) return;
    if (menuItems.querySelector('a[data-markdown-export-duplicate-link="true"]')) return;

    var duplicateLink = issueCopyLink.cloneNode(true);
    duplicateLink.href = duplicateUrl;
    duplicateLink.title = 'Duplicate issue';
    duplicateLink.dataset.markdownExportDuplicateLink = 'true';
    duplicateLink.removeAttribute('id');
    duplicateLink.removeAttribute('accesskey');
    duplicateLink.removeAttribute('data-markdown-copy-original-label');
    duplicateLink.removeAttribute('data-markdown-copy-original-title');
    duplicateLink.removeAttribute('data-markdown-copy-patched');
    duplicateLink.removeAttribute('data-markdown-copy-url');
    setLinkLabel(duplicateLink, 'Duplicate issue');

    var deleteLink = menuItems.querySelector('a.icon-del, a[data-method="delete"]');
    if (deleteLink) {
      menuItems.insertBefore(document.createTextNode(' '), deleteLink);
      menuItems.insertBefore(duplicateLink, deleteLink);
    } else {
      menuItems.appendChild(document.createTextNode(' '));
      menuItems.appendChild(duplicateLink);
    }
  }

  function patchIssueCopyLink(issueCopyLink, markdownUrl) {
    var originalLabel = getLinkLabel(issueCopyLink) || 'Copy';
    var originalTitle = issueCopyLink.getAttribute('title') || '';

    issueCopyLink.dataset.markdownCopyOriginalLabel = originalLabel;
    issueCopyLink.dataset.markdownCopyOriginalTitle = originalTitle;
    issueCopyLink.dataset.markdownCopyPatched = 'true';
    issueCopyLink.dataset.markdownCopyUrl = markdownUrl;
    issueCopyLink.href = markdownUrl;
    issueCopyLink.title = 'Copy Markdown';

    issueCopyLink.addEventListener('click', function(event) {
      event.preventDefault();
      event.stopPropagation();

      setTemporaryLinkState(issueCopyLink, 'Building...', null, 0);

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
          setTemporaryLinkState(issueCopyLink, 'Copied', 'Copy Markdown', 2000);
        })
        .catch(function(error) {
          console.error(error);
          setTemporaryLinkState(issueCopyLink, 'Copy failed', 'Copy Markdown', 3000);
          window.alert('Failed to copy Markdown. Check issue visibility, the /issues/:id.md response, and browser clipboard permission.');
        });
    });
  }

  function getLabelElement(link) {
    return link.querySelector('.icon-label') || link;
  }

  function getLinkLabel(link) {
    return getLabelElement(link).textContent;
  }

  function setLinkLabel(link, text) {
    getLabelElement(link).textContent = text;
  }

  function setTemporaryLinkState(link, label, title, timeout) {
    var originalLabel = link.dataset.markdownCopyOriginalLabel || 'Copy';
    var originalTitle = link.dataset.markdownCopyOriginalTitle || '';

    setLinkLabel(link, label);
    if (title) {
      link.title = title;
    }

    if (timeout > 0) {
      window.setTimeout(function() {
        setLinkLabel(link, originalLabel);
        link.title = originalTitle || 'Copy Markdown';
      }, timeout);
    }
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

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupMarkdownCopy);
  } else {
    setupMarkdownCopy();
  }
})();
