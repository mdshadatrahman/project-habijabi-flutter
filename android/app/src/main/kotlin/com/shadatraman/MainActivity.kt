package com.shadatraman.project_habijabi_flutter

import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val channelName = "android.methodchannel.com"
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channel.setMethodCallHandler { call, result ->

            var args = call.arguments as Map<String, String>
            var message = args["message"]
           
        
            if(call.method == "showToast"){
                Toast.makeText(this, message, Toast.LENGTH_LONG).show()
            }

        }
    }
}
