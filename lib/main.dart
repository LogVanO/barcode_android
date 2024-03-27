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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebSocketChannel channel;
  bool connectedBool = false;

  // send a message over the websocket channel
  void _sendMessage(String message) {
    channel.sink.add(message);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
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
      ), // This trailing comma makes auto-formatting nicer for build methods.
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerWithScanWindow(
            scanningMode: Mode.scanning, channelRef: channel),
      ),
    );

    // send the message to PC
    _sendMessage(result);
  }
}
