function trackAddToCart_google(productCode, quantityAdded) {
  _gaq.push(['_trackEvent', 'Cart', 'AddToCart', productCode, quantityAdded]);

  var string = "addtocartapp";
    
  sendCommand(string, productCode, quantityAdded);
}

function sendCommand(a, b, c) {
    var url=a+":"+b+":"+c;
    document.location = url;  
}