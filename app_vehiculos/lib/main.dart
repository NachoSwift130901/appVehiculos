// ignore_for_file: library_private_types_in_public_api

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
    return  MaterialApp(
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
            ListaCategorias(),
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

  final List<Widget> _pages = [
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Vehículos', style: TextStyle(fontSize: 20)),
        const PantallaVehiculos(),
        
        const SizedBox(height: 20),
        BotonAgregarVehiculo(),
  
      ],
    ),
    const Column(
      children: [
        ListaCategorias(),
        SizedBox(height: 20),
        AgregarCategoriaWidget()
      ],
    ),
    const Text('Contenido de la página de gastos'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BottomNavigationBar Example'),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Carros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Categorias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Gastos',
          ),
        ],
      ),
    );
  }
}

/* PANTALLA DE CATEGORIAS */

class ListaCategorias extends StatelessWidget {
  const ListaCategorias({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> categorias = [];
    var estado = context.watch<AppBloc>().state;
    print(estado);
    // if(estado is Inicial) return const Text('Oh no');
    if (estado is Operacional) categorias = (estado).listaCategorias;
    if (estado is Inicial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (categorias.isEmpty) {
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
          itemBuilder: (context, index) {
            return GestureDetector(
             /* onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        
                  ),
                );
              },
              */
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
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
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
                      context.read<AppBloc>().add(
                          EliminarCategoria(categoriaAEliminar: categoria));
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
                  context.read<AppBloc>().add(ActualizarCategoria(
                      oldCategoria: categoriaVieja,
                      newCategoria: nuevaCategoria));
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
      padding: const EdgeInsets.all(50.0),
      child: Column(
        children: [
          TextField(
            controller: controlador,
            decoration: const InputDecoration(
              hintText: 'Nueva categoria',
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              final nuevaCategoria = controlador.text.trim();
              if (nuevaCategoria.isNotEmpty) {
                context
                    .read<AppBloc>()
                    .add(AgregarCategoria(categoriaAAgregar: nuevaCategoria));
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

class _AgregarCategoriaWidgetStateTest extends State<AgregarCategoriaWidget> {
  final TextEditingController controlador = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _mostrarDialogo(context);
      },
      child: const Text('Agregar'),
    );
  }

  Future<void> _mostrarDialogo(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Categoría'),
          content: TextField(
            controller: controlador,
            decoration: const InputDecoration(
              hintText: 'Nueva categoría',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final nuevaCategoria = controlador.text.trim();
                if (nuevaCategoria.isNotEmpty) {
                  context
                  .read<AppBloc>()
                  .add(AgregarCategoria(categoriaAAgregar: nuevaCategoria));
                  controlador.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
}


/* Pantalla de categoria seleccionada */
/*
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
          if (state is Operacional) {
            final vehiculosEnCategoria = state.listaCategorias
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
          } else {
            return const Center(
              child: Text('Error al cargar los detalles de la categoria'),
            );
          }
        },
      ),
    );
  }
*/
/* PANTALLA DE VEHICULOS */

class PantallaVehiculos extends StatelessWidget {

  const PantallaVehiculos({super.key});

  @override
   Widget build(BuildContext context) {

    void eliminarVehiculo(Vehiculo vehiculo) {
    context.read<AppBloc>().add(
                EliminarVehiculo(matricula: vehiculo.matricula));
                
  }
    void actualizarVehiculo(matricula, marca, modelo, color, matriculaId) {
      context.read<AppBloc>().add(ActualizarVehiculo(matricula, marca, modelo, color, matriculaId));
    }

    void mostrarAdvertencia(String mensaje){
  
        final snackBar = SnackBar(
        content: Text(mensaje),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    
    List<Vehiculo> vehiculos = [];
    var estado = context.watch<AppBloc>().state;
    print(estado);
    if(estado is Operacional) vehiculos = (estado).listaVehiculos;
    if(estado is Inicial) {
      return const Center(child: CircularProgressIndicator());
    }
    

    if(vehiculos.isEmpty){
      return const Center(
        child: Text('Aun no hay vehiculos compa'),
      );
    }
    return BlocBuilder<AppBloc, AppEstado>(
      
      builder: (context, state) {
        if (state is Operacional) {
          return 
              Expanded(
                child: SizedBox(
                  width:200,
                  height: 200,
                  child: ListView.builder(
                    itemCount: state.listaVehiculos.length,
                    itemBuilder: (context, index) {
                      final vehiculo = state.listaVehiculos[index];
                      return ListTile(
                        title: Text(vehiculo.matricula),
                        subtitle: Text(vehiculo.marca),
                        onTap: () {
                          // Navegar a la página de detalles del vehículo
                          Navigator.push(
                          context,
                          MaterialPageRoute(
                          builder: (BuildContext context) {
                            void cerrartodo(){
                              Navigator.pop(context);
                            }
                            return Scaffold(
                              appBar: AppBar(
                                title: Text('Vehiculo: ${vehiculo.matricula}'),
                              ),
                                body: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Marca: ${vehiculo.marca}',
                                      style: const TextStyle(fontSize: 20)),
                                  Text('Modelo: ${vehiculo.modelo}',
                                      style: const TextStyle(fontSize: 20)),
                                  Text('Color: ${vehiculo.color}',
                                      style: const TextStyle(fontSize: 20)),
                                  Text('Matricula: ${vehiculo.matricula}',
                                      style: const TextStyle(fontSize: 20)),
                                  // Agrega aquí más información sobre el vehículo según tus necesidades
                                ],
                              ),
                                floatingActionButton: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    FloatingActionButton(
                                      onPressed: () {
                                        eliminarVehiculo(vehiculo);
                                        Navigator.pop(context);
                                      },
                                      tooltip: 'Borrar Vehiculo',
                                      child: const Icon(Icons.delete),
                                      ),
                                    const SizedBox(height: 16),
                                    FloatingActionButton(
                                        onPressed: () {
                                          final controladorMarca = TextEditingController(text: vehiculo.marca);
                                          final controladorModelo = TextEditingController(text: vehiculo.modelo.toString());
                                          final controladorColor = TextEditingController(text: vehiculo.color);
                                          final controladorMatricula = TextEditingController(text: vehiculo.matricula);

                                          showDialog(
                                            context: context, 
                                            builder: (context) {
                                            return AlertDialog(
                                                title: const Text('Editar vehiculo'),
                                                content: Column(
                                                  children: [
                                              TextFormField(
                                                controller: controladorMarca,
                                                decoration: const InputDecoration(labelText: 'Marca'),
                                              ),
                                              TextFormField(
                                                controller: controladorModelo,
                                                decoration: const InputDecoration(labelText: 'Modelo'),
                                              ),
                                              TextFormField(
                                                controller: controladorColor,
                                                decoration: const InputDecoration(labelText: 'Color'),
                                              ),
                                              TextFormField(
                                                controller: controladorMatricula,
                                                decoration: const InputDecoration(labelText: 'Matricula'),
                                              ),
                                                  ],
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                    final nuevaMatricula = controladorMatricula.text.trim();
                                                    final nuevaMarca = controladorMarca.text.trim();
                                                    final nuevoModelo = controladorModelo.text.trim();
                                                    final nuevoColor = controladorColor.text.trim();

                                                    final matriculaVieja = vehiculo.matricula;

                                                    actualizarVehiculo(nuevaMatricula, nuevaMarca, nuevoModelo, nuevoColor, matriculaVieja);
                                                    
                                                    mostrarAdvertencia("Vehiculo actualizado correctamente");
                                                    cerrartodo();
                                                  }, 
                                                  child: const Text('Guardar')),
                                                  TextButton(onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Cancelar'))
                                                ],
                                                
                                              );
                                              
                                            }
                                            );
                                          if (controladorMarca.text.isEmpty || controladorModelo.text.isEmpty || controladorColor.text.isEmpty || controladorMatricula.text.isEmpty) {
                                        mostrarAdvertencia("Todos los campos son obligatorios");
                                        return; // Sale de la función para evitar más procesamiento
                                          }
                                          

    
                                      },
                                      tooltip: 'Editar Vehiculo',
                                      child: const Icon(Icons.edit),
                                    )
                                  ],
                                ),
                                
                            )

                            ;
                          },
                        ),
                          );
                        },
                      );
                    },
                  ),
                ),
              );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class BotonAgregarVehiculo extends StatelessWidget {
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  
  BotonAgregarVehiculo({super.key});

  @override
   Widget build(BuildContext context) {
    void agregarVehiculo(String marca, int modelo, String color, String matricula) {
    context.read<AppBloc>().add(AgregarVehiculo(
                marca: marca,
                modelo: modelo,
                color: color,
                matricula: matricula,
                ));
                
  }
    return ElevatedButton(
      onPressed: () {
        // Mostrar el formulario como un modal
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            
            title: const Text('Agregar Vehículo'),
            content: FormularioVehiculo(
              marcaController: _marcaController,
              modeloController: _modeloController,
              colorController: _colorController,
              matriculaController: _matriculaController,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cerrar el AlertDialog
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  String marca = _marcaController.text;
                  int modelo = int.tryParse(_modeloController.text) ?? 0;
                  String color = _colorController.text;
                  String matricula = _matriculaController.text;

                  agregarVehiculo(marca, modelo, color, matricula);
                  _marcaController.clear();
                  _colorController.clear();
                  _matriculaController.clear();
                  _modeloController.clear();


                  // Cierra el AlertDialog
                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        );
      },
      child: const Text('Agregar Vehículo'),
    );
  }

  
}

class FormularioVehiculo extends StatelessWidget {
  final TextEditingController marcaController;
  final TextEditingController modeloController;
  final TextEditingController colorController;
  final TextEditingController matriculaController;
  
  const FormularioVehiculo({super.key, required this.marcaController, required this.modeloController, required this.colorController, required this.matriculaController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: marcaController,
          decoration: const InputDecoration(labelText: 'Marca'),
        ),
        TextFormField(
          controller: modeloController,
          decoration: const InputDecoration(labelText: 'Modelo'),
        ),
        TextFormField(
          controller: colorController,
          decoration: const InputDecoration(labelText: 'Color'),
        ),
        TextFormField(
          controller: matriculaController,
          decoration: const InputDecoration(labelText: 'Matrícula'),
        ),
      ],
    );
  }
}

