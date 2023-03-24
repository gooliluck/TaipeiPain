import 'package:flutter/material.dart';
import 'package:gl_taipeipain_flutter/model/RubbishTruck.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  late RubbishTrucksBloc rubbishTrucksBloc;

  Future<BitmapDescriptor> getTruckIcon() async {
    final ImageConfiguration config = ImageConfiguration(size: Size(48, 48));
    final BitmapDescriptor bitmap =
        await BitmapDescriptor.fromAssetImage(config, 'assets/truck_icon.png');
    return bitmap;
  }

// Usage in creating a Marker
  late BitmapDescriptor truckIcon;
  late Icon trashIcon;

  Future<void> initMarkerImages() async {
    // BitmapDescriptor truckBitmap = await BitmapDescriptor.fromAssetImage(
    //     const ImageConfiguration(size: Size(48, 48)),
    //     'assets/rubbish_truck.jpg'
    // );
    // truckIcon = const ImageIcon(
    //   AssetImage('images/rubbish_truck.jpg'),
    //   size: 24,
    // );
    BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(12, 12)),
      'assets/images/rubbish_truck.jpg',
    ).then((icon) {
      truckIcon = icon;
    });
    trashIcon = const Icon(Icons.delete);
  }

  Future<Position> getCurrentLocation() async {
    // Check for location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request location permission if not granted
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // If location permission is still not granted, display an error message.
        throw Exception('Location permission is denied.');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    print('JP Flutter :print initState');
    rubbishTrucksBloc = BlocProvider.of(context);
    rubbishTrucksBloc.add(FetchRubbishTrucks(10));
    initMarkerImages();
  }
  late List<RubbishTruck> trucks;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Position>(
          future: getCurrentLocation(),
          builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
            if (snapshot.hasData) {
              return BlocBuilder<RubbishTrucksBloc, RubbishTrucksState>(
                  builder: (context, state) {
                if (state is RubbishTrucksAreLoaded) {
                  trucks = state.rubbishTrucks;
                  // return initGoogleMap(121.32, 24.32);
                  return initGoogleMap(
                      snapshot.data!.latitude, snapshot.data!.longitude);
                } else {
                  return Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                        Text('Still loading....')
                      ],
                    ),
                  );
                }
              });
            } else if (snapshot.hasError) {
              // Handle any errors that occur.
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              // Show a loading indicator until the future completes.
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Widget initGoogleMap(double latitude, double longitude) {
    getMarkers( latitude,  longitude);
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 18,
      ),
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      markers: _markers,
    );
  }
  Set<Marker> _markers = {};

  void getMarkers(double latitude, double longitude) {
    _markers.clear();
    trucks.forEach((element) {
      _markers.add(
          createRubbishTruckMarker(element, latitude,  longitude)
      );
    });
  }
  Marker createRubbishTruckMarker(RubbishTruck truck,double latitude, double longitude){
    // var location = LatLng(truck.latitude??0, truck.longitude??0);
    var location = LatLng(latitude??0, longitude??0);
    return Marker(markerId: MarkerId(location.toString()),position: location,infoWindow: InfoWindow(
      title: truck.name??'',
      snippet: ''
    ),icon: truckIcon);
  }
}
