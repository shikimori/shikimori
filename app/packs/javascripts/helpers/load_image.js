/* eslint-disable no-param-reassign */
import imagePromise from 'image-promise';

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
