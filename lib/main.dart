// TO DO:
//
// - If websocket disconnects, then reset main page:
//     setState() {
//       channel.close()
//       connectedBool = false
//     }
//
// - Add helpful text under scanner window depending on scan mode:
//     In barcode_scanner_window.dart:
//     If connecting mode:
//          "Start the Scanner Companion app on your PC,
//             then scan the QR code to connect."
//     If scanning mode:
//          "On your PC, select where you want scanned codes to be entered."

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'barcode_scanner_window.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode to PC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Barcode to PC'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebSocketChannel channel;
  bool connectedBool = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: !connectedBool
              ? // show connect button if not connected
              <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      _connectPC(context);
                    },
                    child: const Text('Connect to PC'),
                  ),
                ]
              : // show scan button if connected
              <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      _scanBarcode(context, channel);
                    },
                    child: const Text('New Barcode Scan'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        channel.sink.close();
                        connectedBool = false;
                      });
                    },
                    child: const Text('Disconnect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  Future<void> _connectPC(BuildContext context) async {
    // await ip address from scanner
    final ip = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerWithScanWindow(
          scanningMode: Mode.connecting,
        ),
      ),
    );

    if (ip == null || ip.substring(ip.length - 5) != ":8001") {
      return;
    }

    // connect the websocket channel to the IP address
    setState(() {
      channel = WebSocketChannel.connect(
        Uri.parse('ws://' + ip),
      );
      connectedBool = true;
    });
  }

  Future<void> _scanBarcode(
      BuildContext context, WebSocketChannel channel) async {
    // await barcode value from scanner
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerWithScanWindow(
            scanningMode: Mode.scanning, channelRef: channel),
      ),
    );
  }
}
