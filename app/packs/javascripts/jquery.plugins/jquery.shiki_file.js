import delay from 'delay';
import { flash } from 'shiki-utils';

import csrf from '@/helpers/csrf';

const I18N_KEY = 'frontend.lib.jquery_shiki_file';

const defaults = {
  maxfiles: 150,
  progress: null,
  input: null
};

let globalDragLock = false;

$.fn.extend({
  shikiFile(opts) {
    return this.each(function () {
      const options = $.extend({}, defaults, opts);
      const $node = $(this);

      // плейсхолдер того места, куда будет класться файл
      let $dropArea = null;

      // прогресс-бар
      const $progressContainer = $(options.progress);
      const $progressBar = $progressContainer.children();

      const $input = $(options.input);
      // выбор файла в инпуте - триггер файлдропа
      $input.change(function () {
        if (this.files.length > 0) {
          $node.trigger('drop', [this.files]);
        }
      });

      const csrfTokens = csrf();
      $node.filedrop({
        url: $node.data('upload_url'),
        paramname: 'image',
        data: csrfTokens.post,
        headers: csrfTokens.headers,
        allowedfiletypes: [
          'image/jpg',
          'image/jpeg',
          'image/png'
        ],
        error(status, _file, _fileIndex, _status, errorText) {
          this.afterAll();

          switch (status) {
            case 'TooManyFiles':
              flash.error(I18n.t(`${I18N_KEY}.too_many_files`, { count: options.maxfiles }));
              break;

            case 'FileTooLarge':
              flash.error(I18n.t(`${I18N_KEY}.too_large_file`));
              break;

            case 'Unprocessable Entity':
              if (errorText) {
                flash.error(errorText);
              } else {
                flash.error(I18n.t(`${I18N_KEY}.please_try_again_later`));
              }
              break;

            case 'FileTypeNotAllowed':
              flash.error(I18n.t(`${I18N_KEY}.file_type_not_allowed`));
              break;

            // when 'BrowserNotSupported'
            default:
              flash.error(I18n.t(`${I18N_KEY}.browser_not_supported`));
          }

          globalDragLock = false;
        },

        maxfiles: options.maxfiles,
        maxfilesize: 4, // max file size in MBs
        queuefiles: 1,
        refresh: 50,

        beforeEach(file) {
          // $progressBar.width '0%'
          const filename = file.name;
          const filesize = Math.ceil(file.size / 10) / 100;
          return $progressBar.html(
            I18n.t(`${I18N_KEY}.loading_file`, {
              filename,
              filesize
            })
          );
        },

        drop() {
          if (globalDragLock) { return false; }

          globalDragLock = true;
          $node.trigger('upload:before');
          $(document.body).trigger('dragleave');

          $progressContainer.addClass('active');
          return true;
        },

        async afterAll() {
          $node.trigger('upload:after');
          globalDragLock = false;

          $progressContainer.removeClass('active');
          await delay(250);
          $progressBar.width('0%');
        },

        async docOver(_e) {
          if ($node.data('placeholder_displayed') || !$node.is(':visible')) {
            return;
          }

          $node.data({ placeholder_displayed: true });

          const height = $node.outerHeight();
          const width = $node.outerWidth();
          const text =
            globalDragLock ?
              I18n.t(`${I18N_KEY}.wait_till_loaded`) :
              I18n.t(`${I18N_KEY}.drop_pictures_here`);

          const cls = globalDragLock ? 'disallowed' : 'allowed';

          $dropArea = $(`<div data-text='${text}' class='shiki-file_uploader-drop_placeholder ${cls}' style='width:${width}px!important;height:${height}px;line-height:${Math.max(height, 75)}px;'></div>`)
            .css({ opacity: 0 })
            .on('drop', e => $node.trigger(e))
            .on('dragenter', function () { return $(this).addClass('hovered'); })
            .on('dragleave', function () { return $(this).removeClass('hovered'); })
            .insertBefore($node);

          await delay();
          $dropArea.css({ opacity: 0.75 });
        },

        docLeave(_e) {
          if (!$node.data('placeholder_displayed')) { return; }

          $dropArea = $node.parent()
            .find('.shiki-file_uploader-drop_placeholder')
            .css({ opacity: 0 });

          delay(350).then(() => $dropArea.remove());
          $node.data({ placeholder_displayed: false });
        },

        uploadStarted(i, _file, _len) {
          return $node.trigger('upload:started', i);
        },

        uploadFinished(i, file, response, _time) {
          if (Object.isString(response) || 'error' in response) {
            $node.trigger('upload:failed', [response, i]);
          } else {
            $node.trigger('upload:success', [response, i]);
          }
        },
          // $.hideCursorMessage()

        progressUpdated(i, file, progress) {
          if ((progress > 85) || (i > 0)) {
            $progressBar.width('100%');
          } else {
            $progressBar.width(progress + '%');
          }
        }
      });

      $node.pastableTextarea();
      $node.on('pasteImage', (e, data) => {
        const file = new File(
          [data.blob],
          `pasted_file.${data.blob.type.split('/')[1]}`, {
            type: data.blob.type,
            lastModified: Date.now()
          }
        );
        $node.trigger('drop', [[file]]);
      });
    });
  } });
