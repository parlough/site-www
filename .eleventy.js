const yaml = require('js-yaml');
const markdownIt = require('markdown-it');
const markdownItDefinitionList = require('markdown-it-deflist');
const markdownItAnchor = require('markdown-it-anchor');
const markdownItAttrs = require('markdown-it-attrs');
const {markdownItTable} = require('markdown-it-table');
const eleventySass = require('eleventy-sass');
const htmlParser = require('htmlparser2');
const {findAll, innerText} = require('domutils');
const slugify = require('@sindresorhus/slugify');

module.exports = function (eleventyConfig) {
  const markdown = markdownIt({html: true})
      .use(markdownItTable)
      .use(markdownItDefinitionList)
      .use(markdownItAttrs, {
        leftDelimiter: '{:',
        rightDelimiter: '}',
        allowedAttributes: ['id', 'class', /^data-.*$/],
      })
      .use(markdownItAnchor, {
        slugify: s => slugify(s),
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
    const {getHighlighter} = await import('shikiji')
    const {toHtml} = await import('hast-util-to-html');
    const {toText} = await import('hast-util-to-text');
    const highlighter = await getHighlighter({
      langs: ['dart', 'yaml', 'json', 'swift', 'css', 'html', 'xml',
        'js', 'objc', 'bash', 'kotlin', 'java', 'md', 'diff']
    });

    await highlighter.loadTheme(import('./11ty/dash-light.json', {
      assert: {type: 'json'}
    }));

    // markdown.set({
    //   highlight: (str, lang, attrs) => 
    //       _highlight(highlighter, toHtml, toText, str, lang, attrs),
    // });

    markdown.renderer.rules.fence = function (tokens, index, options, env, self) {
      const token = tokens[index];

      const splitTokenInfo = token.info.match(/(\S+)\s?(.*?)$/m);
      const language = splitTokenInfo.length > 1 ? splitTokenInfo[1] : '';
      const attributes = splitTokenInfo.length > 2 ? splitTokenInfo[2] : '';

      return _highlight(highlighter, toHtml, toText, token.content, language, attributes);
    };

  });
  
  eleventyConfig.addGlobalData('isProduction', isProduction());

  eleventyConfig.setLibrary('md', markdown);

  eleventyConfig.addDataExtension('yml,yaml',
      contents => yaml.load(contents));

  eleventyConfig.setLiquidOptions({
    cache: true,
    strictFilters: true,
    // strictVariables: true, TODO(parlough): Enable
    lenientIf: true
  });

  eleventyConfig.addTemplateFormats('scss');

  eleventyConfig.addFilter('regex_replace', function (input, regex, replacement = '') {
    return input.toString().replace(new RegExp(regex), replacement);
  });

  eleventyConfig.addFilter('toISOString', function (input) {
    if (input instanceof Date) {
      return input.toISOString();
    } else {
      return input;
    }
  });

  eleventyConfig.addFilter('active_nav_entry_index_array', function (navEntryTree, pageUrlPath = '') {
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

  eleventyConfig.addPairedShortcode('WhyLearn', function (content) {
    const renderedContent = markdown.render(content);
    return `
    <div class="mini-toc">
      <h4 class="no_toc">What you'll learn</h4>
      ${renderedContent}
    </div>
    `;
  });

  eleventyConfig.addPairedShortcode('WhyLearn', function (content) {
    const renderedContent = markdown.render(content);
    return `
    <div class="mini-toc">
      <h4 class="no_toc">What you'll learn</h4>
      ${renderedContent}
    </div>
    `;
  });

  eleventyConfig.addPairedShortcode('alert', function (content, type) {
    const renderedContent = markdown.renderInline(content);
    switch (type) {
      case 'important':
        return `
<aside class="alert alert-warning">
<i class="material-icons" aria-hidden="true">error</i> <strong>Important:</strong> ${renderedContent}
</aside>`;
      case 'note':
        return `
<aside class="alert alert-info">
<i class="material-icons" aria-hidden="true">info</i>${renderedContent}
</aside>`;
      case 'info':
        return `
<aside class="alert alert-info">
<i class="material-icons" aria-hidden="true">info</i> <strong>Note:</strong> ${renderedContent}
</aside>`;
      case 'flutter-note':
        return `
<aside class="alert alert-info">
<img src="/assets/img/shared/flutter/icon/64.png" width="24" alt="Flutter logo"> <strong>Flutter note</strong>
${renderedContent}
</aside>`;
      case 'version-note':
        return `
<aside class="alert alert-info">
<i class="material-icons" aria-hidden="true">merge_type</i> <strong>Version note:</strong> ${renderedContent}
</aside>`;
      case 'secondary':
        return `
<aside class="alert alert-secondary">${renderedContent}
</aside>`;
      case 'tip':
        return `
<aside class="alert alert-success">
<i class="material-icons" aria-hidden="true">tips_and_updates</i> <strong>Tip:</strong> ${renderedContent}
</aside>`;
      case 'warn':
        return `
<aside class="alert alert-warning">
<i class="material-icons" aria-hidden="true">report_problem</i>${renderedContent}
</aside>`;
      case 'warning':
        return `
<aside class="alert alert-warning">
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
  eleventyConfig.addPassthroughCopy('src/assets/img', {expand: true});
  eleventyConfig.addPassthroughCopy('src/assets/shared', {expand: true, filter: /^(?!_).+/});
  eleventyConfig.addPassthroughCopy('src/f', {expand: true, filter: /^(?!_).+/});

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

function _highlight(highlighter, toHtml, toText, content, language, attributeString) {
  // Skip embedded DartPads.
  if (language.includes('-dartpad') || language.includes('file-')) {
    return content; // TODO
  }

  const attributes = attributeString === '' ? {} : JSON.parse(attributeString);

  const tree = highlighter.codeToHast(content, {lang: language, theme: 'dash-light'});

  const pre = tree.children[0];

  // Remove hard coded background color and text color if present.
  pre.properties['style'] = '';

  const highlightEntries = attributes['highlight'];
  if (highlightEntries) {
    for (const highlight of highlightEntries) {
      _wrapTargetWord(tree, highlight, toText);
    }
  }

  const blockBody = {
    type: 'element',
    tagName: 'div',
    children: [
      pre // pre with highlighted content
    ],
    properties: {
      'class': 'code-block-body'
    }
  };

  const wrapper = {
    type: 'element',
    tagName: 'div',
    children: [
      blockBody,
    ],
    properties: {
      'class': 'code-block-wrapper'
    }
  };

  // TODO: Don't support arbitrary tag, require a list
  // Also support special "language" tag
  const extraTag = attributes['tag'];
  if (extraTag) {
    blockBody.properties['class'] += ` ${extraTag.class}`;

    if (extraTag.text) {
      const extraTagContent = {
        type: 'element',
        tagName: 'span',
        children: [
          {type: 'text', value: extraTag.text}
        ],
        properties: {
          'class': 'code-block-tag'
        }
      };

      blockBody.children.unshift(extraTagContent);
    }
  }

  const title = attributes['title'];
  if (title && title !== '') {
    const titleElement = {
      type: 'element',
      tagName: 'div',
      children: [
        {type: 'text', value: title}
      ],
      properties: {
        'class': 'code-block-header'
      }
    };

    wrapper.children.unshift(titleElement);
  }

  tree.children = [wrapper];

  return toHtml(tree);
}

function _wrapTargetWord(ast, highlight, toText) {
  /** @type {Array<number>} */
  const instances = highlight['instances'];
  /** @type {string} */
  const targetWord = highlight['target'];
  const targetLength = targetWord.length;

  if (targetLength < 1) {
    return;
  }

  for (const line of ast.children[0].children[0].children) {
    const spans = line.children;
    if (!spans || spans.length < 1) continue;

    const output = toText(line);

    const startingIndices = getStartingIndices(output, targetWord);

    if (startingIndices.length < 1) {
      continue;
    }

    const newChildren = [];

    let currentIndex = 0;

    let wrapper;

    for (const span of spans) {
      if (startingIndices.length < 1) break;
      const targetStartIndex = startingIndices[0];
      const targetEndIndex = startingIndices[0] + targetLength;

      const spanText = toText(span);
      const nextStartIndex = currentIndex + spanText.length;

      // If wrapper is not null, at least start should be added to it.
      if (wrapper) {
        const extraCharacters = nextStartIndex - targetEndIndex;

        if (extraCharacters === 0) {
          wrapper.children.push(span);
          newChildren.push(wrapper);
        } else if (extraCharacters < 0) {
          // If current instance ends after span, just include the whole thing.
          wrapper.children.push(span);
        } else {
          // Otherwise, the instance ends within this span. Split it up.
          const splitIndex = spanText.length - extraCharacters;
          const firstHalf = spanText.substring(0, splitIndex);
          const secondHalf = spanText.substring(splitIndex);

          const firstSpan = structuredClone(span);
          firstSpan.children[0].value = firstHalf;
          wrapper.children.push(firstSpan);

          newChildren.push(wrapper);

          const secondSpan = structuredClone(span);
          secondSpan.children[0].value = secondHalf;
          newChildren.push(secondSpan);
        }
      }
      // Check if this span at least contains part of the target word.
      else if (targetStartIndex < nextStartIndex) {
        // Four cases: Whole, at beginning, in middle, or at end
        const extraCharacters = nextStartIndex - targetEndIndex;

        const newWrapper = createWrapper();

        // If whole is target:
        if (extraCharacters <= 0) {
          newWrapper.children.push(span);
          wrapper = newWrapper;
        }
        // If at beginning, but ends in span, split
        else if (currentIndex === targetStartIndex) {
          const firstHalf = spanText.substring(0, spanText.length);
          const secondHalf = spanText.substring(spanText.length);

          const firstSpan = structuredClone(span);
          firstSpan.children[0].value = firstHalf;
          newWrapper.children.push(firstSpan);

          newChildren.push(newWrapper);

          const secondSpan = structuredClone(span);
          secondSpan.children[0].value = secondHalf;
          newChildren.push(secondSpan);
        }
        // If in middle and ends in span, split
        else if (extraCharacters > 0) {
          const beforeTarget = spanText.substring(0, targetStartIndex);
          const duringTarget = spanText.substring(targetStartIndex, targetEndIndex);
          const afterTarget = spanText.substring(targetEndIndex);

          const beforeSpan = structuredClone(span);
          beforeSpan.children[0].value = beforeTarget;
          newChildren.push(beforeSpan);

          const duringTargetSpan = structuredClone(span);
          duringTargetSpan.children[0].value = duringTarget;
          newWrapper.children.push(duringTargetSpan);

          newChildren.push(newWrapper);

          const afterSpan = structuredClone(span);
          afterSpan.children[0].value = afterTarget;
          newChildren.push(afterSpan);
        } else {
          // If at end and doesn't end in span
          const firstHalf = spanText.substring(0, spanText.length);
          const secondHalf = spanText.substring(spanText.length);

          const firstSpan = structuredClone(span);
          firstSpan.children[0].value = firstHalf;
          newChildren.push(firstSpan);

          const secondSpan = structuredClone(span);
          secondSpan.children[0].value = secondHalf;
          newWrapper.children.push(secondSpan);

          // newChildren.push(newWrapper);
          wrapper = newWrapper;
        }
      } else {
        // This span does not contain any part of the target word.
        newChildren.push(span);
      }

      currentIndex = nextStartIndex;

      // If this instance of the target word is complete, move to the next one.
      if (targetEndIndex <= currentIndex) {
        wrapper = null;
        startingIndices.shift();
      }
    }

    line.children = newChildren;
  }
}

function getStartingIndices(source, target) {
  const targetLength = target.length;
  if (targetLength === 0) {
    return [];
  }

  let initialIndex = 0;
  const result = [];
  let index;

  while ((index = source.indexOf(target, initialIndex)) > -1) {
    result.push(index);
    initialIndex = index + targetLength;
  }

  return result;
}

function createWrapper() {
  return {type: 'element', tagName: 'mark', children: [], properties: {class: 'highlight'}};
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

function isProduction() {
  return process.env.PRODUCTION === 'true'
}
