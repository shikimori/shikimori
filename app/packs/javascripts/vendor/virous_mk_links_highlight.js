// https://greasyfork.org/ru/scripts/445617-shiki-links-comparator/code
// Возвращает массив ссылок из элемента .change
function getLinks(block) {
  let links = Array.from(block.getElementsByClassName('b-external_link'));

  return links.map(link => {
    let url = new URL(link.getElementsByTagName('a')[0].href);

    return {
      url: url.href,
      host: url.host,
      path: url.href.replace(url.origin, ''),
      kind: link.classList[1],
      node: link.getElementsByClassName('url')[0]
    };
  });
}

// Возвращает массив уникальных элементов beforeLinks, при сравнении с afterLinks
function getUniqueElements(beforeLinks, afterLinks) {
  return beforeLinks.filter(el1 => (
    !afterLinks.find(el2 => el1.url === el2.url && el1.kind === el2.kind)
  ));
}

// Возвращает похожую на link ссылку из array
function getSimilarLink(link, array) {
  return array.find(l => {
    // Если отличается только kind
    if (link.url === l.url) return true;

    // Если совпадает host или kind и при этом pathname одной ссылки содержит pathname другой
    // P.S. Сомнительное решение, возможно, стоит подумать над другим
    if (link.host === l.host || link.kind === l.kind) {
      if (link.path.includes(l.path)) return true;
      if (l.path.includes(link.path)) return true;
    }

    return false;
  });
}

// Возвращает массив beforeLinks со state, определённым как add, mod или del
function organizeLinks(beforeLinks, afterLinks, defaultState) {
  return beforeLinks.map(link => {
    if (link.url.includes('/NONE') ?? defaultState === 'ins') {
      link.state = 'del';
      return link;
    }

    let similarLink = getSimilarLink(link, afterLinks);
    link.state = similarLink ? 'mod' : defaultState;
    return link;
  });
}

function prepareLinks(changes_block) {
  let links_container = changes_block.getElementsByClassName('change');
  let beforeLinks = getLinks(links_container[0]);
  let afterLinks = getLinks(links_container[1]);

  let beforeLinksUniq = getUniqueElements(beforeLinks, afterLinks);
  let afterLinksUniq = getUniqueElements(afterLinks, beforeLinks);

  let beforeLinksPrepared = organizeLinks(beforeLinksUniq, afterLinksUniq, 'del');
  let afterLinksPrepared = organizeLinks(afterLinksUniq, beforeLinksUniq, 'ins');

  return beforeLinksPrepared.concat(afterLinksPrepared);
}

export default function(fieldChangesNode) {
  prepareLinks(fieldChangesNode).forEach(link => {
    link.node.classList.add(link.state);
  });
}
