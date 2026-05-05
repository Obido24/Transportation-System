import 'dart:async';
import 'dart:html' as html;

const String _routesUpdatedKey = 'i_metro_routes_updated_at';

StreamSubscription<dynamic>? watchRouteUpdates(void Function() onUpdate) {
  return html.window.onStorage.listen((event) {
    if (event.key == _routesUpdatedKey) {
      onUpdate();
    }
  });
}

void signalRouteUpdates() {
  html.window.localStorage[_routesUpdatedKey] = DateTime.now().toIso8601String();
}
