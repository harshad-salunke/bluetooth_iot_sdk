import 'package:nearby_connections/nearby_connections.dart';

checkBluetoothPermissions() async {
  if (await Nearby().checkBluetoothPermission()) {
    print('bluetooth permission is already given');
  } else {
    print('asking bluetooth permission');
    Nearby().askBluetoothPermission();
  }

  return Nearby().checkBluetoothPermission();
}
