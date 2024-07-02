import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:third_party_map_integration_frontend/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
        automaticallyImplyLeading: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weather App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'OJT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: places,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.53,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final place = snapshot.data![index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceDetailsScreen(
                        geoapifyId: place['geoapifyId'],
                      ),
                    ),
                  );
                },
                child: _buildWeatherCard(place),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWeatherCard(Map<String, dynamic> place) {
    String imagePath = 'assets/images/default.jpg';

    String weatherDescription =
        place['weather'][0]['description'].toLowerCase();
    if (weatherDescription.contains('rain') ||
        weatherDescription.contains('shower')) {
      imagePath = 'assets/images/lightrain.jpg';
    }
    if (weatherDescription.contains('overcast')) {
      imagePath = 'assets/images/overcast.jpg';
    }
    if (weatherDescription.contains('scattered')) {
      imagePath = 'assets/images/scattered.webp';
    }
    if (weatherDescription.contains('broken')) {
      imagePath = 'assets/images/brokenclouds.jpg';
    }
    if (weatherDescription.contains('few')) {
      imagePath = 'assets/images/fewclouds.jpg';
    }
    if (weatherDescription.contains('clear')) {
      imagePath = 'assets/images/sunny.jpg';
    }
    if (weatherDescription.contains('snow')) {
      imagePath = 'assets/images/snow.jpg';
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10.0),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.2),
              BlendMode.darken,
            ),
          ),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _locationHeader(place),
            _temperatureInfo(place),
            _weatherDescription(place),
          ],
        ),
      ),
    );
  }

  Widget _locationHeader(Map<String, dynamic> place) {
    String weatherDescription = place['weather'][0]['description'];

    return Column(
      children: [
        Text(
          place['name'],
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          weatherDescription,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _temperatureInfo(Map<String, dynamic> place) {
    return Text(
      '${place['main']['temp']} °C',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _weatherDescription(Map<String, dynamic> place) {
    return Text(
      place['weather'][0]['description'],
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
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
        title: const Text(
          'Place Details',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: placeDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (snapshot.hasData) {
            final place = snapshot.data!['current'];
            final forecast = snapshot.data!['forecast']['list'];
            final DateTime now = DateTime.now();

            String backgroundImage = 'assets/images/default.jpg';

            String weatherDescription =
                place['weather'][0]['description'].toLowerCase();
            if (weatherDescription.contains('rain') ||
                weatherDescription.contains('shower')) {
              backgroundImage = 'assets/images/lightrain.jpg';
            }
            if (weatherDescription.contains('overcast')) {
              backgroundImage = 'assets/images/overcast.jpg';
            }
            if (weatherDescription.contains('scattered')) {
              backgroundImage = 'assets/images/scattered.webp';
            }
            if (weatherDescription.contains('broken')) {
              backgroundImage = 'assets/images/brokenclouds.jpg';
            }
            if (weatherDescription.contains('few')) {
              backgroundImage = 'assets/images/fewclouds.jpg';
            }
            if (weatherDescription.contains('clear')) {
              backgroundImage = 'assets/images/sunny.jpg';
            }
            if (weatherDescription.contains('snow')) {
              backgroundImage = 'assets/images/snow.jpg';
            }

            return Container(
              color: Colors.black,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(backgroundImage),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.3),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            place['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Image.network(
                            'http://openweathermap.org/img/w/${place['weather'][0]['icon']}.png',
                            width: 80,
                            height: 80,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            DateFormat('EEEE, MMM d, yyyy').format(now),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            DateFormat('h:mm a').format(now),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${place['main']['temp']} °C',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0.05),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.grey[800],
                      ),
                      padding: const EdgeInsets.all(0.05),
                      height: 120,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Container(
                              width: 100,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 0.05),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'NOW',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Image.network(
                                    'http://openweathermap.org/img/w/${place['weather'][0]['icon']}.png',
                                    width: 40,
                                    height: 40,
                                  ),
                                  Text(
                                    '${place['main']['temp']} °C',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            ...List.generate(4, (index) {
                              final forecastDateTime =
                                  now.add(Duration(hours: (index + 1) * 3));
                              final forecastItem = forecast.firstWhere(
                                  (item) =>
                                      DateTime.parse(item['dt_txt']).hour ==
                                      forecastDateTime.hour,
                                  orElse: () => forecast.first);
                              return Container(
                                width: 75,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 0.05),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('h a')
                                          .format(forecastDateTime),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(height: 5),
                                    Image.network(
                                      'http://openweathermap.org/img/w/${forecastItem['weather'][0]['icon']}.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                    Text(
                                      '${forecastItem['main']['temp']} °C',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const Divider(color: Colors.white),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: (forecast.length / 8).ceil(),
                      itemBuilder: (context, index) {
                        final startIndex = index * 8;
                        if (startIndex >= forecast.length) {
                          return const SizedBox.shrink();
                        }

                        final item = forecast[startIndex];
                        final dayLabel = index == 0
                            ? 'Today'
                            : DateFormat('EEEE')
                                .format(DateTime.parse(item['dt_txt']));

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey[800],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dayLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Image.network(
                                        'http://openweathermap.org/img/w/${item['weather'][0]['icon']}.png',
                                        width: 50,
                                        height: 50,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '${item['weather'][0]['description']}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                '${item['main']['temp_max']} °C - ${item['main']['temp_min']} °C',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(
            child: Text(
              'No data available',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
