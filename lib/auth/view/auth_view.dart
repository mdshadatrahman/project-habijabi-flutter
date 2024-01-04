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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.error,
      body: Center(
        child: ElevatedButton(
          onPressed: showToast,
          child: const Text('Click Me!'),
        ),
      ),
    );
  }
}
