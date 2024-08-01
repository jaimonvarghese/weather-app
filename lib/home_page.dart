import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'services/local_storage_service.dart';
import 'services/weather_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  String? _city;
  Map<String, dynamic>? _currentWeather;
  Map<String, dynamic>? _forecast;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCityAndWeather();
  }

  Future<void> _loadCityAndWeather() async {
    _city = await LocalStorageService.getCity();
    if (_city != null && _city!.isNotEmpty) {
      _fetchWeather(_city!);
    }
  }

  Future<void> _fetchWeather(String city) async {
    try {
      final currentWeather = await WeatherService.fetchCurrentWeather(city);
      final forecast = await WeatherService.fetchWeatherForecast(city);
      setState(() {
        _currentWeather = currentWeather;
        _forecast = forecast;
        _city = city;
        _errorMessage = null;
      });
      await LocalStorageService.saveCity(city);
      await LocalStorageService.saveWeatherData({
        'current': currentWeather,
        'forecast': forecast,
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'City not found. Please try again.';
      });
    }
  }

  Widget getWeatherIcon(String code) {
    switch (code) {
      case 'Thunderstorm':
        return Image.asset('assets/images/thunderstorm.png', width: 150);
      case 'Drizzle':
        return Image.asset('assets/images/drizzle.png', width: 150);
      case 'Rain':
        return Image.asset('assets/images/heavyrain.png', width: 150);
      case 'Snow':
        return Image.asset('assets/images/snow.png', width: 150);
      case 'Atmosphere':
        return Image.asset('assets/images/mist.png', width: 150);
      case 'Clear':
        return Image.asset('assets/images/clear.png', width: 150);
      case 'Clouds':
        return Image.asset('assets/images/heavycloud.png', width: 150);
      default:
        return Image.asset('assets/images/heavycloud.png', width: 150);
    }
  }

  Widget _buildWeatherInfo() {
    if (_currentWeather == null) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_currentWeather!['name']}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 50),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 200,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 133, 153, 187),
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(255, 133, 153, 187),
                offset: Offset(0, 25),
                blurRadius: 10,
                spreadRadius: -12,
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -40,
                left: 20,
                child: getWeatherIcon(_currentWeather!['weather'][0]['main']),
              ),
              Positioned(
                bottom: 30,
                left: 20,
                child: Text(
                  '${_currentWeather!['weather'][0]['main']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _currentWeather!['main']['temp'].round().toString(),
                        style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Text(
                      'o',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 50),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _forecast!['list'].length,
            itemBuilder: (BuildContext context, int index) {
              final item = _forecast!['list'][index];
              DateTime dateTime = DateTime.parse(item['dt_txt']);
              String formattedDate = DateFormat('EEEE,').format(dateTime);
              String formattedTime = DateFormat('jm').format(dateTime);

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                margin: const EdgeInsets.only(right: 20, bottom: 10, top: 10),
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 1),
                      blurRadius: 5,
                      color: Colors.black54.withOpacity(.2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 100,
                        child: getWeatherIcon(item['weather'][0]['main']),
                      ),
                    ),
                    Text(
                      "${item['main']['temp'].round()}°C",
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      item['weather'][0]['main'],
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    if (_errorMessage == null) return Container();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        _errorMessage!,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.red,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.all(20),
                    hintStyle: const TextStyle(
                      color: Color(0xff383838),
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          const BorderSide(color: Colors.white, width: 0.4),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.4),
                    ),
                    hintText: 'Enter city name',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        _fetchWeather(_controller.text.trim());
                      },
                    ),
                  ),
                ),
                _buildErrorMessage(),
                const SizedBox(height: 15,),
                _buildWeatherInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
