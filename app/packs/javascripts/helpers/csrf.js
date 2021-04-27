export default () => {
  const param = $('meta[name=csrf-param]').attr('content');
  const token = $('meta[name=csrf-token]').attr('content');
  const post = { [param]: token };

  const headers = { 'X-CSRF-Token': token };

  return {
    post,
    headers
  };
};
