import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  var channel = MethodChannel('android.methodchannel.com');

  void showToast() {
    channel.invokeMethod('showToast', {'message': 'This is a native toast'});
  }

  final batteryChannel = const MethodChannel('com.shadatrahman/battery');

  Future<void> getBatteryLevel() async {
    try {
      final args = <String, dynamic>{'name': 'Shadat'};
      final result = await batteryChannel.invokeMethod('getBatteryLevel', args);
      print(result);
    } on PlatformException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.error,
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            getBatteryLevel();
          },
          child: const Text('Click Me!'),
        ),
      ),
    );
  }
}
