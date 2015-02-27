  var container = document.querySelector('.cards');
  var containerWidth = container.offsetWidth;
  var msnry;
  imagesLoaded( container, function() {
    msnry = new Masonry( container, {
      // options
      columnWidth: containerWidth / 4,
      itemSelector: '.card'
    });
  });