import dayjs from '@/utils/dayjs';

pageLoad('tests_momentjs', () => {
  const { MOMENT_DIFF } = window;

  $('.date').html(new Date());
  $('.dayjs').html(dayjs().format());
  $('.dayjs_diff').html(MOMENT_DIFF);
  $('.server_time').html(dayjs($(document.body).data('server-time')).format());

  const $div1 = $('.test1');
  $div1.html(dayjs($div1.data('datetime')).fromNow());

  const $div2 = $('.test2');
  $div2.html(dayjs($div2.data('datetime')).add(MOMENT_DIFF).fromNow());

  const $div3 = $('.test3');
  $div3.html(dayjs($div3.data('datetime')).subtract(MOMENT_DIFF).fromNow());

  const $div4 = $('.test4');
  $div4.html(dayjs($div4.data('datetime')).fromNow());

  const $div5 = $('.test5');
  $div5.html(dayjs($div5.data('datetime')).add(MOMENT_DIFF).fromNow());

  const $div6 = $('.test6');
  $div6.html(dayjs($div6.data('datetime')).subtract(MOMENT_DIFF).fromNow());
});
