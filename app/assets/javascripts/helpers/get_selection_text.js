export default () => {
  let selectionTxt;

  if (window.getSelection) {
    selectionTxt = window.getSelection();
  } else if (document.getSelection) {
    selectionTxt = document.getSelection();
  } else if (document.selection) {
    selectionTxt = document.selection.createRange().text;
  }

  return (selectionTxt.toString() || '').trim();
};
