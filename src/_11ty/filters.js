const htmlParser = require('htmlparser2');
const {findAll, innerText} = require('domutils');
const getPage = require('./utils/get-page');

function regexReplace(input, regex, replacement = '') {
  return input.toString().replace(new RegExp(regex), replacement);
}

function toISOString(input) {
  if (input instanceof Date) {
    return input.toISOString();
  } else {
    return input;
  }
}

function activeNavEntryIndexArray(navEntryTree, pageUrlPath = '') {
  const activeEntryIndexes = _getActiveNavEntries(navEntryTree, pageUrlPath);
  return activeEntryIndexes.length === 0 ? null : activeEntryIndexes;
}

function _getActiveNavEntries(navEntryTree, pageUrlPath = '') {
  for (let i = 0; i < navEntryTree.length; i++) {
    const entry = navEntryTree[i];

    if (entry.children) {
      const descendantIndexes = _getActiveNavEntries(entry.children, pageUrlPath);
      if (descendantIndexes.length > 0) {
        return [i + 1, ...descendantIndexes];
      }
    }

    if (entry.permalink) {
      const isMatch = entry['match-page-url-exactly'] ? pageUrlPath === entry.permalink : pageUrlPath.includes(entry.permalink);

      if (isMatch) {
        return [i + 1];
      }
    }
  }

  return [];
}

function arrayToSentenceString(list, joiner = 'and') {
  if (!list || list.length === 0) {
    return '';
  }

  if (list.length === 1) {
    return list[0];
  }

  let result = '';

  for (let i = 0; i < list.length; i++) {
    const item = list[i];
    if (i === list.length - 1) {
      result += `${joiner} ${item}`;
    } else {
      result += `${item}, `;
    }
  }

  return result;
}

function underscoreBreaker(stringToBreak, inAnchor = false) {
  // Only consider text which has underscores in it to keep this simpler.
  if (!stringToBreak.includes('_')) {
    return stringToBreak;
  }

  if (inAnchor) {
    // If the replacement is to be done inside an anchor,
    // we don't want to replace the href,
    // just the inner text content.
    return stringToBreak.replace(/>([a-zA-Z_]*?)</g, (match) => {
      return `>${match[1].replace('_', '_<wbr>')}<`;
    });
  }

  return stringToBreak.replace('_', '_<wbr>');
}

function generateToc(contents) {
  const dom = htmlParser.parseDocument(contents);
  const headers = findAll((e) => e.tagName === 'h2' || e.tagName === 'h3', dom.children);
  let currentH2 = null;
  const builtToc = [];
  let count = 0;
  for (const header of headers) {
    const id = header.attribs.id;
    // Header can't be linked to without an ID.
    if (id === null || id === '') {
      continue;
    }

    // Don't include if no_toc is specified.
    if (header.attribs.class?.includes('no_toc')) {
      continue;
    }

    // Remove # added by markdown-it-anchor.
    const text = innerText(header)
        .replace(/#$/, '').trim();

    if (header.tagName === 'h2') {
      currentH2 = {text: text, id: `#${id}`, children: []};
      builtToc.push(currentH2);
      count += 1;
    } else if (header.tagName === 'h3') {
      // A h3 must be under a h2 header.
      if (currentH2 === null) {
        continue;
      }

      currentH2.children.push({text: text, id: `#${id}`});
      count += 1;
    }
  }

  return {
    toc: builtToc, count: count
  };
}

function breadcrumbsForPage(page) {
  const breadcrumbs = [];

  let data = this.context.environments;

  while (page) {
    const urlSegments = page.url.split('/').filter(segment => segment.length > 0);

    breadcrumbs.push({
      title: data['breadcrumb'] ?? data['short-title'] ?? data.title, url: page.url,
    });

    if (urlSegments.length <= 1) {
      // The root page, no more ancestors
      break;
    } else {
      // Assume the last part is "index.html" and go to the parent directory
      const parentUrl = `/${urlSegments.slice(0, -1).join('/')}/`;
      // Continue with the parent page
      const parentPage = getPage(this.context.environments.collections.all, parentUrl);
      page = parentPage?.page;
      data = parentPage?.data;
    }
  }

  return breadcrumbs.reverse();
}

module.exports = {
  regexReplace,
  toISOString,
  activeNavEntryIndexArray,
  arrayToSentenceString,
  underscoreBreaker,
  generateToc,
  breadcrumbsForPage,
};
