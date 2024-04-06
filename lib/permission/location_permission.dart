import 'package:nearby_connections/nearby_connections.dart';

Future<bool> checkLocationPermissions() async {
  if (await Nearby().checkLocationPermission()) {
    print('location permission is already given');
  } else {
    print('asking location permission');
    await Nearby().askLocationPermission();
  }
  return Nearby().checkLocationPermission();
}
