import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para convertir JSON a Map
import 'package:dio/dio.dart'; // para solicitudes
import 'package:flutter/services.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Mi App",
      home: Home(),
    );
  }
}

class Home extends StatefulWidget{
 const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
  }

  class _HomeState extends State<Home> {
    List<dynamic> characters = []; // Para almacenar los personajes

    // Solicitud a la API de Rick and Morty
    Future<void> fetchCharacters() async {
      final dio = Dio();

      try {
        final response = await dio.get('https://rickandmortyapi.com/api/character');

        if (response.statusCode == 200) {
          setState(() {
            characters = response.data['results']; // Almacena los personajes
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Datos obtenidos exitosamente')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response.statusMessage}')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Home'),
        ),
        body: Column(
          children: [
            Center(
              child: ElevatedButton(
                onPressed: fetchCharacters, // Llama a la función para obtener personajes
                child: Text('Obtener personajes'),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  final character = characters[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CharacterDetail(character: character),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        leading: Image.network(character['image']),
                        title: Text(character['name']),
                        subtitle: Text(character['status']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: 0,
          onDestinationSelected: (int index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile()),
              );
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
            NavigationDestination(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      );
    }
  }

  class CharacterDetail extends StatelessWidget {
    final dynamic character;

    CharacterDetail({required this.character});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(character['name']),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(character['image']),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    character['name'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Text('Status: ${character['status']}'),
                Text('Species: ${character['species']}'),
                Text('Gender: ${character['gender']}'),
                Text('Origin: ${character['origin']['name']}'),
              ],
            ),
          ),
        ),
      );
    }
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _Settings();
}

class _Settings extends State<Settings> {
  final TextEditingController _controller = TextEditingController();
  Color _borderColor = Colors.grey;
  String _validationMessage = '';

  void _validateInput(String value) {
    setState(() {
      if (value.isEmpty) {
        _borderColor = Colors.grey;
        _validationMessage = '';
      } else if (double.tryParse(value) != null) {
        _borderColor = Colors.red;
        _validationMessage = 'Por favor, ingresa solo letras.';
      } else {
        _borderColor = Colors.green;
        _validationMessage = '';
      }
    });
  }

  void _validateInputSend() {
    setState(() {
      if (_controller.text.isEmpty) {
        _borderColor = Colors.red;
        _validationMessage = 'Campos vacíos, ingresa algún nombre.';
      } else {
        _validationMessage = '';
      }
    });
  }

  void _showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alerta'),
          content: Text('Que onda\n'),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search, color: const Color.fromARGB(255, 191, 185, 185)),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: const Color.fromARGB(255, 214, 210, 210)),
            onPressed: () {
              _showAlert(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: '¿Cómo te llamas?',
                  hintStyle: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  filled: true,
                  errorText: _validationMessage.isEmpty ? null : _validationMessage,
                ),
                onChanged: _validateInput,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 58, 106, 183)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                ),
                onPressed: () {
                  _validateInputSend();
                  if (_validationMessage.isEmpty) {
                    String name = _controller.text;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Color.fromARGB(255, 119, 193, 236),
                          content: Text(
                            '¡Hola, $name!',
                            style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cerrar', style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
                              onPressed: () {
                                Navigator.of(context).pop(); // Cierra el diálogo
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text(
                  'Saludar',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (int index) {
          if (index == 0) {
            Navigator.pop(context); // Regresa a la vista anterior
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Profile()),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class Profile extends StatelessWidget {

const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Image.asset(
                'assets/63227.png',
                fit: BoxFit.cover,
              ),
            ),
            Text("211218"),
            Text("Luis Adrián Pozo Gómez"),
            Text("Ingeniería en Software"),
            Text("Programación para Móviles 2"),
            Text("9B"),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.phone, color: Color.fromARGB(255, 15, 248, 7)),
                  iconSize: 30,
                  onPressed: () async {
                    final call = Uri.parse('tel:+529611586664');
                    if (await canLaunchUrl(call)) {
                      await launchUrl(call, mode: LaunchMode.externalApplication);
                    } else {
                      print('Could not launch $call');
                    }
                  },
                  tooltip: 'Llamar',
                  splashColor: Colors.blueAccent,
                ),
                IconButton(
                  icon: Icon(Icons.message, color: Color.fromARGB(255, 31, 99, 226)),
                  iconSize: 30,
                  onPressed: () async {
                    final sms = Uri.parse('sms:9613866687');
                    if (await canLaunchUrl(sms)) {
                      await launchUrl(sms);
                    } else {
                      print('Could not launch $sms');
                    }
                  },
                  tooltip: 'Mensaje',
                  splashColor: Colors.blueAccent,
                ),
                IconButton(
                  icon: Icon(Icons.web, color: const Color.fromARGB(255, 186, 35, 35)),
                  iconSize: 30,
                  onPressed: () async {
                    final web = Uri.parse('https://github.com/luisadrianPOZOGOMEZ/Flutter_Morty.git');
                    if (await canLaunchUrl(web)) {
                      await launchUrl(web, mode: LaunchMode.externalApplication);
                    } else {
                      print('Could not launch $web');
                    }
                  },
                  tooltip: 'Repositorio',
                  splashColor: Colors.blueAccent,
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (int index) {
          if (index == 0) {
            Navigator.pop(context); // Regresa a la vista anterior
          }else if(index == 1){
             Navigator.pop(context);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}