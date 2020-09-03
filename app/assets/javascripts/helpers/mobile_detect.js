import IsMobileJS from 'ismobilejs';

export const mobileDetect = new IsMobileJS(window.navigator.userAgent);

export const isTablet = () =>
  document.documentElement.clientWidth < 1024 || (
    mobileDetect.tablet && document.documentElement.clientWidth <= 1023
  );

export const isPhone = () =>
  document.documentElement.clientWidth < 768 || (
    mobileDetect.phone && document.documentElement.clientWidth <= 480
  );

export const isMobile = () =>
  document.documentElement.clientWidth < 1024 || (
    mobileDetect.any && document.documentElement.clientWidth <= 1023
  );

// export const isWebkit = ('webkitURL' in window) ||
//   ('WebkitAppearance' in document.documentElement.style) ||
//   ('webkitRequestAnimationFrame' in window);
