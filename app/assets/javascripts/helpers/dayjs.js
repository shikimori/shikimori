import dayjs from 'dayjs';

import 'dayjs/locale/ru';

import localeData from 'dayjs/plugin/localeData';
import localizedFormat from 'dayjs/plugin/localizedFormat';
import relativeTime from 'dayjs/plugin/relativeTime';

dayjs.extend(localeData);
dayjs.extend(localizedFormat);
dayjs.extend(relativeTime);

export default dayjs;
