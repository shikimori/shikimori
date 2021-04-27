let resizeBinded = false;

function handleResize() {
  const $galleries = $('.align-posters');
  $galleries.find('.image-cutter').css('max-height', '');
  return $galleries.alignPosters();
}

$.fn.extend({
  // выравнивание анимешных и манговых постеров по высоте минимального элемента
  alignPosters() {
    return this.each(function() {
      const $root = $(this);

      if (!resizeBinded) {
        $(document).on('resize:debounced orientationchange', handleResize);
        resizeBinded = true;
      }

      const columns = $root.data('columns');

      // при разворачивании спойлеров выше, запускаем ресайз
      // хак для корректной работы галерей аниме внутри спойлеров
      if (!$root.data('spoiler_binded')) {
        $root
          .data({ spoiler_binded: true })
          .on('spoiler:opened', () => $root.alignPosters());
      }

      // разбиваем по группам
      return $root.children().toArray().inGroupsOf(columns).forEach(group => {
        const fixedGroup = group.compact();

        // определяем высоту самого низкого постера
        const minHeightNode = fixedGroup.min(node =>
          $(node).find('.image-cutter').outerHeight()
        );
        const minHeight = $(minHeightNode).find('.image-cutter').outerHeight();

        // и ставим её для всех постеров ряда
        if (minHeight > 0) {
          $(fixedGroup).find('.image-cutter').css('max-height', minHeight);
        }
      });
    });
  }
});
