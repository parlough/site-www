const yaml = require('js-yaml');
const markdownIt = require('markdown-it');
const markdownItDefinitionList = require('markdown-it-deflist');
const markdownItAnchor = require('markdown-it-anchor');
const markdownItAttrs = require('markdown-it-attrs');
const { markdownItTable } = require('markdown-it-table');
const eleventySass = require('eleventy-sass');
const shiki = require('shiki');
const htmlParser = require('htmlparser2');
const {findAll, innerText} = require("domutils");

module.exports = function (eleventyConfig) {
  const markdown = markdownIt({html: true})
      .use(markdownItDefinitionList)
      .use(markdownItAttrs, {
        leftDelimiter: '{:',
        rightDelimiter: '}',
        allowedAttributes: ['id', 'class', /^data-.*$/],
      })
      .use(markdownItAnchor, {
        level: 2,
        tabIndex: false,
        permalink: markdownItAnchor.permalink.ariaHidden({
          space: true,
          placement: 'after',
          symbol: '#',
          class: 'heading-link',
        }),
      });
      // .use(markdownItTable) // TODO(parlough): Tables broken

  eleventyConfig.on('eleventy.before', async () => {
    const highlighter = await shiki.getHighlighter({ 
      theme: 'css-variables',
      langs: ['dart', 'yaml', 'json', 'swift', 'css', 'html', 
        'js', 'objc', 'bash', 'kotlin', 'md']
    });
    markdown.set({
      highlight: (str, lang, attrs) => _highlight(highlighter, str, lang, attrs),
    });
  });

  eleventyConfig.setLibrary("md", markdown);
  
  eleventyConfig.addDataExtension('yml,yaml', 
          contents => yaml.load(contents));
  
  eleventyConfig.setLiquidOptions({
    cache: true,
    strictFilters: true,
    // strictVariables: true, TODO(parlough): Enable
    lenientIf: true
  });

  eleventyConfig.addTemplateFormats('scss');

  eleventyConfig.addFilter('regex_replace', function(input, regex, replacement = '') {
    return input.toString().replace(new RegExp(regex), replacement);
  });

  eleventyConfig.addFilter('active_nav_entry_index_array', function(navEntryTree, pageUrlPath = '') {
    const activeEntryIndexes = _getActiveNavEntries(navEntryTree, pageUrlPath);
    return activeEntryIndexes.length === 0 ? null : activeEntryIndexes;
  });

  eleventyConfig.addFilter('array_to_sentence_string', _arrayToSentenceString);
  
  eleventyConfig.addFilter('underscore_breaker', _underscoreBreaker);
  
  eleventyConfig.addFilter('throw_error', function (error) {
    throw new Error(error);
  });
  
  eleventyConfig.addFilter('generate_toc', function (contents) {
    const dom = htmlParser.parseDocument(contents);
    const headers = findAll((e) =>
        e.tagName === 'h2' || e.tagName === 'h3', dom.children);
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
      toc: builtToc,
      count: count
    };
  });
  
  eleventyConfig.addPairedShortcode('WhyLearn', function(content) {
    const renderedContent = markdown.render(content);
    return `
    <div class="mini-toc">
      <h4 class="no_toc">What you'll learn</h4>
      ${renderedContent}
    </div>
    `;
  });

  eleventyConfig.addPairedShortcode('WhyLearn', function(content) {
    const renderedContent = markdown.render(content);
    return `
    <div class="mini-toc">
      <h4 class="no_toc">What you'll learn</h4>
      ${renderedContent}
    </div>
    `;
  });

  eleventyConfig.addPairedShortcode('alert', function(content, type) {
    const renderedContent = markdown.renderInline(content);
    switch (type) {
      case 'important':
        return `
<aside class="alert alert-warning" role="alert">
<i class="material-icons" aria-hidden="true">error</i> <strong>Important:</strong> ${renderedContent}
</aside>`;
      case 'note':
        return `
<aside class="alert alert-info" role="alert">
<i class="material-icons" aria-hidden="true">info</i>${renderedContent}
</aside>`;
      case 'info':
        return `
<aside class="alert alert-info" role="alert">
<i class="material-icons" aria-hidden="true">info</i> <strong>Note:</strong> ${renderedContent}
</aside>`;
      case 'flutter-note':
        return `
<aside class="alert alert-info" role="alert">
<img src="/assets/img/shared/flutter/icon/64.png" width="24" alt="Flutter logo"> <strong>Flutter note</strong>
${renderedContent}
</aside>`;
      case 'version-note':
        return `
<aside class="alert alert-info" role="alert">
<i class="material-icons" aria-hidden="true">merge_type</i> <strong>Version note:</strong> ${renderedContent}
</aside>`;
      case 'secondary':
        return `
<aside class="alert alert-secondary" role="alert">${renderedContent}
</aside>`;
      case 'tip':
        return `
<aside class="alert alert-success" role="alert">
<i class="material-icons" aria-hidden="true">tips_and_updates</i> <strong>Tip:</strong> ${renderedContent}
</aside>`;
      case 'warn':
        return `
<aside class="alert alert-warning" role="alert">
<i class="material-icons" aria-hidden="true">report_problem</i>${renderedContent}
</aside>`;
      case 'warning':
        return `
<aside class="alert alert-warning" role="alert">
<i class="material-icons" aria-hidden="true">report_problem</i> <strong>Warning:</strong> ${renderedContent}
</aside>`;
    }
    throw new Error(`${type} is not supported by the alert shortcode!`);
  });

  eleventyConfig.addPlugin(eleventySass, {
    sass: {
      style: isProduction() ? 'compressed' : 'expanded',
      sourceMap: !isProduction(),
      quietDeps: true
    },
    compileOptions: {
      cache: !isProduction(),
    },
  });

  eleventyConfig.addPassthroughCopy('src/assets/dash');
  eleventyConfig.addPassthroughCopy('src/assets/js');
  eleventyConfig.addPassthroughCopy('src/assets/img',{ expand: true });
  eleventyConfig.addPassthroughCopy('src/assets/shared',{ expand: true, filter: /^(?!_).+/ });
  eleventyConfig.addPassthroughCopy('src/f', { expand: true, filter: /^(?!_).+/ });

  return {
    htmlTemplateEngine: 'liquid',
    dir: {
      input: 'src',
      output: '_site',
      layouts: '_layouts'
    }
  }
};

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
      const isMatch = entry['match-page-url-exactly']
          ? pageUrlPath === entry.permalink
          : pageUrlPath.includes(entry.permalink);

      if (isMatch) {
        return [i + 1];
      }
    }
  }

  return [];
}

function _underscoreBreaker(stringToBreak, inAnchor = false) {
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

function _arrayToSentenceString(list, joiner = 'and') {
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

function _highlight(highlighter, content, language, attributeString) {
  // Skip embedded DartPads.
  if (language.includes('-dartpad') || language.includes('file-')) {
    return content; // TODO
  }
  
  const attributes = _parseAttributes(attributeString);
  
  return highlighter.codeToHtml(content, { lang: language });
}

function _parseAttributes(attributes) {
  const results = {};
  
  const titlePattern = /title:"([^"]+)"/;
  const titleMatch = titlePattern.exec(attributes);
  if (titleMatch) {
    results['title'] = titleMatch[1];
  }

  const lineNumbersPattern = /lineNumbers(:(\d+))?/;
  const lineNumbersMatch = lineNumbersPattern.exec(attributes);
  if (lineNumbersMatch) {
    results['lineNumbers'] = true;
    if (lineNumbersMatch.length >= 3) {
      results['lineNumbersStart'] = lineNumbersMatch[2];
    }
  }
  
  const highlights = [];
  
  const highlightPattern = /3/;
  let highlightMatch;
  while (highlightMatch = highlightPattern.exec(attributes) && highlightMatch) {
    
  }

  results['highlight'] = highlights;
  
  return results;
}

function isProduction() { return process.env.PRODUCTION === 'true' }
