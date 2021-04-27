import delay from 'delay';
import TinyUri from 'tiny-uri';

function setLink() {
  $('#link').val(
    document.location.href.replace(/\?.*/, '') +
      '?image_url=' + $('#image_url').val() +
      '&image_border=' + $('#image_border').val().replace('#', '@')
  );
}

pageLoad('.tests', () => {
  $('#image_url')
    .on('keypress', function(e) {
      if ((e.keyCode === 10) || (e.keyCode === 13)) {
        $(this).trigger('change');
      }
    })
    .on('blur change', function() {
      $('.b-achievement .c-image img').attr({ src: this.value });
      setLink();
    })
    .on('paste', async function() {
      await delay();
      $(this).trigger('change');
    })
    .trigger('change');

  $('#image_border')
    .on('keyup blur change', function() {
      $('.b-achievement .c-image .border').css({ borderColor: this.value });
      setLink();
    })
    .on('paste', async function() {
      await delay();
      $(this).trigger('change');
    })
    .trigger('change');
});

pageLoad('tests_reset_styles_cache', () => {
  $('.b-form').on('submit', ({ currentTarget }) => {
    currentTarget.action = new TinyUri(currentTarget.action)
      .query.set('url', $('input[name=url]', currentTarget).val())
      .toString();
  });
});
