package com.refermie.app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import com.google.android.gms.maps.MapsInitializer
import com.google.android.gms.maps.MapsInitializer.Renderer
import com.google.android.gms.maps.OnMapsSdkInitializedCallback

class MainActivity: FlutterFragmentActivity(), OnMapsSdkInitializedCallback {
    private val CHANNEL = "app.channel.shared.data"
    private var startString: String? = null
    private var linksReceiver: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Method channel setup for initial deep link
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getInitialLink") {
                if (startString != null) {
                    result.success(startString)
                } else {
                    result.success(null)
                }
            } else {
                result.notImplemented()
            }
        }

        // Event channel for incoming links when app is already running
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "$CHANNEL/link").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    linksReceiver = events
                }

                override fun onCancel(arguments: Any?) {
                    linksReceiver = null
                }
            }
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Initialize Google Maps
        MapsInitializer.initialize(applicationContext, Renderer.LATEST, this)
        // Handle initial deep link intent
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        val action = intent.action
        val data = intent.data

        if (Intent.ACTION_VIEW == action && data != null) {
            val link = data.toString()

            if (linksReceiver != null) {
                // If app is already running, send via event channel
                linksReceiver?.success(link)
            } else {
                // Store for initial method channel query
                startString = link
            }
        }
    }

    override fun onMapsSdkInitialized(renderer: MapsInitializer.Renderer) {
        when (renderer) {
            Renderer.LATEST -> {
                Log.d("NewRendererLog", "The latest version of the renderer is used.")
            }
            Renderer.LEGACY -> {
                Log.d("NewRendererLog", "The legacy version of the renderer is used.")
            }
        }
    }
}
