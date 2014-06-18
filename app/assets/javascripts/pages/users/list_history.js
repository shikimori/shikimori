// первый заголовок в подгруженном контенте не нужен, если такой уже есть на странице
$('.list_history .b-postloader').live('postloader:success', function(e, $data) {
  var $h2 = $data.filter('.subheadline:first');
  if ($('.list_history .subheadline').filter(function() { return this.innerHTML == $h2.text(); }).length > 0) {
    $h2.hide();
    $h2.next().css('margin-top', -25);
  }
});
