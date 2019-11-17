import MobileDetect from 'mobile-detect';

export const mobileDetect = new MobileDetect(window.navigator.userAgent);

export const isTablet = () =>
  document.documentElement.clientWidth <= 1023 || (
    !!mobileDetect.tablet() && document.documentElement.clientWidth <= 1023
  );

export const isPhone = () =>
  document.documentElement.clientWidth <= 1023 || (
    !!mobileDetect.phone() && document.documentElement.clientWidth <= 480
  );

export const isMobile = () =>
  document.documentElement.clientWidth <= 1023 || (
    !!mobileDetect.mobile() && document.documentElement.clientWidth <= 1023
  );
