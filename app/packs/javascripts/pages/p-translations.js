pageLoad('translations_show', async () => {
  const { default: Packery } = await import('packery');
  new Packery($('.translations')[0], { itemSelector: '.animes' });
});
