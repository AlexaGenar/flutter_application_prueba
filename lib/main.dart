import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Nombre de la caja (box) donde guardaremos el contador
const String COUNTER_BOX = 'counter_box';
const String COUNTER_KEY = 'counter_value';

void main() async {
  // Inicializar Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive y abrir el box
  await Hive.initFlutter();
  await Hive.openBox(COUNTER_BOX);
  
  // Leer el valor guardado
  final box = Hive.box(COUNTER_BOX);
  final savedCounter = box.get(COUNTER_KEY, defaultValue: 0);
  print('Valor inicial leído: $savedCounter'); // Debug
  
  runApp(MyApp(initialCounter: savedCounter));
}

class MyApp extends StatelessWidget {
  final int initialCounter;
  
  const MyApp({Key? key, required this.initialCounter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contador Examen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CounterPage(initialCounter: initialCounter),
    );
  }
}

class CounterPage extends StatefulWidget {
  final int initialCounter;
  
  const CounterPage({Key? key, required this.initialCounter}) : super(key: key);

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> with WidgetsBindingObserver {
  late int _counter;
  late Box _box;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _counter = widget.initialCounter;
    _initBox();
    
    // Registrar el observador para detectar cambios en el ciclo de vida
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    // Guardar el valor actual antes de destruir el widget
    _saveCounter(_counter);
    // Eliminar el observador
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  // Este método se llama cuando cambia el estado del ciclo de vida de la aplicación
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Guardar el estado cuando la aplicación pasa a segundo plano o se inactiva
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _saveCounter(_counter);
    }
  }
  
  Future<void> _initBox() async {
    _box = Hive.box(COUNTER_BOX);
    setState(() {
      _isLoading = false;
    });
  }
  
  void _saveCounter(int value) {
    _box.put(COUNTER_KEY, value);
    print('Valor guardado: $value'); // Debug
  }
  
  void _updateCounter(int value) {
    setState(() {
      _counter = value;
    });
    _saveCounter(_counter);
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contador'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Valor actual del contador:',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '$_counter',
              style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _updateCounter(_counter - 1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.all(15),
                  ),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _updateCounter(_counter + 1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.all(15),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}