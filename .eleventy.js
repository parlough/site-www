const yaml = require('js-yaml');
const markdownItDefinitionList = require('markdown-it-deflist');
const markdownItAnchor = require('markdown-it-anchor');
const markdownItContainer = require('markdown-it-container');
const markdownItTocDoneRight = require('markdown-it-toc-done-right');
const markdownItAttrs = require('markdown-it-attrs');
const path = require('path');
const eleventySass = require('eleventy-sass');

module.exports = function (eleventyConfig) {
  eleventyConfig.addDataExtension('yml,yaml', contents => yaml.load(contents));
  eleventyConfig.amendLibrary('md', mdLib => mdLib
      .use(markdownItDefinitionList)
      .use(markdownItAttrs, {
        leftDelimiter: '{:',
        rightDelimiter: '}',
        allowedAttributes: ['id', 'class', /^data-.*$/],
      })
      .use(markdownItAnchor, {
        level: 2,
        permalink: markdownItAnchor.permalink.ariaHidden({
          space: true,
          placement: 'after',
          symbol: '#',
          class: 'heading-link',
        }),
      })
      .use(markdownItTocDoneRight)
      .use(markdownItContainer, 'version-note', {
        render: function (tokens, idx) {
          if (tokens[idx].nesting === 1) {
            return '<aside class="alert alert-info" role="alert">' +
                '<i class="material-icons" aria-hidden="true">merge_type</i> <strong>Version note</strong>';
          } else {
            return '</aside>\n';
          }
        }
      })
  );

  eleventyConfig.setLiquidOptions({
    strictFilters: true,
    strictVariables: true,
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

  eleventyConfig.addFilter('array_to_sentence_string', function(list, joiner = 'and') {
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
  });


  eleventyConfig.addFilter('underscore_breaker', _underscoreBreaker);

  eleventyConfig.addPlugin(eleventySass, {
    sass: {
      style: 'compressed',
      sourceMap: false,
      quietDeps: true
    }
  });

  eleventyConfig.addPassthroughCopy('src/assets/dash');
  eleventyConfig.addPassthroughCopy('src/assets/js');
  eleventyConfig.addPassthroughCopy('src/assets/img',{ expand: true });
  eleventyConfig.addPassthroughCopy('src/assets/shared',{ expand: true });
  eleventyConfig.addPassthroughCopy('src/f');
  eleventyConfig.addPassthroughCopy('src/get-dart/archive/assets');

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
