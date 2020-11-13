import 'package:geolocator/geolocator.dart';
import 'package:krish_connect/data/fenceData.dart';
import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/database.dart';

class Geofencing {
  String getBlockLocation(Position currentPosition) {
    List<String> locationNames = fenceData.keys.toList();
    for (String locationName in locationNames) {
      if (_isInsidePolygon(
          currentPosition: currentPosition, polygon: fenceData[locationName])) {
        return locationName;
      }
    }
    return "Outside";
  }

  Future<void> updateLocationCallback() async {
    Position currentPosition = await Geolocator.getCurrentPosition();
    Geofencing fence = Geofencing();
    String location = fence.getBlockLocation(currentPosition);
    await Database().updateLocation(location);
  }

  bool _isInsidePolygon({Position currentPosition, List polygon}) {
    Position lastPoint = polygon[polygon.length - 1];
    bool isInside = false;
    double x = currentPosition.longitude;
    for (var point in polygon) {
      double x1 = lastPoint.longitude;
      double x2 = point.longitude;
      double dx = x2 - x1;

      if ((dx.abs()) > 180.0) {
        if (x > 0) {
          while (x1 < 0) x1 += 360;
          while (x2 < 0) x2 += 360;
        } else {
          while (x1 > 0) x1 -= 360;
          while (x2 > 0) x2 -= 360;
        }
        dx = x2 - x1;
      }

      if ((x1 <= x && x2 > x) || (x1 >= x && x2 < x)) {
        var grad = (point.latitude - lastPoint.latitude) / dx;
        var intersectAtLat = lastPoint.latitude + ((x - x1) * grad);

        if (intersectAtLat > currentPosition.latitude) isInside = !isInside;
      }
      lastPoint = point;
    }

    return isInside;
  }
}
