import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Laravel App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> places;

  @override
  void initState() {
    super.initState();
    places = apiService.getGeneralList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Places with Weather'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: places,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
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

  PlaceDetailsScreen({required this.geoapifyId});

  @override
  Widget build(BuildContext context) {
    final ApiService apiService = ApiService();
    late Future<Map<String, dynamic>> placeDetails =
        apiService.getSingleFullDetails(geoapifyId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Place Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: placeDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
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
