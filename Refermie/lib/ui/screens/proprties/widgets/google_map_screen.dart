import 'dart:async';

import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/foundation.dart' as f;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({
    required this.latitude,
    required this.longitude,
    required Completer<GoogleMapController> controller,
    super.key,
  }) : _controller = controller;
  final double latitude;
  final double longitude;

  final Completer<GoogleMapController> _controller;

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  bool isGoogleMapVisible = false;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500), () {
      isGoogleMapVisible = true;
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        isGoogleMapVisible = false;
        setState(() {});
        await Future<void>.delayed(const Duration(milliseconds: 500));
        Future.delayed(
          Duration.zero,
          () {
            Navigator.pop(context);
          },
        );
        return Future.value(false);
      },
      child: Builder(
        builder: (context) {
          if (!isGoogleMapVisible) {
            return Center(child: UiUtils.progress());
          }
          return GoogleMap(
            myLocationButtonEnabled: false,
            gestureRecognizers: const <f.Factory<OneSequenceGestureRecognizer>>{
              f.Factory<OneSequenceGestureRecognizer>(
                EagerGestureRecognizer.new,
              ),
            },
            markers: {
              Marker(
                markerId: const MarkerId('1'),
                position: LatLng(widget.latitude, widget.longitude),
              ),
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.latitude, widget.longitude),
              zoom: 14.4746,
            ),
            onMapCreated: (GoogleMapController controller) {
              if (!widget._controller.isCompleted) {
                widget._controller.complete(controller);
              }
            },
          );
        },
      ),
    );
  }
}
