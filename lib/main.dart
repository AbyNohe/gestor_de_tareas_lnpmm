import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/date_symbols.dart';
import 'package:intl/intl.dart';
import 'models/task.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  
  // Inicializar la configuración de fecha en español
  await initializeDateFormatting('es_ES', null).then((_) {
    // Configurar el locale predeterminado
    Intl.defaultLocale = 'es_ES';
  });
  
  // Personalizar los símbolos de fecha para español
  var symbols = dateTimeSymbolMap();
  symbols['es_ES'] = DateSymbols(
    NAME: 'es_ES',
    ERAS: const ['a.C.', 'd.C.'],
    ERANAMES: const ['antes de Cristo', 'después de Cristo'],
    NARROWMONTHS: const ['E', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'],
    STANDALONENARROWMONTHS: const ['E', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'],
    MONTHS: const ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
    STANDALONEMONTHS: const ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
    SHORTMONTHS: const ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
    STANDALONESHORTMONTHS: const ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
    WEEKDAYS: const ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'],
    STANDALONEWEEKDAYS: const ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'],
    SHORTWEEKDAYS: const ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'],
    STANDALONESHORTWEEKDAYS: const ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'],
    NARROWWEEKDAYS: const ['D', 'L', 'M', 'M', 'J', 'V', 'S'],
    STANDALONENARROWWEEKDAYS: const ['D', 'L', 'M', 'M', 'J', 'V', 'S'],
    SHORTQUARTERS: const ['T1', 'T2', 'T3', 'T4'],
    QUARTERS: const ['1er trimestre', '2º trimestre', '3er trimestre', '4º trimestre'],
    AMPMS: const ['a. m.', 'p. m.'],
    DATEFORMATS: const ['EEEE, d \'de\' MMMM \'de\' y', 'd \'de\' MMMM \'de\' y', 'd MMM y', 'd/M/yy'],
    TIMEFORMATS: const ['H:mm:ss (zzzz)', 'H:mm:ss z', 'H:mm:ss', 'H:mm'],
    DATETIMEFORMATS: const ['{1}, {0}', '{1}, {0}', '{1}, {0}', '{1}, {0}'],
    FIRSTDAYOFWEEK: 0,
    WEEKENDRANGE: const [5, 6],
    FIRSTWEEKCUTOFFDAY: 3,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final Color turquesa = Color(0xFF5DC1B9);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider()..initHive(),
      child: MaterialApp(
        title: 'Gestor de Tareas',
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
        ],
        locale: const Locale('es', 'ES'),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                timePickerTheme: TimePickerThemeData(
                  hourMinuteColor: MaterialStateColor.resolveWith((states) =>
                    states.contains(MaterialState.selected)
                        ? turquesa
                        : Colors.grey[200]!),
                  dialHandColor: turquesa,
                ),
              ),
              child: child!,
            ),
          );
        },
        theme: ThemeData(
          useMaterial3: true,
          timePickerTheme: TimePickerThemeData(
            backgroundColor: Colors.white,
            dayPeriodBorderSide: const BorderSide(color: Colors.grey),
            dayPeriodColor: Colors.grey[200],
            dayPeriodTextColor: Colors.black,
            dayPeriodShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            hourMinuteColor: MaterialStateColor.resolveWith((states) =>
              states.contains(MaterialState.selected)
                  ? turquesa
                  : Colors.grey[200]!),
            dialHandColor: turquesa,
            dialBackgroundColor: Colors.grey[200],
            hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
              states.contains(MaterialState.selected)
                  ? Colors.white
                  : Colors.black),
          ),
          colorScheme: ColorScheme.light(
            primary: turquesa,
            secondary: turquesa.withOpacity(0.7),
            surface: Colors.white,
            onPrimary: Colors.white,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: turquesa,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: turquesa,
            foregroundColor: Colors.white,
          ),
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.selected)) {
                return turquesa;
              }
              return Colors.grey;
            }),
          ),
          scaffoldBackgroundColor: Colors.grey[50],
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    StatsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tareas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
