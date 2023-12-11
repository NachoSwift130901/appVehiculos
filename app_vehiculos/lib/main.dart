// ignore_for_file: library_private_types_in_public_api, must_be_immutable

import 'package:app_vehiculos/modelos/gastos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_async_autocomplete/flutter_async_autocomplete.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'blocs/bloc.dart';
import 'modelos/vehiculo.dart';
import 'modelos/categoria.dart';
import 'package:intl/intl.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AplicacionInyectada());
}


class AplicacionInyectada extends StatelessWidget {
  const AplicacionInyectada({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlotillaTaxis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: const Color.fromARGB(255, 57, 127, 136)),
      home: BlocProvider(
        create: (context) => AppBloc()..add(Inicializado()),
        child: const BottomNavigationBarExample(),
      ),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Lista de Categorias'),
        ),
        body: const Column(
          children: [
            PantallaCategorias(),
            AgregarCategoriaWidget(),
          ],
        ),
      ),
    );
  }
}

/* NAVIGATION BAR*/

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({Key? key}) : super(key: key);

  @override
  _BottomNavigationBarExampleState createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _currentIndex = 0;

  String obtenerTitulo() {
    switch (_currentIndex) {
      case 0:
        return 'Vehiculos';
      case 1:
        return 'Categorias';
      case 2:
        return 'Gastos';
      default:
        return 'Unknown';
    }
  }

  final List<Widget> _pages = [
    const PantallaVehiculos(),
    const PantallaCategorias(),
    const PantallaGastos(),
  ];

  @override
  Widget build(BuildContext context) {
    var estado = context.watch<AppBloc>().state;

    List<Categoria> categorias = [];
    List<Vehiculo> vehiculos = [];
    if (estado is Operacional) {
      categorias = (estado).listaCategorias;
      vehiculos = (estado).listaVehiculos;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 57, 127, 136),
        title: Text(obtenerTitulo()),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 57, 127, 136),
        selectedItemColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_canNavigate(index, categorias, vehiculos)) {
            setState(() {
              _currentIndex = index;
            });
          }
        else{
          mostrarAdvertencia('Debe haber al menos un vehículo y una categoría');
        }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.drive_eta_rounded),
            label: 'Carros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_rounded),
            label: 'Categorias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money_rounded),
            label: 'Gastos',
          ),
        ],
      ),
    );
  }

  bool _canNavigate(int index, List<Categoria> categorias, List<Vehiculo> vehiculos) {
    // Verifica las condiciones antes de permitir la navegación
    if (index == 2) {

      return categorias.isNotEmpty && vehiculos.isNotEmpty;
    }
    return true;
  }
  void mostrarAdvertencia(String mensaje) {
      final snackBar = SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
}

/* PANTALLA DE CATEGORIAS */

class PantallaCategorias extends StatelessWidget {
  const PantallaCategorias({super.key});
  

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    List<Categoria> categorias = [];
    List<String> cattegories = [];
    var estado = context.watch<AppBloc>().state;
    void editarCategoria(old, nueva) {
      context
          .read<AppBloc>()
          .add(ActualizarCategoria(oldCategoria: old, newCategoria: nueva));
    }
   void borrarCategoria(categoria){
      context.read<AppBloc>().add(EliminarCategoria(categoriaAEliminar: categoria));
   }
    // if(estado is Inicial) return const Text('Oh no');
    if (estado is Operacional) {
      categorias = (estado).listaCategorias;
      for (Categoria categoria in categorias) {
        cattegories.add(categoria.nombre);
      }
    }
    if (estado is Inicial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (categorias.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Aun no hay categorias'),
            AgregarCategoriaWidget(),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                final categoria = categorias[index];
                return ListTile(
                  title: Text(categoria.nombre),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                            onPressed: () {
                              final controlador =
                                  TextEditingController(text: categoria.nombre);

                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Editar Categoria'),
                                      content: SingleChildScrollView(
                                        child: Form(
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          key: formKey,
                                          child: Column(
                                            children: <Widget>[
                                              TextFormField(
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Por favor, ingresa la categoria';
                                                  }
                                                  if (cattegories.contains(value.toUpperCase()) && value != categoria.nombre) {
                                                    return 'Categoria ya existe';
                                                  }
                                                  RegExp lettersOnlyRegExp =
                                                      RegExp(r'[^a-zA-Z]');
                                                  if (lettersOnlyRegExp
                                                      .hasMatch(value)) {
                                                    return 'Solo letras';
                                                  }
                                      
                                                  return null;
                                                },
                                                controller: controlador,
                                                decoration: const InputDecoration(
                                                    labelText: 'Categoria',
                                                    icon:
                                                        Icon(Icons.category_outlined),
                                                    iconColor: Color.fromARGB(
                                                        255, 57, 127, 136),
                                                    labelStyle: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 57, 127, 136)),
                                                    enabledBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Color.fromARGB(
                                                                255, 57, 127, 136))),
                                                    focusedBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Color.fromARGB(
                                                                255, 57, 127, 136)))),
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(15)
                                      
                                                  
                                                ],
                                                
                                              ),
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(0, 24, 0, 13),
                                                  child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 57, 127, 136)),
                                                  onPressed: () {
                                                    if (formKey.currentState!.validate()) {
                                                    final nuevaCategoria = controlador.text.trim();
                                                    
                                                      editarCategoria(categoria.nombre,nuevaCategoria.toUpperCase());
                                                      Navigator.of(context).pop();
                                                    }
                                                  },
                                                  child: const Text('Guardar'),
                                                  ),
                                                ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Cancelar', style: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),),
                                              )
                                            ],
                                          ),
                                          
                                          
                                        ),
                                      ),
                                    );
                                  });
                            },
                            icon: const Icon(Icons.edit)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                            onPressed: () {
                              showDialog(
                                context: context, 
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: const Text('Estás seguro de que quieres eliminar esta categoría? (Esto tambien eliminara los gastos)'),
                                    actions: [
                                      TextButton(onPressed: () {
                                        Navigator.pop(context);
                                      }, child: const Text('Cancelar', style: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),)),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 57, 127, 136)),
                                        onPressed: () {
                                        borrarCategoria(categoria);
                                        Navigator.pop(context);
                                      }, 
                                      child: const Text('Eliminar'))
                                    ],
                                  );
                                }
                                );
                              
                            },
                            icon: const Icon(Icons.delete)),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          const AgregarCategoriaWidget(),
        ],
      ),
    );
  }
}

class AgregarCategoriaWidget extends StatefulWidget {
  const AgregarCategoriaWidget({super.key});

  @override
  State<AgregarCategoriaWidget> createState() => _AgregarCategoriaWidgetState();
}

class _AgregarCategoriaWidgetState extends State<AgregarCategoriaWidget> {
  final TextEditingController controlador = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {

    var estado = context.watch<AppBloc>().state;
    List<String> categorias = [];
    List<Categoria> cattegories = [];

    if(estado is Operacional){
      cattegories = (estado).listaCategorias;

      for(Categoria categoria in cattegories){
        categorias.add(categoria.nombre);
      }
    }

    void agregarCategoria(nuevaCategoria) {
        context.read<AppBloc>().add(AgregarCategoria(categoriaAAgregar: nuevaCategoria));
        controlador.clear();
        Navigator.pop(context);
      
    }

    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      title: const Text('Agregar Categoria'),
                      content: SingleChildScrollView(
                        child: Form(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, ingresa la categoria';
                                  }
                                  if(categorias.contains(value.toUpperCase())){
                                    return 'Categoria ya existe';
                                  }
                                  RegExp lettersOnlyRegExp = RegExp(r'[^a-zA-Z]');
                                  if (lettersOnlyRegExp.hasMatch(value)) {
                                    return 'Solo letras';
                                  }

                                  return null;
                                },
                                controller: controlador,
                                decoration: const InputDecoration(
                                    labelText: 'Categoria',
                                    icon: Icon(Icons.category_outlined),
                                    iconColor: Color.fromARGB(255, 57, 127, 136),
                                    labelStyle: TextStyle(
                                        color: Color.fromARGB(255, 57, 127, 136)),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Color.fromARGB(255, 57, 127, 136))),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Color.fromARGB(255, 57, 127, 136)))),
                                inputFormatters: [LengthLimitingTextInputFormatter(15)],
                              ),
                      
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                                child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 57, 127, 136)),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                              
                                    String nuevaCategoria = controlador.text.trim().toUpperCase();
                                    
                                    agregarCategoria(nuevaCategoria);
                                  }
                                },
                                child: const Text('Agregar')
                                ),
                              ),

                              TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancelar', style: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),)),
                              
                            
                            
                            ],
                          ),
                          
                          
                        ),
                      ),
                      
                      
                    ));
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 57, 127, 136)),
          label: const Text('Agregar Categoria'),
          icon: const Icon(Icons.add),
        ));
  }
}

/* PANTALLA DE VEHICULOS */

class PantallaVehiculos extends StatefulWidget {
  const PantallaVehiculos({super.key});

  @override
  State<PantallaVehiculos> createState() => _PantallaVehiculosState();
}

class _PantallaVehiculosState extends State<PantallaVehiculos> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController filtroCarros = TextEditingController();

  List<Vehiculo>? vehiculosFiltrados;

  @override
  Widget build(BuildContext context) {
    void eliminarVehiculo(Vehiculo vehiculo) {
      context.read<AppBloc>().add(EliminarVehiculo(vehiculo: vehiculo));
      
      
    }

    void actualizarVehiculo(matricula, marca, modelo, color, matriculaId) {
      context.read<AppBloc>().add(
          ActualizarVehiculo(matricula, marca, modelo, color, matriculaId));
    }

    void mostrarAdvertencia(String mensaje) {
      final snackBar = SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    List<String> matriculas = [];
    List<Vehiculo> vehiculos = [];
    var estado = context.watch<AppBloc>().state;
    if (estado is Operacional) {
      vehiculos = (estado).listaVehiculos;
      for (Vehiculo vehiculo in vehiculos) {
        matriculas.add(vehiculo.matricula);
        
      }
    }
    
    
    String search = '';
    
    if (estado is Inicial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vehiculos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Aún no hay vehículos...'),
            const SizedBox(height: 16.0),
            BotonAgregarVehiculo()
          ],
        ),
      );
    }
    
    vehiculosFiltrados ??= vehiculos;

    

    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              
              controller: filtroCarros,
              decoration: const InputDecoration(hintText: 'Buscar por vehículo...',
              enabledBorder: 
              UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
              focusedBorder: 
              UnderlineInputBorder(borderSide: BorderSide( color: Color.fromARGB(255, 57, 127, 136))),),
              onChanged: (value) {
                setState(() {
                  search = value;
                  vehiculosFiltrados = vehiculos.where((vehiculo) {
                    return vehiculo.toString().toUpperCase().contains(search.toUpperCase());
                  }).toList();
                  
                });
              },
            ),
          ),
          BlocBuilder<AppBloc, AppEstado>(
            builder: (context, state) {
              if (state is Operacional) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: vehiculosFiltrados!.length,
                    itemBuilder: (context, index) {
                      final vehiculo = vehiculosFiltrados![index];

                      return ListTile(
                        leading: const Icon(Icons.drive_eta_rounded),
                        trailing: const Icon(Icons.drag_handle_rounded),
                        title: Text(vehiculo.marca),
                        subtitle: Text(vehiculo.matricula),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('Vehiculo: ${vehiculo.matricula}'),
                                      ],
                                    ),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons
                                                        .branding_watermark_outlined,
                                                    color: Color.fromARGB(
                                                        255, 57, 127, 136),
                                                  ),
                                                ),
                                                Text('Marca',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Color.fromARGB(
                                                            255,
                                                            57,
                                                            127,
                                                            136))),
                                              ],
                                            ),
                                          ),
                                          Text(vehiculo.marca,
                                              style: const TextStyle(
                                                  fontSize: 20)),
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.numbers_outlined,
                                                    color: Color.fromARGB(
                                                        255, 57, 127, 136),
                                                  ),
                                                ),
                                                Text('Modelo',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      color: Color.fromARGB(
                                                          255, 57, 127, 136),
                                                    )),
                                              ],
                                            ),
                                          ),
                                          Text(vehiculo.modelo.toString(),
                                              style: const TextStyle(
                                                  fontSize: 20)),
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.palette,
                                                    color: Color.fromARGB(
                                                        255, 57, 127, 136),
                                                  ),
                                                ),
                                                Text('Color',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      color: Color.fromARGB(
                                                          255, 57, 127, 136),
                                                    )),
                                              ],
                                            ),
                                          ),
                                          Text(vehiculo.color,
                                              style: const TextStyle(
                                                  fontSize: 20)),
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.drive_eta,
                                                    color: Color.fromARGB(
                                                        255, 57, 127, 136),
                                                  ),
                                                ),
                                                Text('Matricula',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Color.fromARGB(
                                                            255,
                                                            57,
                                                            127,
                                                            136))),
                                              ],
                                            ),
                                          ),
                                          Text(vehiculo.matricula,
                                              style: const TextStyle(
                                                  fontSize: 20)),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 16, 0, 0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      final controladorMarca =
                                                          TextEditingController(
                                                              text: vehiculo
                                                                  .marca);
                                                      final controladorModelo =
                                                          TextEditingController(
                                                              text: vehiculo
                                                                  .modelo
                                                                  .toString());
                                                      final controladorColor =
                                                          TextEditingController(
                                                              text: vehiculo
                                                                  .color);
                                                      final controladorMatricula =
                                                          TextEditingController(
                                                              text: vehiculo
                                                                  .matricula);

                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (BuildContext
                                                              context) {
                                                            return Scaffold(
                                                              appBar: AppBar(
                                                                backgroundColor:
                                                                    const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        57,
                                                                        127,
                                                                        136),
                                                                title: const Text(
                                                                    'Editar vehiculo'),
                                                              ),
                                                              body: Form(
                                                                autovalidateMode:
                                                                    AutovalidateMode
                                                                        .onUserInteraction,
                                                                key: _formKey,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          16.0),
                                                                  child: Column(
                                                                    children: [
                                                                      TextFormField(
                                                                        validator:
                                                                            (value) {
                                                                          if (value == null ||
                                                                              value.isEmpty) {
                                                                            return 'Por favor, ingresa la marca';
                                                                          }
                                                                          RegExp
                                                                              lettersOnlyRegExp =
                                                                              RegExp(r'[^a-zA-Z]');
                                                                          if (lettersOnlyRegExp
                                                                              .hasMatch(value)) {
                                                                            return 'Solo letras';
                                                                          }
                                                                          return null;
                                                                        },
                                                                        controller:
                                                                            controladorMarca,
                                                                        decoration: const InputDecoration(
                                                                            labelText:
                                                                                'Marca',
                                                                            icon: Icon(Icons
                                                                                .branding_watermark_outlined),
                                                                            iconColor: Color.fromARGB(
                                                                                255,
                                                                                57,
                                                                                127,
                                                                                136),
                                                                            labelStyle:
                                                                                TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                                                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
                                                                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136)))),
                                                                      ),
                                                                      TextFormField(
                                                                        validator:
                                                                            (value) {
                                                                          if (value == null ||
                                                                              value.isEmpty) {
                                                                            return 'Por favor, ingresa el modelo';
                                                                          }
                                                                          RegExp
                                                                              numbersOnlyRegExp =
                                                                              RegExp(r'[^0-9]');
                                                                          if (numbersOnlyRegExp
                                                                              .hasMatch(value)) {
                                                                            return 'Solo se permiten números del 0 al 9.';
                                                                          }
                                                                          if (int.parse(value) < 1950 ||
                                                                              int.parse(value) > 2025) {
                                                                            return 'Introduce un modelo valido';
                                                                          }

                                                                          return null;
                                                                        },
                                                                        controller:
                                                                            controladorModelo,
                                                                        decoration: const InputDecoration(
                                                                            labelText:
                                                                                'Modelo',
                                                                            icon: Icon(Icons
                                                                                .numbers_outlined),
                                                                            iconColor: Color.fromARGB(
                                                                                255,
                                                                                57,
                                                                                127,
                                                                                136),
                                                                            labelStyle:
                                                                                TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                                                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
                                                                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136)))),
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        inputFormatters: <TextInputFormatter>[
                                                                          FilteringTextInputFormatter
                                                                              .digitsOnly,
                                                                          LengthLimitingTextInputFormatter(
                                                                              4),
                                                                        ],
                                                                      ),
                                                                      TextFormField(
                                                                        validator:
                                                                            (value) {
                                                                          if (value == null ||
                                                                              value.isEmpty) {
                                                                            return 'Por favor, ingresa el color';
                                                                          }
                                                                          RegExp
                                                                              lettersOnlyRegExp =
                                                                              RegExp(r'[^a-zA-Z]');
                                                                          if (lettersOnlyRegExp
                                                                              .hasMatch(value)) {
                                                                            return 'Introduce un color valido';
                                                                          }

                                                                          return null;
                                                                        },
                                                                        controller:
                                                                            controladorColor,
                                                                        decoration: const InputDecoration(
                                                                            labelText:
                                                                                'Color',
                                                                            icon: Icon(Icons
                                                                                .palette),
                                                                            iconColor: Color.fromARGB(
                                                                                255,
                                                                                57,
                                                                                127,
                                                                                136),
                                                                            labelStyle:
                                                                                TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                                                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
                                                                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136)))),
                                                                        inputFormatters: [
                                                                          LengthLimitingTextInputFormatter(
                                                                              15)
                                                                        ],
                                                                      ),
                                                                      TextFormField(
                                                                        validator:
                                                                            (value) {
                                                                          if (value == null ||
                                                                              value.isEmpty) {
                                                                            return 'Por favor, ingresa la matricula';
                                                                          }

                                                                          RegExp
                                                                              alphanumericRegExp =
                                                                              RegExp(r'^[a-zA-Z0-9]+$');
                                                                          if (!alphanumericRegExp
                                                                              .hasMatch(value)) {
                                                                            return 'Solo letras y números!';
                                                                          }
                                                                          // Verifica que haya al menos una letra y al menos un número
                                                                          RegExp
                                                                              letterAndNumberRegExp =
                                                                              RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]+$');
                                                                          if (!letterAndNumberRegExp
                                                                              .hasMatch(value)) {
                                                                            return 'Al menos una letra/numero';
                                                                          }
                                                                          if (matriculas.contains(value.toUpperCase()) &&
                                                                              value.toUpperCase() != vehiculo.matricula) {
                                                                            return 'Matricula existente';
                                                                          }

                                                                          return null;
                                                                        },
                                                                        controller:
                                                                            controladorMatricula,
                                                                        decoration: const InputDecoration(
                                                                            labelText:
                                                                                'Matrícula',
                                                                            icon: Icon(Icons
                                                                                .drive_eta),
                                                                            iconColor: Color.fromARGB(
                                                                                255,
                                                                                57,
                                                                                127,
                                                                                136),
                                                                            labelStyle:
                                                                                TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                                                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
                                                                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136)))),
                                                                        inputFormatters: [
                                                                          LengthLimitingTextInputFormatter(
                                                                              8)
                                                                        ],
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .fromLTRB(
                                                                            0,
                                                                            32,
                                                                            0,
                                                                            8),
                                                                        child:
                                                                            ElevatedButton(
                                                                          onPressed:
                                                                              () {
                                                                            if (_formKey.currentState!.validate()) {
                                                                              final nuevaMatricula = controladorMatricula.text.trim();
                                                                              final nuevaMarca = controladorMarca.text.trim();
                                                                              final nuevoModelo = controladorModelo.text.trim();
                                                                              final nuevoColor = controladorColor.text.trim();

                                                                              final matriculaVieja = vehiculo.matricula;

                                                                              actualizarVehiculo(nuevaMatricula, nuevaMarca, nuevoModelo, nuevoColor, matriculaVieja);
                                                                              setState(() {
                                                                                Navigator.of(context).pop();
                                                                              });

                                                                              mostrarAdvertencia("Vehiculo actualizado correctamente");
                                                                              Navigator.pop(context);
                                                                            }
                                                                          },
                                                                          style:
                                                                              ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 57, 127, 136)),
                                                                          child:
                                                                              const Text('Guardar'),
                                                                        ),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          'Cancelar',
                                                                          style:
                                                                              TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: const Color
                                                          .fromARGB(
                                                          255,
                                                          57,
                                                          127,
                                                          136), // Puedes cambiar el color según tus preferencias
                                                    ),
                                                    child: const Row(
                                                      children: [
                                                        Icon(Icons.edit),
                                                        Text('Editar')
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              content: const Text(
                                                                  '¿Estás seguro de que quieres eliminar este vehículo? (Esto tambien eliminará los gastos)'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context); // Cerrar el diálogo de confirmación
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Cancelar',
                                                                    style: TextStyle(
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            57,
                                                                            127,
                                                                            136)),
                                                                  ),
                                                                ),
                                                                ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    eliminarVehiculo(
                                                                        vehiculo);
                                                                    Navigator.pop(
                                                                        context); // Cerrar el diálogo de confirmación
                                                                    Navigator.pop(
                                                                        context); // Cerrar la pantalla actual
                                                                    mostrarAdvertencia(
                                                                        "Vehiculo eliminado correctamente");
                                                                  },
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        const Color
                                                                            .fromARGB(
                                                                            255,
                                                                            57,
                                                                            127,
                                                                            136), // Puedes cambiar el color según tus preferencias
                                                                  ),
                                                                  child: const Text(
                                                                      'Eliminar'),
                                                                ),
                                                              ],
                                                            );
                                                          });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: const Color
                                                          .fromARGB(
                                                          255,
                                                          57,
                                                          127,
                                                          136), // Puedes cambiar el color según tus preferencias
                                                    ),
                                                    child: const Row(
                                                      children: [
                                                        Icon(Icons.delete),
                                                        Text('Eliminar'),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ));
                        },
                      );
                    },
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          const SizedBox(height: 20),
          BotonAgregarVehiculo()
        ],
      ),
    );
  }
}

class BotonAgregarVehiculo extends StatelessWidget {
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  BotonAgregarVehiculo({super.key});

  @override
  Widget build(BuildContext context) {
    var estado = context.watch<AppBloc>().state;

    List<Vehiculo> vehiculos = [];
    List<String> matriculas = [];

    if (estado is Operacional) {
      vehiculos = (estado).listaVehiculos;

      for (Vehiculo vehiculo in vehiculos) {
        matriculas.add(vehiculo.matricula);
      }
    }

    void mostrarAdvertencia(String mensaje) {
      final snackBar = SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    void agregarVehiculo(
        String marca, int modelo, String color, String matricula) {
      context.read<AppBloc>().add(AgregarVehiculo(
            marca: marca,
            modelo: modelo,
            color: color,
            matricula: matricula,
          ));
          
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton.icon(
        onPressed: () {
          // Mostrar el formulario como un modal
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text(
                'Agregar Vehículo',
                style: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
              ),
              content: SingleChildScrollView(
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa la marca';
                          }
                          RegExp lettersOnlyRegExp = RegExp(r'[^a-zA-Z]');
                          if (lettersOnlyRegExp.hasMatch(value)) {
                            return 'Solo letras';
                          }

                          return null;
                        },
                        controller: _marcaController,
                        decoration: const InputDecoration(
                            labelText: 'Marca',
                            icon: Icon(Icons.branding_watermark_outlined),
                            iconColor: Color.fromARGB(255, 57, 127, 136),
                            labelStyle: TextStyle(
                                color: Color.fromARGB(255, 57, 127, 136)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 57, 127, 136))),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 57, 127, 136)))),
                        inputFormatters: [LengthLimitingTextInputFormatter(15)],
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa el modelo';
                          }
                          RegExp numbersOnlyRegExp = RegExp(r'[^0-9]');
                          if (numbersOnlyRegExp.hasMatch(value)) {
                            return 'Solo se permiten números del 0 al 9.';
                          }
                          if (int.parse(value) < 1950 ||
                              int.parse(value) > 2025) {
                            return 'Introduce un modelo valido';
                          }

                          return null;
                        },
                        controller: _modeloController,
                        decoration: const InputDecoration(
                            labelText: 'Modelo',
                            icon: Icon(Icons.numbers_outlined),
                            iconColor: Color.fromARGB(255, 57, 127, 136),
                            labelStyle: TextStyle(
                                color: Color.fromARGB(255, 57, 127, 136)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 57, 127, 136))),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 57, 127, 136)))),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa el color';
                          }
                          RegExp lettersOnlyRegExp = RegExp(r'[^a-zA-Z]');
                          if (lettersOnlyRegExp.hasMatch(value)) {
                            return 'Introduce un color valido';
                          }

                          return null;
                        },
                        controller: _colorController,
                        decoration: const InputDecoration(
                            labelText: 'Color',
                            icon: Icon(Icons.palette),
                            iconColor: Color.fromARGB(255, 57, 127, 136),
                            labelStyle: TextStyle(
                                color: Color.fromARGB(255, 57, 127, 136)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 57, 127, 136))),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 57, 127, 136)))),
                        inputFormatters: [LengthLimitingTextInputFormatter(15)],
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa la matricula';
                          }

                          RegExp alphanumericRegExp = RegExp(r'^[a-zA-Z0-9]+$');
                          if (!alphanumericRegExp.hasMatch(value)) {
                            return 'Solo letras y números!';
                          }
                          // Verifica que haya al menos una letra y al menos un número
                          RegExp letterAndNumberRegExp =
                              RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]+$');
                          if (!letterAndNumberRegExp.hasMatch(value)) {
                            return 'Al menos una letra/numero';
                          }
                          if (matriculas.contains(value.toUpperCase())) {
                            return 'Matricula existente';
                          }

                          return null;
                        },
                        controller: _matriculaController,
                        decoration: const InputDecoration(
                            labelText: 'Matrícula',
                            icon: Icon(Icons.drive_eta),
                            iconColor: Color.fromARGB(255, 57, 127, 136),
                            labelStyle: TextStyle(
                                color: Color.fromARGB(255, 57, 127, 136)),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide( color: Color.fromARGB(255, 57, 127, 136))),
                            focusedBorder: UnderlineInputBorder(  borderSide: BorderSide( color: Color.fromARGB(255, 57, 127, 136)))),
                        inputFormatters: [LengthLimitingTextInputFormatter(8)],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 57, 127, 136)),
                          onPressed: () {
                            // Validate returns true if the form is valid, or false otherwise.
                            if (_formKey.currentState!.validate()) {
                              String marca = _marcaController.text;
                              int modelo =
                                  int.tryParse(_modeloController.text) ?? 0;
                              String color = _colorController.text;
                              String matricula = _matriculaController.text;

                              agregarVehiculo(marca.toUpperCase(), modelo,
                                  color.toUpperCase(), matricula.toUpperCase());

                              _marcaController.clear();
                              _colorController.clear();
                              _matriculaController.clear();
                              _modeloController.clear();

                              // Cierra el AlertDialog
                              Navigator.pop(context);
                              mostrarAdvertencia("Vehiculo agregado correctamente");

                              
                            }
                          },
                          child: const Text('Agregar'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor:
                                    const Color.fromARGB(255, 57, 127, 136)),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancelar')),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 57, 127, 136)),
        label: const Text('Agregar Vehículo'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class FormularioVehiculo extends StatefulWidget {
  final TextEditingController marcaController;
  final TextEditingController modeloController;
  final TextEditingController colorController;
  final TextEditingController matriculaController;

  const FormularioVehiculo(
      {super.key,
      required this.marcaController,
      required this.modeloController,
      required this.colorController,
      required this.matriculaController});

  @override
  State<FormularioVehiculo> createState() => _FormularioVehiculoState();
}

class _FormularioVehiculoState extends State<FormularioVehiculo> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    void agregarVehiculo(
        String marca, int modelo, String color, String matricula) {
      context.read<AppBloc>().add(AgregarVehiculo(
            marca: marca,
            modelo: modelo,
            color: color,
            matricula: matricula,
          ));
    }

    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingresa texto.';
              }

              return null;
            },
            controller: widget.marcaController,
            decoration: const InputDecoration(
                labelText: 'Marca',
                icon: Icon(Icons.branding_watermark_outlined),
                iconColor: Color.fromARGB(255, 57, 127, 136),
                labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 57, 127, 136)))),
            inputFormatters: [LengthLimitingTextInputFormatter(15)],
          ),
          TextFormField(
            controller: widget.modeloController,
            decoration: const InputDecoration(
                labelText: 'Modelo',
                icon: Icon(Icons.numbers_outlined),
                iconColor: Color.fromARGB(255, 57, 127, 136),
                labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 57, 127, 136)))),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
          ),
          TextFormField(
            controller: widget.colorController,
            decoration: const InputDecoration(
                labelText: 'Color',
                icon: Icon(Icons.palette),
                iconColor: Color.fromARGB(255, 57, 127, 136),
                labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 57, 127, 136)))),
            inputFormatters: [LengthLimitingTextInputFormatter(15)],
          ),
          TextFormField(
            controller: widget.matriculaController,
            decoration: const InputDecoration(
                labelText: 'Matrícula',
                icon: Icon(Icons.drive_eta),
                iconColor: Color.fromARGB(255, 57, 127, 136),
                labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 57, 127, 136)))),
            inputFormatters: [LengthLimitingTextInputFormatter(8)],
          ),
          ElevatedButton(
            onPressed: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                String marca = widget.marcaController.text;
                int modelo = int.tryParse(widget.modeloController.text) ?? 0;
                String color = widget.colorController.text;
                String matricula = widget.matriculaController.text;

                agregarVehiculo(marca.toUpperCase(), modelo,
                    color.toUpperCase(), matricula.toUpperCase());

                widget.marcaController.clear();
                widget.colorController.clear();
                widget.matriculaController.clear();
                widget.modeloController.clear();

                // Cierra el AlertDialog
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing Data')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

/* PANTALLA DE GASTOS */

class PantallaGastos extends StatefulWidget {
  const PantallaGastos({super.key});

  @override
  State<PantallaGastos> createState() => _PantallaGastosState();
}

class _PantallaGastosState extends State<PantallaGastos> {
  double cantidadGastada = 0.00;
  final formKey = GlobalKey<FormState>();

  TextEditingController controladorFechaInicial = TextEditingController(text: '1950-01-01');
  TextEditingController controladorFechaFinal = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  TextEditingController controladorCategoriaSeleccionada = TextEditingController(text: 'Todas las categorias');
  TextEditingController controladorVehiculoSeleccionado = TextEditingController(text: 'Todos los vehiculos');
  TextEditingController controladorLugar = TextEditingController(text: 'Todos los lugares');

  Categoria? categoriaEncontrada;
  Vehiculo? vehiculoEncontrado;
  Gasto? gastoEncontrado;

  @override
  Widget build(BuildContext context) {
    void eliminarGasto(gastoId) {
      context.read<AppBloc>().add(EliminarGasto(gastoId));
    }

    void editarGasto(Gasto gastoViejo, Gasto gastoNuevo) {
      context
          .read<AppBloc>()
          .add(EditarGasto(gastoViejo: gastoViejo, gastoNuevo: gastoNuevo));
    }
    void mostrarAdvertencia(String mensaje) {
      final snackBar = SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    List<Gasto> gastos = [];
    List<Categoria> categorias = [];
    List<Vehiculo> vehiculos = [];
    List<Gasto> gastosFiltrados = [];

    double calcularTotalGastado(List<Gasto> gastos) {
      double total = 0.0;
      for (var gasto in gastos) {
        total += gasto.cantidad;
      }
      return total;
    }

    Categoria todasLasCategorias = Categoria(nombre: 'TODAS LAS CATEGORIAS', categoria_id: 999);
    Vehiculo todosLosVehiculos = Vehiculo(
      marca: "",
      modelo: 2012,
      vehiculo_id: 999,
      color: "azul",
      matricula: "TODOS LOS VEHICULOS",
    );
    Gasto todosLosGastos = Gasto(
        descripcion: '',
        lugar: 'TODOS LOS LUGARES',
        cantidad: 0,
        fecha: '1',
        categoria_id: 1,
        vehiculo_id: 1);

    var estado = context.watch<AppBloc>().state;

    if (estado is Operacional) {
      gastos = (estado).listaGastos;
      categorias = (estado).listaCategorias;
      vehiculos = (estado).listaVehiculos;
      gastosFiltrados = (estado).listaGastosFiltrados;
    }
    double cantidadGastada = calcularTotalGastado(gastosFiltrados);
    Categoria categoriaSeleccionada = todasLasCategorias;
    Vehiculo vehiculoSeleccionado = todosLosVehiculos;
    Gasto gastoSeleccionado = todosLosGastos;



    if (estado is Inicial) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Categoria> categoriaList = [todasLasCategorias];
      categoriaList.addAll(categorias);
    List<Vehiculo> vehiculoList = [todosLosVehiculos];
      vehiculoList.addAll(vehiculos);
    List<Gasto> gastoList = [todosLosGastos];
      gastoList.addAll(gastos);

      
      List<Gasto> eliminarDuplicados(List<Gasto> original){
        List<Gasto> result = [];

        for (var gasto in original) {
          if(!result.any((element) => element.lugar == gasto.lugar)){
            result.add(gasto);
          }
        }
        return result;
      }

      gastoList = eliminarDuplicados(gastoList);
      

categoriaEncontrada ??= todasLasCategorias;
vehiculoEncontrado ??= todosLosVehiculos;
gastoEncontrado ??= todosLosGastos;

    Categoria? buscarCategoria(listaCategoria, String nombreABuscar){
      for (var categoria in categoriaList) {
        if(categoria.nombre.toUpperCase() == nombreABuscar.toUpperCase()) {
          return categoria;
        }
      }
      return null;
    
    }
    Vehiculo? buscarVehiculo(listaVehiculos, String vehiculoABuscar){
      for (var vehiculo in vehiculoList) {
        if(vehiculo.matricula.toUpperCase() == vehiculoABuscar.toUpperCase()){
          return vehiculo;
        }
      }
      return null;

    }
    Gasto? buscarGasto(listaGastos, String gastoABuscar){
      for (var gasto in gastoList) {
        if(gasto.lugar.toUpperCase() == gastoABuscar.toUpperCase()){
          return gasto;
        }
      }
      return null;
    }


    Future<List<Categoria>> getCategoria(String search) async {
      await Future.delayed(const Duration(microseconds: 500));

      return categoriaList.where((element) => element.nombre.toUpperCase().startsWith(search.toUpperCase())).toList();
    }
    Future<List<Vehiculo>> getVehiculo(String search) async{
  
      await Future.delayed(const Duration(microseconds: 500));
      return vehiculoList.where((element) => element.matricula.toUpperCase().startsWith(search.toUpperCase())).toList();
    }
    Future<List<Gasto>> getLugar(String search) async{
      
      await Future.delayed(const Duration(microseconds: 500));
      return gastoList.where((element) => element.lugar.toUpperCase().startsWith(search.toUpperCase())).toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                onTap: () async {
                  DateTime? fechaSeleccionada = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now());
                  setState(() {
                    if (fechaSeleccionada != null) {
                      String formattedDate = DateFormat('yyyy-MM-dd').format(fechaSeleccionada);

                       if (DateTime.parse(formattedDate).isBefore(DateTime.parse(controladorFechaFinal.text)) ||
                           DateTime.parse(formattedDate).isAtSameMomentAs(DateTime.parse(controladorFechaFinal.text))) {
                        controladorFechaInicial.text = formattedDate;

                        context.read<AppBloc>().add(FiltrarGasto(
                        controladorFechaInicial.text,
                        controladorFechaFinal.text,
                        categoriaEncontrada!.categoria_id.toString(),
                        vehiculoEncontrado!.vehiculo_id.toString(),
                        gastoEncontrado!.lugar));
                          return;
                      }
                      mostrarAdvertencia('La fecha inicial debe ser menor que la final');
                    }
                  });
                },
                controller: controladorFechaInicial,
                decoration: const InputDecoration(labelText: 'Fecha Inicial'),
                readOnly: true,
              ),
              TextFormField(
          onTap: () async {
            DateTime? fechaSeleccionada = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now());
            setState(() {
              if (fechaSeleccionada != null) {
                String formattedDate = DateFormat('yyyy-MM-dd').format(fechaSeleccionada);

                if (DateTime.parse(formattedDate).isAfter(DateTime.parse(controladorFechaInicial.text)) ||
                    DateTime.parse(formattedDate).isAtSameMomentAs(DateTime.parse(controladorFechaInicial.text))) {
                  controladorFechaFinal.text = formattedDate;
               
                context.read<AppBloc>().add(FiltrarGasto(
                      controladorFechaInicial.text,
                      controladorFechaFinal.text,
                      categoriaEncontrada!.categoria_id.toString(),
                      vehiculoEncontrado!.vehiculo_id.toString(),
                      gastoEncontrado!.lugar));
                    return;
                }
                mostrarAdvertencia('La fecha final debe ser mayor que la inicial');
              }
            });
          },
          controller: controladorFechaFinal,
          decoration: const InputDecoration(labelText: 'Fecha Final'),
        ),
              
              AsyncAutocomplete<Categoria>(
                controller: controladorCategoriaSeleccionada,
                onChanged: (value) {
                  categoriaEncontrada = buscarCategoria(categorias, value);
                  
                  setState(() {
                  categoriaSeleccionada = categoriaEncontrada!;
                  controladorCategoriaSeleccionada.text = categoriaSeleccionada.nombre;

                  context.read<AppBloc>().add(FiltrarGasto(
                  controladorFechaInicial.text,
                  controladorFechaFinal.text,
                  categoriaEncontrada!.categoria_id.toString(),
                  vehiculoEncontrado!.vehiculo_id.toString(),
                  gastoEncontrado!.lugar.toString()));
                  });
                  
                },
                onTapItem: (Categoria categoria) {
                  categoriaEncontrada = buscarCategoria(categorias, categoria.nombre);

                  setState(() {
                    categoriaSeleccionada = categoriaEncontrada!;
                    controladorCategoriaSeleccionada.text = categoriaSeleccionada.nombre;

                  context.read<AppBloc>().add(FiltrarGasto(
                  controladorFechaInicial.text,
                  controladorFechaFinal.text,
                  categoriaEncontrada!.categoria_id.toString(),
                  vehiculoEncontrado!.vehiculo_id.toString(),
                  gastoEncontrado!.lugar.toString()));
                  });
                  
                },
                suggestionBuilder: (data) => ListTile(
                  title: Text(data.nombre),
                  subtitle: Text(data.categoria_id.toString()),
                ),
                asyncSuggestions: (searchValue) => getCategoria(searchValue)),
              
              AsyncAutocomplete<Vehiculo>(
                controller: controladorVehiculoSeleccionado,
                onChanged: (value) {
                  vehiculoEncontrado = buscarVehiculo(vehiculos, value);

                  setState(() {
                  vehiculoSeleccionado = vehiculoEncontrado!;
                  controladorVehiculoSeleccionado.text = vehiculoEncontrado!.matricula;

                  context.read<AppBloc>().add(FiltrarGasto(
                      controladorFechaInicial.text,
                      controladorFechaFinal.text,
                      categoriaEncontrada!.categoria_id.toString(),
                      vehiculoEncontrado!.vehiculo_id.toString(),
                      gastoEncontrado!.lugar.toString()));
                });
                },
                onTapItem: (Vehiculo vehiculo) {
                  vehiculoEncontrado = buscarVehiculo(vehiculos, vehiculo.matricula);

                  setState(() {
                    vehiculoSeleccionado = vehiculoEncontrado!;
                    controladorVehiculoSeleccionado.text = vehiculoEncontrado!.matricula;

                    context.read<AppBloc>().add(FiltrarGasto(
                      controladorFechaInicial.text,
                      controladorFechaFinal.text,
                      categoriaEncontrada!.categoria_id.toString(),
                      vehiculoEncontrado!.vehiculo_id.toString(),
                      gastoEncontrado!.lugar.toString()));

                  });
                },
                suggestionBuilder: (data) => ListTile(
                  title: Text(data.matricula),
                  subtitle: Text(data.vehiculo_id.toString()),
                ),
                asyncSuggestions: (searchValue) => getVehiculo(searchValue)),

              AsyncAutocomplete<Gasto>(
                controller: controladorLugar,
                onChanged: (value) {
                  gastoEncontrado = buscarGasto(gastos, value);

                  setState(() {
                  gastoSeleccionado = gastoEncontrado!;
                  controladorLugar.text = gastoEncontrado!.lugar;

                  context.read<AppBloc>().add(FiltrarGasto(
                      controladorFechaInicial.text,
                      controladorFechaFinal.text,
                      categoriaEncontrada!.categoria_id.toString(),
                      vehiculoEncontrado!.vehiculo_id.toString(),
                      gastoEncontrado!.lugar));
                });
                  
                },
                onTapItem: (Gasto gasto) {
                  gastoEncontrado = buscarGasto(gastos, gasto.lugar);

                  setState(() {
                    gastoSeleccionado = gastoEncontrado!;
                    controladorLugar.text = gastoEncontrado!.lugar;

                    context.read<AppBloc>().add(FiltrarGasto(
                      controladorFechaInicial.text,
                      controladorFechaFinal.text,
                      categoriaEncontrada!.categoria_id.toString(),
                      vehiculoEncontrado!.vehiculo_id.toString(),
                      gastoEncontrado!.lugar));
                  });
                },
                suggestionBuilder: (data) => ListTile(
                  title: Text(data.lugar),
                ),
                asyncSuggestions: (searchValue) => getLugar(searchValue)),
              
            ],
          ),
        ),
 
        
        Expanded(
          child: SizedBox(
            //width: 500,
            height: 200,
            child: BlocBuilder<AppBloc, AppEstado>(
              builder: (context, state) {
                if (state is Operacional) {
                  if (state.listaGastosFiltrados.isEmpty) {
                    return const Center(
                      child: Text('No hay gastos disponibles'),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.listaGastosFiltrados.length,
                    itemBuilder: (context, index) {
                      final gasto = state.listaGastosFiltrados[index];
                      final categorias = state.listaCategorias;
                      final vehiculos = state.listaVehiculos;

                      
                      late int x;
                      for (var vehiculo in vehiculos) {
                        if (vehiculo.vehiculo_id == gasto.vehiculo_id) {
                          x = vehiculos.indexOf(vehiculo);
                          break;
                        }
                      }
                      late int y;
                          for (var categoria in categorias) {
                            if (categoria.categoria_id == gasto.categoria_id) {
                              y = categorias.indexOf(categoria);
                              break;
                            }
                          }
                          Categoria categoriaDelGasto = categorias[y];
                          Vehiculo vehiculoDelGasto = vehiculos[x];

                      return ListTile(
                        leading: const Icon(Icons.attach_money_outlined),
                        title: Text(
                            '${vehiculos[x].marca.toString()} ${vehiculos[x].matricula.toString()} '),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(gasto.fecha.substring(0, 10)),
                            Text(gasto.cantidad.toStringAsFixed(2)),
                          ],
                        ),
                        onTap: () {
                            
                          
                          showDialog(
                            context: context, 
                            builder: (BuildContext context) => AlertDialog(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Gasto: ${gasto.gastoId}')
                                ],
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.category_outlined,
                                                      color: Color.fromARGB(255, 57, 127, 136),
                                                    ),
                                                  ),
                                                  Text('Categoria',
                                                      style: TextStyle(fontSize: 20,color: Color.fromARGB(255,57,127,136))),
                                                ],
                                              ),
                                    ),
                                            Text(categoriaDelGasto.nombre,style: const TextStyle(fontSize: 20)), 

                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.car_repair,
                                                      color: Color.fromARGB(255, 57, 127, 136),
                                                    ),
                                                  ),
                                                  Text('Vehiculo',style: TextStyle(fontSize: 20,color: Color.fromARGB(255,57,127,136))),
                                                ],
                                              ),
                                    ),
                                            Text(vehiculoDelGasto.matricula,style: const TextStyle(fontSize: 20)),
                                    
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.description_outlined,
                                                      color: Color.fromARGB(255, 57, 127, 136),
                                                    ),
                                                  ),
                                                  Text('Descripcion',
                                                      style: TextStyle(fontSize: 20,color: Color.fromARGB(255,57,127,136))),
                                                ],
                                              ),
                                    ),
                                            Text(gasto.descripcion,style: const TextStyle(fontSize: 20)),

                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.place_outlined,
                                                      color: Color.fromARGB(255, 57, 127, 136),
                                                    ),
                                                  ),
                                                  Text('Lugar',
                                                      style: TextStyle(fontSize: 20,color: Color.fromARGB(255,57,127,136))),
                                                ],
                                              ),
                                    ),
                                            Text(gasto.lugar,style: const TextStyle(fontSize: 20)),

                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.attach_money_outlined,
                                                      color: Color.fromARGB(255, 57, 127, 136),
                                                    ),
                                                  ),
                                                  Text('Cantidad',
                                                      style: TextStyle(fontSize: 20,color: Color.fromARGB(255,57,127,136))),
                                                ],
                                              ),
                                    ),
                                            Text(gasto.cantidad.toString(),style: const TextStyle(fontSize: 20)),

                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.calendar_month_outlined,
                                                      color: Color.fromARGB(255, 57, 127, 136),
                                                    ),
                                                  ),
                                                  Text('Fecha',
                                                      style: TextStyle(fontSize: 20,color: Color.fromARGB(255,57,127,136))),
                                                ],
                                              ),
                                    ),
                                            Text(gasto.fecha.substring(0, 10),style: const TextStyle(fontSize: 20)),

                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                      ElevatedButton(
                                      onPressed: () {
                                      final controladorVehiculoIdE = TextEditingController(text: gasto.vehiculo_id.toString());
                                      final controladorCategoriaIdE =TextEditingController(text:gasto.categoria_id.toString());
                                      final controladorDescripcionE =TextEditingController(text: gasto.descripcion);
                                      final controladorLugarE =TextEditingController(text: gasto.lugar);
                                      final controladorGastoE =TextEditingController(text: gasto.cantidad.toString());
                                      final controladorFechaE =TextEditingController(text: gasto.fecha.substring(0,10));
                                  
                                      final categoriaSeleccionadaE = categoriaDelGasto;
                                      final vehiculoSeleccionadoE = vehiculoDelGasto;
                                  
                                      void updateCategoriaSeleccionada(Categoria value) {
                                      setState(() {
                                        categoriaDelGasto= value;
                                        controladorCategoriaIdE.text = value.categoria_id.toString();
                                      });
                                    }
                                  
                                      void updateVehiculoSeleccionado(Vehiculo value) {
                                      setState(() {
                                        vehiculoDelGasto = value;
                                        controladorVehiculoIdE.text = value.vehiculo_id.toString();    
                                      });
                                    }
                                  
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) {
                                            return Scaffold(
                                              appBar: AppBar(
                                                backgroundColor: const Color.fromARGB(255,57,127,136),
                                                title: const Text("Editar gasto"),
                                              ),
                                              body: Form(
                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                key: formKey,
                                                child: Column(
                                                  children: [
                                  
                                                  DropdownButtonFormField<Categoria>(
                                                    decoration: const InputDecoration(
                                                        labelText: 'Categoria',
                                                        icon: Icon(Icons.category_rounded),
                                                        iconColor: Color.fromARGB(255, 57, 127, 136),
                                                        labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                                        enabledBorder: UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
                                                        focusedBorder: UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(color: Color.fromARGB(255, 57, 127, 136)))),
                                                    value: categoriaSeleccionadaE,
                                                    onChanged: (value) {
                                                      updateCategoriaSeleccionada(value!);
                                                    },
                                                    items: categorias.map<DropdownMenuItem<Categoria>>((Categoria categoria) {
                                                      return DropdownMenuItem<Categoria>(
                                                        value: categoria,
                                                        child: Text(categoria.nombre),
                                                      );
                                                    }).toList(),
                                                  ),
                                                  DropdownButtonFormField<Vehiculo>(
                                                    decoration: const InputDecoration(
                                                        labelText: 'Vehiculo',
                                                        icon: Icon(Icons.car_repair_rounded),
                                                        iconColor: Color.fromARGB(255, 57, 127, 136),
                                                        labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                                        enabledBorder: UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
                                                        focusedBorder: UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(color: Color.fromARGB(255, 57, 127, 136)))),
                                                    value: vehiculoSeleccionadoE,
                                                    onChanged: (value) {
                                                      updateVehiculoSeleccionado(value!);
                                                    },
                                                    items: vehiculos.map<DropdownMenuItem<Vehiculo>>((Vehiculo vehiculo) {
                                                      return DropdownMenuItem<Vehiculo>(
                                                        value: vehiculo,
                                                        child: Text('${vehiculo.marca} ${vehiculo.matricula}'),
                                                      );
                                                    }).toList(),
                                                  ),
                                                  TextFormField(
                                                    controller: controladorDescripcionE,
                                                    decoration: const InputDecoration(
                                                        labelText: 'Descripcion',
                                                        icon: Icon(Icons.description_rounded),
                                                        iconColor: Color.fromARGB(255, 57, 127, 136),
                                                        labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                                        enabledBorder: UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
                                                        focusedBorder: UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(color: Color.fromARGB(255, 57, 127, 136)))),
                                                    inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                                  ),
                                                  TextFormField(
                                                    validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                        return 'Por favor, ingresa el lugar';
                                                    }
                                                    return null;
                                                  },
                                                      controller: controladorLugarE,
                                                      decoration: const InputDecoration(
                                                          labelText: 'Lugar',
                                                          icon: Icon(Icons.place),
                                                          iconColor: Color.fromARGB(255, 57, 127, 136),
                                                          labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                                          enabledBorder: UnderlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
                                                          focusedBorder: UnderlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(color: Color.fromARGB(255, 57, 127, 136)))),
                                                      keyboardType: TextInputType.number,
                                                      inputFormatters: [LengthLimitingTextInputFormatter(14)]),
                                                  TextFormField(
                                                    validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'Por favor, ingresa la cantidad';
                                                  }
                                                  RegExp numbersWithDecimalRegExp = RegExp(r'^\d*\.?\d*$');
                                                  if (!numbersWithDecimalRegExp.hasMatch(value)) {
                                                    return 'Solo se permiten números del 0 al 9 y un punto decimal.';
                                                  }
                                                    return null;

                                                  },
                                                    controller: controladorGastoE,
                                                    decoration: const InputDecoration(
                                                        labelText: 'Cantidad',
                                                        icon: Icon(Icons.attach_money_outlined),
                                                        iconColor: Color.fromARGB(255, 57, 127, 136),
                                                        labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                                        enabledBorder: UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
                                                        focusedBorder: UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(color: Color.fromARGB(255, 57, 127, 136)))),
                                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                                      LengthLimitingTextInputFormatter(8),
                                                    ],
                                                  ),
                                                  TextFormField(
                                                    controller: controladorFechaE,
                                                    decoration: const InputDecoration(
                                                        icon: Icon(Icons.calendar_today),
                                                        labelText: 'Fecha',
                                                        iconColor: Color.fromARGB(255, 57, 127, 136),
                                                        labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                                        enabledBorder: UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
                                                        focusedBorder: UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(color: Color.fromARGB(255, 57, 127, 136)))),
                                                    readOnly: true,
                                                    onTap: () async {
                                                      DateTime? selectedDate = await showDatePicker(
                                                        context: context,
                                                        initialDate: DateTime.now(),
                                                        firstDate: DateTime(1950),
                                                        lastDate: DateTime.now(),
                                                        builder: (BuildContext context, Widget? child) {
                                                          return Theme(
                                                            data: ThemeData.light().copyWith(
                                                              primaryColor: const Color.fromARGB(
                                                                  255, 57, 127, 136), // Cambia el color principal
                                                              colorScheme: const ColorScheme.light(
                                                                  primary: Color.fromARGB(255, 57, 127, 136)),
                                                              buttonTheme: const ButtonThemeData(
                                                                  textTheme: ButtonTextTheme.primary),
                                                            ),
                                                            child: child!,
                                                          );
                                                        },
                                                      );
                                  
                                                      if (selectedDate != null) {
                                                        String formattedDate =
                                                            DateFormat('yyyy-MM-dd').format(selectedDate);
                                                        controladorFechaE.text = formattedDate;
                                                      }
                                                    },
                                                    keyboardType: TextInputType.datetime,
                                                  ),
                                  
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                                                    child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(
                                                            255,
                                                            57,
                                                            127,
                                                            136), // Puedes cambiar el color según tus preferencias
                                                      ),
                                                      onPressed: () {
                                                      if(formKey.currentState!.validate()) {
                                                        final nuevaCategoria = controladorCategoriaIdE.text.trim();
                                                        final nuevoVehiculo = controladorVehiculoIdE.text.trim();
                                                        final nuevaDescripcion = controladorDescripcionE.text.trim();
                                                        final nuevoLugar = controladorLugarE.text.trim();
                                                        final nuevaCantidad = controladorGastoE.text.trim();
                                                        final nuevaFecha = controladorFechaE.text.trim();
                                                                                    
                                                        Gasto nuevoGasto = Gasto(gastoId: gasto.gastoId, descripcion: nuevaDescripcion, lugar: nuevoLugar, cantidad: double.parse(nuevaCantidad), fecha: nuevaFecha, categoria_id: int.parse(nuevaCategoria), vehiculo_id: int.parse(nuevoVehiculo));
                                                        
                                                        
                                                        editarGasto(gasto, nuevoGasto);
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                                                    
                                                        
                                                                                    
                                                        
                                                                                    
                                                      }
                                                    }, child: const Text('Editar')),
                                                  )
                                  
                                                  ],
                                                )),
                                            );
                                        }
                                        )
                                      );
                                  
                                        }, 
                                        style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(
                                                            255,
                                                            57,
                                                            127,
                                                            136), // Puedes cambiar el color según tus preferencias
                                                      ),
                                        child: const Row(
                                           children: [
                                            Icon(Icons.edit),
                                            Text('Editar'),
                                           ],
                                         ),
                                         ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(
                                                            255,
                                                            57,
                                                            127,
                                                            136), // Puedes cambiar el color según tus preferencias
                                                      ),
                                          onPressed: () {
                                          showDialog(
                                            context: context,
                                             builder: (BuildContext context) {
                                              return AlertDialog(
                                                content: const Text('¿Estás seguro de que quieres eliminar este gasto?'),
                                                actions: [
                                                  TextButton(onPressed: () {
                                                    Navigator.pop(context);
                                                  }, 
                                                  child: const Text('Cancelar',style: TextStyle(
                                                                          color: Color.fromARGB(255,57,127,136)),
                                                                    ),
                                                 ),
                                                 ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(
                                                          255,
                                                          57,
                                                          127,
                                                          136), // Puedes cambiar el color según tus preferencias
                                                    ),
                                                  onPressed: () {
                                                  eliminarGasto(gasto.gastoId);
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                  mostrarAdvertencia("Gasto eliminado correctamente");
                                                 },
                                                  child: const Text('Eliminar'))
                                                ],
                                              );
                                  
                                             }
                                            );
                                        },
                                         child: const Row(
                                           children: [
                                            Icon(Icons.delete),
                                            Text('Eliminar'),
                                           ],
                                         ),
                                         ),
                                  
                                      ],
                                    ),
                                  )
                                  ],
                                ),
                              ),
                            )
                            );
                        },
                      );
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Valor: ${cantidadGastada.toStringAsFixed(2)}'),
        const BotonAgregarGasto(),
      ],
    );
  }
}

class BotonAgregarGasto extends StatefulWidget {

  const BotonAgregarGasto({super.key});

  @override
  State<BotonAgregarGasto> createState() => _BotonAgregarGastoState();
}

class _BotonAgregarGastoState extends State<BotonAgregarGasto> {

  final TextEditingController vehiculoController = TextEditingController();

  final TextEditingController descripcionController = TextEditingController();

  final TextEditingController lugarController = TextEditingController();

  final TextEditingController cantidadController = TextEditingController();

  final TextEditingController fechaController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  final TextEditingController idCategoriaSeleccionada =TextEditingController(text: '1');

  final TextEditingController idVehiculoSeleccionado =TextEditingController(text: '1');

  late TooltipBehavior _tooltipBehavior;

  @override 
  void initState(){
   _tooltipBehavior = TooltipBehavior(enable: true);
   super.initState();
                  }

  @override
  Widget build(BuildContext context) {
    
    
    void agregarGasto(String descripcion, String lugar, double cantidad,
        String fecha, int categoriaId, int vehiculoId) {
      Gasto nuevoGasto = Gasto(
          descripcion: descripcion,
          lugar: lugar,
          cantidad: cantidad,
          fecha: fecha,
          categoria_id: categoriaId,
          vehiculo_id: vehiculoId);
      context.read<AppBloc>().add(AgregarGasto(gasto: nuevoGasto));
    }

    
    List<Categoria> categorias = [];
    List<Vehiculo> vehiculos = [];
    List<Gasto> listaFiltrada = [];
    var estado = context.watch<AppBloc>().state;


    if (estado is Operacional) {
      categorias = (estado).listaCategorias;
      vehiculos = (estado).listaVehiculos;
      listaFiltrada = (estado).listaGastosFiltrados;
    }

    String buscarCategoria(int id){
      for (var categoria in categorias) {
        if(categoria.categoria_id == id) {
          return categoria.nombre;
        }
      }
      return '';
    }
      String  buscarVehiculo(int id){
      for (var vehiculo in vehiculos) {
        if(vehiculo.vehiculo_id == id){
          return vehiculo.matricula;
        }
      }
      return '';
    }

    Categoria categoriaSeleccionada = categorias[0];
    Vehiculo vehiculoSeleccionado = vehiculos[0];
    final formKey = GlobalKey<FormState>();

    void updateCategoriaSeleccionada(Categoria value) {
    setState(() {
      categoriaSeleccionada = value;
      idCategoriaSeleccionada.text =
          (value).categoria_id.toString();
    });
  }

    void updateVehiculoSeleccionado(Vehiculo value) {
    setState(() {
      vehiculoSeleccionado = value;
      idVehiculoSeleccionado.text =
          (value).vehiculo_id.toString();
    });
  }

                 final List<ChartData> chartData = listaFiltrada.map((gasto) {
                    String categoria = buscarCategoria(gasto.categoria_id).toString();
                    double monto = gasto.cantidad;
                    return ChartData(categoria, monto);
                  }).toList();
                  final List<ChartData> chartData2 = listaFiltrada.map((gasto) {
                    String vehiculo = buscarVehiculo(gasto.vehiculo_id).toString();
                    double monto = gasto.cantidad;
                    return ChartData(vehiculo, monto);
                  }).toList();
                  final List<ChartData> chartData3 = listaFiltrada.map((gasto) {
                    String lugar = gasto.lugar;
                    double monto = gasto.cantidad;
                    return ChartData(lugar, monto);
                  }).toList();

                  List<ChartData> mergedData = mergeChartData(chartData);
                  List<ChartData> mergedData2 = mergeChartData(chartData2);
                  List<ChartData> mergedData3 = mergeChartData(chartData3);
    

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
              onPressed: () {
                
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                    title: const Text('Agregar Gasto'),
                    content: SingleChildScrollView(
                    child: Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      key: formKey,
                      child: Column(
                        
                        children: <Widget>[
                          DropdownButtonFormField<Categoria>(
                            decoration: const InputDecoration(
                                labelText: 'Categoria',
                                icon: Icon(Icons.category_rounded),
                                iconColor: Color.fromARGB(255, 57, 127, 136),
                                labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color.fromARGB(255, 57, 127, 136)))),
                            value: categoriaSeleccionada,
                            onChanged: (value) {
                              updateCategoriaSeleccionada(value!);
                            },
                            items: categorias
                                .map<DropdownMenuItem<Categoria>>((Categoria categoria) {
                              return DropdownMenuItem<Categoria>(
                                value: categoria,
                                child: Text(categoria.nombre),
                              );
                            }).toList(),
                          ),
                          DropdownButtonFormField<Vehiculo>(
                            decoration: const InputDecoration(
                                labelText: 'Vehiculo',
                                icon: Icon(Icons.car_repair_rounded),
                                iconColor: Color.fromARGB(255, 57, 127, 136),
                                labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color.fromARGB(255, 57, 127, 136)))),
                            value: vehiculoSeleccionado,
                            onChanged: (value) {
                              updateVehiculoSeleccionado(value!);
                            },
                            items: vehiculos
                                .map<DropdownMenuItem<Vehiculo>>((Vehiculo vehiculo) {
                              return DropdownMenuItem<Vehiculo>(
                                value: vehiculo,
                                child: Text('${vehiculo.marca} ${vehiculo.matricula}'),
                              );
                            }).toList(),
                          ),
                          TextFormField(
                            controller: descripcionController,
                            decoration: const InputDecoration(
                                labelText: 'Descripcion',
                                icon: Icon(Icons.description_rounded),
                                iconColor: Color.fromARGB(255, 57, 127, 136),
                                labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color.fromARGB(255, 57, 127, 136)))),
                            inputFormatters: [LengthLimitingTextInputFormatter(40)],
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                  return 'Por favor, ingresa el lugar';
                              }
                              return null;
                            },
                              controller: lugarController,
                              decoration: const InputDecoration(
                                  labelText: 'Lugar',
                                  icon: Icon(Icons.place),
                                  iconColor: Color.fromARGB(255, 57, 127, 136),
                                  labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color.fromARGB(255, 57, 127, 136)))),
                              inputFormatters: [LengthLimitingTextInputFormatter(14)]),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingresa la cantidad';
                            }
                            RegExp numbersWithDecimalRegExp = RegExp(r'^\d*\.?\d*$');
                            if (!numbersWithDecimalRegExp.hasMatch(value)) {
                              return 'Solo se permiten números del 0 al 9 y un punto decimal.';
                            }
                              return null;

                            },
                            controller: cantidadController,
                            decoration: const InputDecoration(
                                labelText: 'Cantidad',
                                icon: Icon(Icons.attach_money_outlined),
                                iconColor: Color.fromARGB(255, 57, 127, 136),
                                labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color.fromARGB(255, 57, 127, 136)))),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                              LengthLimitingTextInputFormatter(8),
                            ],
                          ),
                          TextFormField(
                            controller: fechaController,
                            decoration: const InputDecoration(
                                icon: Icon(Icons.calendar_today),
                                labelText: 'Fecha',
                                iconColor: Color.fromARGB(255, 57, 127, 136),
                                labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color.fromARGB(255, 57, 127, 136))),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color.fromARGB(255, 57, 127, 136)))),
                            readOnly: true,
                            onTap: () async {
                              DateTime? selectedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now(),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      primaryColor: const Color.fromARGB(
                                          255, 57, 127, 136), // Cambia el color principal
                                      colorScheme: const ColorScheme.light(
                                          primary: Color.fromARGB(255, 57, 127, 136)),
                                      buttonTheme: const ButtonThemeData(
                                          textTheme: ButtonTextTheme.primary),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                    
                              if (selectedDate != null) {
                                String formattedDate =
                                    DateFormat('yyyy-MM-dd').format(selectedDate);
                                fechaController.text = formattedDate;
                              }
                            },
                            keyboardType: TextInputType.datetime,
                          ),
                        
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
                            
                            child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 57, 127, 136)),
                                  onPressed: () {
                                    if(formKey.currentState!.validate()){
                                    int categoriaId = int.parse(idCategoriaSeleccionada.text);
                                    int vehiculoId = int.parse(idVehiculoSeleccionado.text);
                                    String descripcion =descripcionController.text.toUpperCase();
                                    String lugar = lugarController.text.toUpperCase();
                                    double cantidad = double.parse(cantidadController.text);
                                    String fecha = DateTime.parse(fechaController.text).toString();
                              
                                    agregarGasto(descripcion, lugar, cantidad, fecha,categoriaId, vehiculoId);
                              
                                    vehiculoController.clear();
                                    descripcionController.clear();
                                    lugarController.clear();
                                    cantidadController.clear();
                                    
                              
                                    Navigator.pop(context);
                                    }
                                  },
                                  child: const Text('Guardar')),
                          ),
                        
                          TextButton(
                                style: TextButton.styleFrom(
                                foregroundColor:
                                 const Color.fromARGB(255, 57, 127, 136)),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancelar')),
                          
                        ],
                      ),
                    ),
                  ), 
                 )
                );
              },
              style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 57, 127, 136)),
              label: const Text('Agregar Gasto'),
              icon: const Icon(Icons.add),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
               backgroundColor: const Color.fromARGB(255, 57, 127, 136),
            ),
            onPressed: () {
            
            showDialog(
              context: context,
               builder: (BuildContext context) => AlertDialog(
              title: const Text('Graficar por...'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 57, 127, 136)
                        ),
                        onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {   
                            return Grafica(tooltipBehavior: _tooltipBehavior, mergedData: mergedData);
                          }
                        ));
                      }, 
                      label: const Text('Categoría'),
                      icon: const Icon(Icons.category_outlined),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 57, 127, 136)
                        ),
                        onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {   
                            return Grafica(tooltipBehavior: _tooltipBehavior, mergedData: mergedData2);
                          }
                        ));
                      }, 
                      label: const Text('Vehículo'),
                      icon: const Icon(Icons.drive_eta_rounded),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 57, 127, 136)
                        ),
                        onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {   
                            return Grafica(tooltipBehavior: _tooltipBehavior, mergedData: mergedData3);
                          }
                        ));
                    
                      }, 
                      label: const Text('Lugar'),
                      icon: const Icon(Icons.place_outlined),
                      ),
                    ),
                  ],
                ),

              ),
               )
               
               );
            
            
          }, 
          icon: const Icon(Icons.auto_graph_rounded),          
          label: const Text('Gráfica')
          )
        ],
      ),
    );
  }
}

class Grafica extends StatelessWidget {
  const Grafica({
    super.key,
    required TooltipBehavior tooltipBehavior,
    required this.mergedData,
  }) : _tooltipBehavior = tooltipBehavior;

  final TooltipBehavior _tooltipBehavior;
  final List<ChartData> mergedData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255,57,127,136),
        title: const Text("Gráfica"),
        ),
        body: Center(
          child: 
            SfPyramidChart(
              title: ChartTitle(text: 'Reporte de gastos'),
              tooltipBehavior: _tooltipBehavior,
              legend: Legend(isVisible: true),
              series:PyramidSeries<ChartData, String>(
              dataSource: mergedData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: const DataLabelSettings(isVisible: true)
                                  )
                              )
          
        ),
    );
  }
}

class ChartData{
  ChartData(this.x, this.y);
  final String x;
  final double y;

}

List<ChartData> mergeChartData(List<ChartData> data) {
  Map<String, double> resultMap = {};

  // Iterate through the data and merge values with the same x
  for (ChartData entry in data) {
    if (resultMap.containsKey(entry.x)) {
      // If x already exists, add y values
      resultMap[entry.x] = (resultMap[entry.x] ?? 0.0) + entry.y;
    } else {
      // If x doesn't exist, add a new entry
      resultMap[entry.x] = entry.y;
    }
  }

  // Convert the resultMap back to a list of ChartData
  List<ChartData> mergedData = resultMap.entries
      .map((entry) => ChartData(entry.key, entry.value))
      .toList();

  return mergedData;
}