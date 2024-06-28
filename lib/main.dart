import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'package:location/location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Laravel App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> places;

  Location location = Location();
  late LocationData _currentLocation;

  @override
  void initState() {
    super.initState();
    places = apiService.getGeneralList();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {

  _currentLocation = await location.getLocation();
  print("Current Location: ${_currentLocation.latitude}, ${_currentLocation.longitude}");

  try {
    await apiService.sendCurrentLocation(
      _currentLocation.latitude!,
      _currentLocation.longitude!,
    );
    print("Location is sent to backend successfully: ${_currentLocation.latitude}, ${_currentLocation.longitude}");
  } catch (e) {
    print("Failed to send location to backend: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Places with Weather'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: places,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final place = snapshot.data![index];
                return Card(
                  child: ListTile(
                    title: Text(place['name']),
                    subtitle: Text('${place['main']['temp']} °C'),
                    leading: Image.network(
                      'http://openweathermap.org/img/w/${place['weather'][0]['icon']}.png',
                      width: 50,
                      height: 50,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaceDetailsScreen(
                              geoapifyId: place['geoapifyId']),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
class PlaceDetailsScreen extends StatelessWidget {
  final String geoapifyId;

  const PlaceDetailsScreen({super.key, required this.geoapifyId});

  @override
  Widget build(BuildContext context) {
    final ApiService apiService = ApiService();
    late Future<Map<String, dynamic>> placeDetails =
        apiService.getSingleFullDetails(geoapifyId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: placeDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final place = snapshot.data!['current'];
            final forecast = snapshot.data!['forecast']['list'];

            return Column(
              children: [
                ListTile(
                  title: Text(place['name']),
                  subtitle: Text('${place['main']['temp']} °C'),
                  leading: Image.network(
                    'http://openweathermap.org/img/w/${place['weather'][0]['icon']}.png',
                    width: 50,
                    height: 50,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: forecast.length,
                    itemBuilder: (context, index) {
                      final item = forecast[index];
                      return ListTile(
                        title: Text('${item['main']['temp']} °C'),
                        subtitle: Text(item['dt_txt']),
                        leading: Image.network(
                          'http://openweathermap.org/img/w/${item['weather'][0]['icon']}.png',
                          width: 50,
                          height: 50,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}