import delay from 'delay';

function setLink() {
  $('#link').val(
    document.location.href.replace(/\?.*/, '') +
      '?image_url=' + $('#image_url').val() +
      '&image_border=' + $('#image_border').val().replace('#', '@')
  );
}

pageLoad('.tests', () => {
  $('#image_url')
    .on('keypress', function (e) {
      if ((e.keyCode === 10) || (e.keyCode === 13)) {
        $(this).trigger('change');
      }
    })
    .on('blur change', function () {
      $('.b-achievement .c-image img').attr({ src: this.value });
      setLink();
    })
    .on('paste', async function () {
      await delay();
      $(this).trigger('change');
    })
    .trigger('change');

  $('#image_border')
    .on('keyup blur change', function () {
      $('.b-achievement .c-image .border').css({ borderColor: this.value });
      setLink();
    })
    .on('paste', async function () {
      await delay();
      $(this).trigger('change');
    })
    .trigger('change');
});
