import 'package:flutter/material.dart';
import 'package:milkmaster_bluetooth_sdk/services/blue_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    home: BlueSdk(),
  ));
}

class BlueSdk extends StatefulWidget {
  const BlueSdk({Key? key}) : super(key: key);

  @override
  State<BlueSdk> createState() => _BlueSdkState();
}

class _BlueSdkState extends State<BlueSdk> {
  BlueServices blueSdk = BlueServices();
  String address = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test SDK'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              //blue address mahit nasel  tar yane pop up madhe blue address  and nave bhetal
              blueSdk.triggerPipelinetoDiscover("testName");
              //
              // // address mahit asel tere direct address pass kr
              blueSdk.triggerPipelineToConnect("5C:17:CF:7F:EF:80");
            },
            child: const Text('Trigger Pipeline'),
          ),
        ],
      ),
    );
  }
}
