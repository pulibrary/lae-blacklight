// add columnWidth function to Masonry
Masonry.prototype._getMeasurement = function( measurement, size ) {
  var option = this.options[ measurement ];
  var elem;
  if ( !option ) {
    // default to 0
    this[ measurement ] = 0;
  } else if ( typeof option === 'function' ) {
    this[ measurement ] = option.call( this );
  } else {
    // use option as an element
    if ( typeof option === 'string' ) {
      elem = this.element.querySelector( option );
    } else if ( isElement( option ) ) {
      elem = option;
    }
    // use size of element, if element
    this[ measurement ] = elem ? getSize( elem )[ size ] : option;
  }
};

// match column to breakpoint name
var breakpoints = {
  default: 2,
  tablet: 3,
  widescreen: 4
};

$( function() {
  var $container = $('.cards');

  $container.imagesLoaded( function() {
    $container.masonry({
      itemSelector: '.card',
      columnWidth: function() {
        var breakpointName = getComputedStyle( document.body, ':after' ).content;
        var columns = breakpoints[ breakpointName ];
        return this.size.innerWidth / columns;
      }
    });
  });
  
});