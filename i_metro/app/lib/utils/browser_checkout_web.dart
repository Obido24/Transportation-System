import 'dart:html' as html;

bool openCheckoutInBrowser(String url) {
  html.window.open(url, '_blank');
  return true;
}
