import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/bloc.dart';
import 'modelos/vehiculo.dart';


void main() async {
  runApp(const AplicacionInyectada());
  WidgetsFlutterBinding.ensureInitialized();
  
}

class AplicacionInyectada extends StatelessWidget {
  const AplicacionInyectada({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppBloc()..add(Inicializado()),
      child:const MainApp(),
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
            // ListaCategorias(),
            // AgregarCategoriaWidget(),
            PantallaVehiculos(),
          ],
        ),
      ),
      
    );
  }
}

/* NAVIGATION BAR*/

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // Lista de pantallas que se mostrarán en función del índice seleccionado.
  final List<Widget> _screens = [
    Screen1(),
    Screen2(),
    Screen3(),
  ];

  // Lista de elementos de la barra de navegación inferior.
  final List<BottomNavigationBarItem> _bottomNavBarItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Inicio',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Buscar',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Perfil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bottom Navigation Bar Example'),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _bottomNavBarItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class Screen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Pantalla 1'),
    );
  }
}

class Screen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Pantalla 2'),
    );
  }
}

class Screen3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Pantalla 3'),
    );
  }
}


/* Pantalla de categorias */

class ListaCategorias extends StatelessWidget {
  const ListaCategorias({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> categorias = [];
    var estado = context.watch<AppBloc>().state;
    print(estado);
    // if(estado is Inicial) return const Text('Oh no');
    if (estado is Operacional) categorias = (estado).listaCategorias;
    if(estado is Inicial) return const Center(child: CircularProgressIndicator());

    if(categorias.isEmpty){
      return const Center(
        child: Text('Aun no hay categorias'),
      );
    }
    return Expanded(
      child: SizedBox(
        height: 200,
        width: 200,
        child: ListView.builder(
          itemCount: categorias.length,
          itemBuilder:(context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => 
                            VehiculosEnCategoria(categoria: categorias[index]),
                  ),
                );
              },
              child: TileCategoria(categoria: categorias[index]),
            );
          },
        ),
      ),
    );
  }
}

class TileCategoria extends StatelessWidget {
  final String categoria;

  const TileCategoria({Key? key, required this.categoria}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoria,
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _mostrarDialogoEditar(context, categoria),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      
                      context.read<AppBloc>().add(EliminarCategoria(categoriaAEliminar: categoria));
                      
                    },
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  void _mostrarDialogoEditar(BuildContext context, String categoriaVieja) {
    final controlador = TextEditingController(text: categoriaVieja);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Categoría'),
          content: TextFormField(
            controller: controlador,
            decoration: const InputDecoration(
              hintText: 'Nueva categoría',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final nuevaCategoria = controlador.text.trim();
                if (nuevaCategoria.isNotEmpty) {
                  context.read<AppBloc>().add(ActualizarCategoria(oldCategoria: categoriaVieja, newCategoria: nuevaCategoria));
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: controlador,
            decoration: const InputDecoration(
              hintText: 'Nueva categoria',
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(onPressed: () {
            final nuevaCategoria = controlador.text.trim();
            if(nuevaCategoria.isNotEmpty) {
              context.read<AppBloc>().add(AgregarCategoria(categoriaAAgregar: nuevaCategoria));
              controlador.clear();
            }
          }, 
          child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}

/* Pantalla de vehiculos */

class PantallaVehiculos extends StatelessWidget {
  const PantallaVehiculos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículos'),
      ),
      body: BlocBuilder<AppBloc, AppEstado>(
        builder: (context, state) {
          if (state is Operacional) {
            return Column(
              children: [
                const Text('Vehículos', style: TextStyle(fontSize: 20)),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.listaVehiculos.length,
                    itemBuilder: (context, index) {
                      final vehiculo = state.listaVehiculos[index];
                      return ListTile(
                        title: Text(vehiculo.matricula),
                        onTap: () {
                          // Navegar a la página de detalles del vehículo
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalleVehiculoSeleccionado(vehiculo: vehiculo),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Mostrar el formulario como un modal
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text('Agregar Vehículo'),
                        content: FormularioVehiculo(),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Cerrar el AlertDialog
                            },
                            child: Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Lógica para guardar el vehículo
                              // Puedes llamar a tu Bloc para manejar la lógica de agregar el vehículo
                              // Luego, cierra el AlertDialog
                              Navigator.pop(context);
                            },
                            child: Text('Guardar'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('Agregar Vehículo'),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class DetalleVehiculoSeleccionado extends StatelessWidget {
  final Vehiculo vehiculo;
  const DetalleVehiculoSeleccionado({super.key, required this.vehiculo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Vehículo'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Matrícula: ${vehiculo.matricula}', style: const TextStyle(fontSize: 20)),
          // Agrega aquí más información sobre el vehículo según tus necesidades
        ],
      ),
    );
  }
}

class FormularioVehiculo extends StatelessWidget {
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();

  FormularioVehiculo({super.key});
  

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _marcaController,
          decoration: const InputDecoration(labelText: 'Marca'),
        ),
        TextFormField(
          controller: _modeloController,
          decoration: const InputDecoration(labelText: 'Modelo'),
        ),
        TextFormField(
          controller: _colorController,
          decoration: const InputDecoration(labelText: 'Color'),
        ),
        TextFormField(
          controller: _matriculaController,
          decoration: const InputDecoration(labelText: 'Matrícula'),
        ),
      ],
    );
  }
}
/* Pantalla de categoria seleccionada */

class VehiculosEnCategoria extends StatelessWidget {
  final String categoria;

  const VehiculosEnCategoria({super.key, required this.categoria});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoria),
      ),
      body: BlocBuilder<AppBloc, AppEstado>(
        builder: (context, state) {
          if(state is Operacional){
            final vehiculosEnCategoria = state.listaVehiculos
            .where((vehiculo) => vehiculo.categoria == categoria)
            .toList();

          return ListView.builder(
            itemCount: vehiculosEnCategoria.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(vehiculosEnCategoria[index].marca),
                subtitle: Text(vehiculosEnCategoria[index].matricula),
              );
            },
          );
         }
         else{
          return const Center(
            child: Text('Error al cargar los detalles de la categoria'),
          );
         }
        },
      ),
    );
  }
}