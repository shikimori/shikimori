/* eslint-disable no-param-reassign */
import imagePromise from 'image-promise';
import pDefer from 'p-defer';

export function loadImage(node, selector = 'img') {
  if (node.constructor === String) {
    node = document.querySelector(node);
  }

  return imagePromise(node.querySelector(selector));
}

export function loadImages(node, selector = 'img') {
  if (node.constructor === String) {
    node = document.querySelector(node);
  }

  return imagePromise(node.querySelectorAll(selector));
}

export function loadImageFinally(...args) {
  const deferred = pDefer();

  loadImage(...args)
    .catch(() => null) // don't need to know about these errors
    .finally(() => deferred.resolve());

  return deferred.promise;
}

export function loadImagesFinally(...args) {
  const deferred = pDefer();

  loadImages(...args)
    .catch(() => null) // don't need to know about these errors
    .finally(() => deferred.resolve());

  return deferred.promise;
}

export function imagePromiseFinally(...args) {
  const deferred = pDefer();

  imagePromise(...args)
    .catch(() => null) // don't need to know about these errors
    .finally(() => deferred.resolve());

  return deferred.promise;
}
