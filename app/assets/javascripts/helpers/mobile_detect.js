import MobileDetect from 'mobile-detect';

export const mobileDetect = new MobileDetect(window.navigator.userAgent);

export const isTablet = () =>
  !!mobileDetect.tablet() || document.documentElement.clientWidth <= 1023;

export const isPhone = () =>
  !!mobileDetect.phone() || document.documentElement.clientWidth <= 480;

export const isMobile = () =>
  !!mobileDetect.mobile() || document.documentElement.clientWidth <= 1023;
