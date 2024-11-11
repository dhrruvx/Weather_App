import 'dart:ui';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:weather/weather.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Good Morning!';
  } else if (hour < 17) {
    return 'Good Afternoon!';
  } else {
    return 'Good Evening!';
  }
}

String capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

String capitalizeEachWord(String s) {
  if (s.isEmpty) return s;
  return s
      .split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

class _HomeState extends State<Home> {
  late WeatherFactory wf;
  Weather? _weather;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    wf = WeatherFactory(
        '42ef84f5bed533e97aa9afe76888f1eb'); // Replace with your OpenWeatherMap API key
    _getLocationAndWeather();
  }

  Future<void> _getLocationAndWeather() async {
    Position position = await _determinePosition();
    Weather weather = await wf.currentWeatherByLocation(
        position.latitude, position.longitude);
    setState(() {
      _weather = weather;
      _loading = false;
    });
    print(position.latitude);
    print(position.longitude);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Weather",
          style: TextStyle(
            color: Colors.grey[100],
            fontWeight: FontWeight.bold,
            fontSize: 40,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Align(
              alignment: const AlignmentDirectional(3, -0.3),
              child: Container(
                height: 300,
                width: 300,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.deepPurple),
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(1, -0.5),
              child: Container(
                height: 300,
                width: 300,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.deepPurple),
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(0.3, -0.8),
              child: Container(
                height: 300,
                width: 300,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.amberAccent),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                decoration: const BoxDecoration(color: Colors.transparent),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Text(_getGreeting(),
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            letterSpacing: .5),
                      )),
                  const SizedBox(height: 16),
                  _loading
                      ? Center(
                          child: LoadingAnimationWidget.flickr(
                            leftDotColor: const Color.fromARGB(255, 71, 71, 71),
                            rightDotColor: const Color.fromARGB(255, 0, 0, 0),
                            size: 200,
                            //color: Colors.white,
                          ),
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 200),
                            child: Text(
                              _weather != null
                                  ? capitalizeEachWord(
                                      'Temperature: ${_weather!.temperature!.celsius!.toStringAsFixed(1)} °C\n'
                                      'Weather: ${_weather!.weatherDescription}')
                                  : 'Failed to get weather data',
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  letterSpacing: .5,
                                ),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//this code isnt returning the desired location details plases check
