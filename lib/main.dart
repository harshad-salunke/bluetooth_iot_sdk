import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  TextEditingController blue_address = TextEditingController();
  TextEditingController data_address = TextEditingController();
  bool buttonPress=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Blue SDK'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: blue_address,

                    decoration: InputDecoration(
                      hintText: 'Enter Blue Address',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async{
                    buttonPress=true;
                    setState(() {
                    });
                    await blueSdk.triggerPipelineToConnect(blue_address.text.toString());
                    buttonPress=false;
                    setState(() {
                    });

                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          return blueSdk.isPaired ? Colors.green : Colors.white60; // Color when pressed based on isPaired
                        } else if (states.contains(MaterialState.disabled)) {
                          return blueSdk.isPaired ? Colors.green : Colors.white60; // Color when disabled based on isPaired
                        }
                        return blueSdk.isPaired ? Colors.green : Colors.white60; // Default color based on isPaired
                      },
                    ),
                  ),
                  child:
                  buttonPress?Container(
                    height: 20,
                      width: 20,
                      child: CircularProgressIndicator()):Text(blueSdk.isPaired?'Connected':'Connect'),
                ),           ],
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: data_address,
                    decoration: InputDecoration(
                      hintText: 'Enter data',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (blueSdk.isPaired) {
                      await blueSdk.sendDataOverSingleBluetooth(
                          data_address.text.toString());
                    }else{
                      Fluttertoast.showToast(
                        msg: 'You are not Connected!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
