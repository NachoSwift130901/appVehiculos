// ignore_for_file: library_private_types_in_public_api, must_be_immutable

import 'package:app_vehiculos/modelos/gastos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/bloc.dart';
import 'modelos/vehiculo.dart';
import 'modelos/categoria.dart';
import 'package:intl/intl.dart';
import 'package:flutter_async_autocomplete/flutter_async_autocomplete.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AplicacionInyectada());
  
}

class AplicacionInyectada extends StatelessWidget {
  const AplicacionInyectada({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
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

  String obtenerTitulo(){
    switch (_currentIndex){
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
    if(estado is Operacional){
    categorias = (estado).listaCategorias;
    vehiculos = (estado).listaVehiculos;
    }

    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 57, 127, 136),
        title: 
      
        
        
        Text(obtenerTitulo()),
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
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.car_repair),
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
  
}



/* PANTALLA DE CATEGORIAS */

class PantallaCategorias extends StatelessWidget {
  const PantallaCategorias({super.key});

  @override
  Widget build(BuildContext context) {
    List<Categoria> categorias = [];
    var estado = context.watch<AppBloc>().state;
    void editarCategoria(old, nueva){
      context.read<AppBloc>().add(ActualizarCategoria(oldCategoria: old , newCategoria: nueva));
    }
    print(estado);
    // if(estado is Inicial) return const Text('Oh no');
    if (estado is Operacional) categorias = (estado).listaCategorias;
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
                                      content: TextFormField(
                                        controller: controlador,
                                        decoration: const InputDecoration(
                                            hintText: 'Nueva Categoria'),
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            final nuevaCategoria =
                                                controlador.text.trim();
                                            if (nuevaCategoria.isNotEmpty) {
                                              editarCategoria(categoria.nombre,
                                                  nuevaCategoria);
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
                                        )
                                      ],
                                    );
                                  });
                            },
                            icon: const Icon(Icons.edit)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(onPressed: () {
                          context.read<AppBloc>().add(
                            EliminarCategoria(categoriaAEliminar: categoria.nombre));
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
  @override
  Widget build(BuildContext context) {
    void agregarCategoria(nuevaCategoria) {
    if (nuevaCategoria.isNotEmpty) {
      context.read<AppBloc>().add(AgregarCategoria(categoriaAAgregar: nuevaCategoria));
      controlador.clear();
      Navigator.pop(context);
    }
  }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(onPressed: () {

        showDialog(
          context: context, 
          builder: (BuildContext context) => AlertDialog(
          title: const Text('Agregar Categoria'),
          content: TextFormField(
          controller: controlador,
          decoration: const InputDecoration(
          labelText: 'Categoria',
          icon: Icon(Icons.category_outlined),
          iconColor: Color.fromARGB(255, 57, 127, 136),
          labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
          enabledBorder: UnderlineInputBorder(
         borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
            )
            ),
          inputFormatters: [LengthLimitingTextInputFormatter(15)],
            ),
            actions: [
              TextButton(onPressed: () {
                Navigator.pop(context);
              }, 
              child: const Text('Cancelar')),
              TextButton(onPressed: () {
              final nuevaCategoria = controlador.text.trim().toUpperCase();
              agregarCategoria(nuevaCategoria);
              
              }, 
              child: const Text('Agregar'))
            ],
          )
          );
      }, 
      style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 57, 127, 136)),
        label: const Text('Agregar Categoria'),
        icon: const Icon(Icons.add),
      
      
      
      
      )

    );
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
  
  @override
   Widget build(BuildContext context) {

    void eliminarVehiculo(Vehiculo vehiculo) {
    context.read<AppBloc>().add(
                EliminarVehiculo(vehiculo: vehiculo));
                
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
     List<String> matriculas = [];
    List<Vehiculo> vehiculos = [];
    var estado = context.watch<AppBloc>().state;
    if(estado is Operacional) {
      vehiculos = (estado).listaVehiculos;
      for(Vehiculo vehiculo in vehiculos){
        matriculas.add(vehiculo.matricula);
      }
      }
    if(estado is Inicial) {
      return const Center(child: CircularProgressIndicator());
    }
    

    if(vehiculos.isEmpty){
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
    return Center(
      child: Column(
        children: [
          BlocBuilder<AppBloc, AppEstado>(   
          
            builder: (context, state) {
              
              if (state is Operacional) {
                return 
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.listaVehiculos.length,
                        itemBuilder: (context, index) {
                          
                          final vehiculo = state.listaVehiculos[index];

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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Vehiculo: ${vehiculo.matricula}'),
                                    ],
                                  ),
                                  content:
                                  SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      
                                      children: [

                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(Icons.branding_watermark_outlined, color: Color.fromARGB(255, 57, 127, 136),),
                                          ),
                                          Text('Marca', style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 57, 127, 136))),
                                        ],
                                      ),
                                    ),
                                    Text(vehiculo.marca, style: const TextStyle(fontSize: 20)),
                                    
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(Icons.numbers_outlined, color: Color.fromARGB(255, 57, 127, 136),),
                                          ),
                                          Text('Modelo', style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 57, 127, 136),)),
                                        ],
                                      ),
                                    ),
                                    Text(vehiculo.modelo.toString(), style: const TextStyle(fontSize: 20)),

                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(Icons.palette, color: Color.fromARGB(255, 57, 127, 136),),
                                          ),
                                          Text('Color', style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 57, 127, 136),)),
                                        ],
                                      ),
                                    ),
                                    Text(vehiculo.color, style: const TextStyle(fontSize: 20)),

                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(Icons.drive_eta, color: Color.fromARGB(255, 57, 127, 136),),
                                          ),
                                          Text('Matricula', style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 57, 127, 136))),
                                        ],
                                      ),
                                    ),
                                    Text(vehiculo.matricula, style: const TextStyle(fontSize: 20)),
                                    

                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(onPressed: () {
                                          final controladorMarca = TextEditingController(text: vehiculo.marca);
                                                  final controladorModelo = TextEditingController(text: vehiculo.modelo.toString());
                                                  final controladorColor = TextEditingController(text: vehiculo.color);
                                                  final controladorMatricula = TextEditingController(text: vehiculo.matricula);
                                                  
                                            
                                                  Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (BuildContext context) {
                                                      return Scaffold(
                                                        appBar: AppBar(
                                                          backgroundColor: const Color.fromARGB(255, 57, 127, 136),
                                                          title: const Text('Editar vehiculo'),
                                                        ),
                                                        body: Form(
                                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                                          key: _formKey,
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(16.0),
                                                            child: Column(
                                                              children: [
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
                                                                  controller: controladorMarca,
                                                                  decoration: const InputDecoration(
                                                                  labelText: 'Marca', 
                                                                  icon: Icon(Icons.branding_watermark_outlined),
                                                                  iconColor: Color.fromARGB(255, 57, 127, 136),
                                                                  labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                                                  enabledBorder: UnderlineInputBorder(
                                                                    borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
                                                                  ),
                                                                  focusedBorder: UnderlineInputBorder(
                                                                    borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
                                                                  )
                                                                  ),
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
                                                                    if(int.parse(value) < 1950 || int.parse(value) > 2025) {
                                                                      return 'Introduce un modelo valido';
                                                                    }
                                                          
                                                          
                                                          
                                                                      return null;
                                                                  },
                                                                  controller: controladorModelo,
                                                                  decoration: const InputDecoration(labelText: 'Modelo', icon: Icon(Icons.numbers_outlined), iconColor: Color.fromARGB(255, 57, 127, 136),
                                                                  labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                                                  enabledBorder: UnderlineInputBorder(
                                                                    borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
                                                                  ),
                                                                  focusedBorder: UnderlineInputBorder(
                                                                    borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
                                                                  )
                                                                  ),
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
                                                                  controller: controladorColor,
                                                                  decoration: const InputDecoration(labelText: 'Color', icon: Icon(Icons.palette), iconColor: Color.fromARGB(255, 57, 127, 136),
                                                                  labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                                                  enabledBorder: UnderlineInputBorder(
                                                                    borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
                                                                  ),
                                                                  focusedBorder: UnderlineInputBorder(
                                                                    borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
                                                                  )
                                                                  ),
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
                                                                    RegExp letterAndNumberRegExp = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]+$');
                                                                    if (!letterAndNumberRegExp.hasMatch(value)) {
                                                                      return 'Al menos una letra/numero';
                                                                    }
                                                                    if(matriculas.contains(value.toUpperCase()) && value.toUpperCase() != vehiculo.matricula){
                                                                      return 'Matricula existente';
                                                                    }
                                                          
                                                                      return null;
                                                                  },
                                                                  controller: controladorMatricula,
                                                                  decoration: const InputDecoration(labelText: 'Matrícula', icon: Icon(Icons.drive_eta), iconColor: Color.fromARGB(255, 57, 127, 136),
                                                                  labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                                                                  enabledBorder: UnderlineInputBorder(
                                                                    borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
                                                                  ),
                                                                  focusedBorder: UnderlineInputBorder(
                                                                    borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
                                                                  )
                                                                  ),
                                                                inputFormatters: [LengthLimitingTextInputFormatter(8)],
                                                              ),
                                                             
                                                                Padding(
                                                                  padding: const EdgeInsets.fromLTRB(0, 32, 0, 8),
                                                                  child: ElevatedButton(
                                                                  
                                                                  onPressed: () {
                                                                    if(_formKey.currentState!.validate()){
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
                                                                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 57, 127, 136)),
                                                                  child: const Text('Guardar'),
                                                                                                                              ),
                                                                ),
                                                              TextButton(
                                                                
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                },
                                                                
                                                                child: const Text('Cancelar', style: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),),
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
                                               style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color.fromARGB(255, 57, 127, 136), // Puedes cambiar el color según tus preferencias
                                                  ),
                                               child: const Row(
                                                 children: [
                                                   Icon(Icons.edit),
                                                   Text('Editar')
                                                 ],
                                               ),),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ElevatedButton(
                                              
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context, 
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                        content: const Text('¿Estás seguro de que quieres eliminar este vehículo? (Esto tambien eliminará los gastos)'),
                                                        actions: [
                                                           TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(context); // Cerrar el diálogo de confirmación
                                                            },
                                                            child: const Text('Cancelar', style: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              eliminarVehiculo(vehiculo);
                                                              Navigator.pop(context); // Cerrar el diálogo de confirmación
                                                              Navigator.pop(context); // Cerrar la pantalla actual
                                                              mostrarAdvertencia("Vehiculo eliminado correctamente");
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                                backgroundColor: const Color.fromARGB(255, 57, 127, 136), // Puedes cambiar el color según tus preferencias
                                                              ),        
                                                            child: const Text('Eliminar'),
                                                          ),
                                                        ],
                                          
                                                        );
                                          
                                                    });
                                          
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color.fromARGB(255, 57, 127, 136), // Puedes cambiar el color según tus preferencias
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

                                  )
                                  );
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

    if(estado is Operacional) {
      vehiculos = (estado).listaVehiculos;

      for(Vehiculo vehiculo in vehiculos){
        matriculas.add(vehiculo.matricula);
      }
      
    }

    


    void mostrarAdvertencia(String mensaje){
    final snackBar = SnackBar(
        content: Text(mensaje),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
    void agregarVehiculo(String marca, int modelo, String color, String matricula) {
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
              
              title: const Text('Agregar Vehículo', style: TextStyle(color:  Color.fromARGB(255, 57, 127, 136)),),
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
                            } ,
                            controller: _marcaController,
                            decoration: const InputDecoration(
                              labelText: 'Marca', 
                              icon: Icon(Icons.branding_watermark_outlined),
                              iconColor: Color.fromARGB(255, 57, 127, 136),
                              labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
                              )
                              ),
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
                              if(int.parse(value) < 1950 || int.parse(value) > 2025) {
                                return 'Introduce un modelo valido';
                              }



                                return null;
                            },
                            controller: _modeloController,
                            decoration: const InputDecoration(labelText: 'Modelo', icon: Icon(Icons.numbers_outlined), iconColor: Color.fromARGB(255, 57, 127, 136),
                              labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
                              )
                              ),
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
                            decoration: const InputDecoration(labelText: 'Color', icon: Icon(Icons.palette), iconColor: Color.fromARGB(255, 57, 127, 136),
                              labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
                              )
                              ),
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
                              RegExp letterAndNumberRegExp = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]+$');
                              if (!letterAndNumberRegExp.hasMatch(value)) {
                                return 'Al menos una letra/numero';
                              }
                              if(matriculas.contains(value.toUpperCase())){
                                return 'Matricula existente';
                              }

                                return null;
                            },
                            controller: _matriculaController,
                            decoration: const InputDecoration(labelText: 'Matrícula', icon: Icon(Icons.drive_eta), iconColor: Color.fromARGB(255, 57, 127, 136),
                              labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
                              )
                              ),
                            inputFormatters: [LengthLimitingTextInputFormatter(8)],
                          ),
                    
                          Padding(
                            padding: const EdgeInsets.only(top: 32.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 57, 127, 136)),
                              onPressed: () {
                                // Validate returns true if the form is valid, or false otherwise.
                                if (_formKey.currentState!.validate()) {
                          
                                    String marca = _marcaController.text;
                                    int modelo = int.tryParse(_modeloController.text) ?? 0;
                                    String color = _colorController.text;
                                    String matricula = _matriculaController.text;
                                            
                                    agregarVehiculo(marca.toUpperCase(), modelo, color.toUpperCase(), matricula.toUpperCase());
                          
                          
                                    _marcaController.clear();
                                    _colorController.clear();
                                    _matriculaController.clear();
                                    _modeloController.clear();
                                            
                                            
                                    // Cierra el AlertDialog
                                    Navigator.pop(context);
                                    mostrarAdvertencia("Vehiculo agregado correctamente");
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Processing Data')),
                                  );
                                }
                              },
                              child: const Text('Submit'),
                                    ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            
                            child: TextButton(
                              style: TextButton.styleFrom(foregroundColor: const Color.fromARGB(255, 57, 127, 136)),
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
        style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 57, 127, 136)),
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

  const FormularioVehiculo({super.key, required this.marcaController, required this.modeloController, required this.colorController, required this.matriculaController});

  @override
  State<FormularioVehiculo> createState() => _FormularioVehiculoState();
}

class _FormularioVehiculoState extends State<FormularioVehiculo> {
  final _formKey = GlobalKey<FormState>();

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
            } ,
            controller: widget.marcaController,
            decoration: const InputDecoration(
              labelText: 'Marca', 
              icon: Icon(Icons.branding_watermark_outlined),
              iconColor: Color.fromARGB(255, 57, 127, 136),
              labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
              )
              ),
            inputFormatters: [LengthLimitingTextInputFormatter(15)],
          ),
          TextFormField(
            controller: widget.modeloController,
            decoration: const InputDecoration(labelText: 'Modelo', icon: Icon(Icons.numbers_outlined), iconColor: Color.fromARGB(255, 57, 127, 136),
              labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
              )
              ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            
            ],
          ),
          TextFormField(
            controller: widget.colorController,
            decoration: const InputDecoration(labelText: 'Color', icon: Icon(Icons.palette), iconColor: Color.fromARGB(255, 57, 127, 136),
              labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
              )
              ),
            inputFormatters: [LengthLimitingTextInputFormatter(15)],
          ),
          TextFormField(
            controller: widget.matriculaController,
            decoration: const InputDecoration(labelText: 'Matrícula', icon: Icon(Icons.drive_eta), iconColor: Color.fromARGB(255, 57, 127, 136),
              labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
              )
              ),
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
    
                    agregarVehiculo(marca.toUpperCase(), modelo, color.toUpperCase(), matricula.toUpperCase());


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

  TextEditingController controladorFechaInicial = TextEditingController(text: '1950-01-01');
  TextEditingController controladorFechaFinal = TextEditingController(text: '2024-12-30');
  TextEditingController controladorCategoriaSeleccionada= TextEditingController(text: 'Todas las categorias');
  TextEditingController controladorVehiculoSeleccionado = TextEditingController(text: 'Todos los vehiculos');
  TextEditingController controladorLugar= TextEditingController(text: 'Todos los lugares');

  

  @override
  Widget build(BuildContext context) {
    void eliminarGasto(gastoId){
      context.read<AppBloc>().add(EliminarGasto(gastoId));
    }
    void editarGasto(Gasto gastoViejo, Gasto gastoNuevo){
      context.read<AppBloc>().add(EditarGasto(gastoViejo: gastoViejo, gastoNuevo: gastoNuevo));
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
    final Categoria todasLasCategorias = Categoria(nombre: 'all', categoria_id: 999);
    final Vehiculo todosLosVehiculos = Vehiculo(marca: "", modelo: 2012, vehiculo_id: 999, color: "azul", matricula: "", );
    final Gasto todosLosGastos = Gasto(descripcion: '', lugar: 'Todos los lugares', cantidad: 0, fecha: '1', categoria_id: 1, vehiculo_id: 1);

    var estado = context.watch<AppBloc>().state;

    if(estado is Operacional) {
      gastos = (estado).listaGastos;
      categorias = (estado).listaCategorias;
      vehiculos = (estado).listaVehiculos;
      gastosFiltrados = (estado).listaGastosFiltrados;
      
    }
    double cantidadGastada = calcularTotalGastado(gastosFiltrados);

    Categoria categoriaSeleccionada = todasLasCategorias;
    Vehiculo vehiculoSeleccionado = todosLosVehiculos;
    Gasto gastoSeleccionado = todosLosGastos;
    

    if(estado is Inicial){
      return const Center(child: CircularProgressIndicator());
    }
 
    
    void updateCategoriaSeleccionada(value){
    setState(() {
      
     categoriaSeleccionada = value;
     controladorCategoriaSeleccionada.text = (value as Categoria).categoria_id.toString();
     
     context.read<AppBloc>().add(
      FiltrarGasto(controladorFechaInicial.text, controladorFechaFinal.text, controladorCategoriaSeleccionada.text, controladorVehiculoSeleccionado.text, controladorLugar.text));

    });
  }
    void updateVehiculoSeleccionado(value){
    
    setState(() {
      vehiculoSeleccionado = value;
      controladorVehiculoSeleccionado.text = (value as Vehiculo).vehiculo_id.toString();
      
      context.read<AppBloc>().add(
      FiltrarGasto(controladorFechaInicial.text, controladorFechaFinal.text, controladorCategoriaSeleccionada.text, controladorVehiculoSeleccionado.text, controladorLugar.text));


    });
  }
     void updateLugarSeleccionado(value){
      setState(() {
        gastoSeleccionado = value;
        controladorLugar.text = (value as Gasto).lugar.toString();
        context.read<AppBloc>().add(
          FiltrarGasto(controladorFechaInicial.text, controladorFechaFinal.text, controladorCategoriaSeleccionada.text, controladorVehiculoSeleccionado.text, controladorLugar.text));
      });
    }
    
    return Column(
      children: [
          TextFormField(
            onTap: () async {
              DateTime? fechaSeleccionada = await showDatePicker(context: context,
               initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                 lastDate: DateTime.now()
                 );
                 setState(() {
                   if(fechaSeleccionada !=null){
                    String formattedDate =  DateFormat('yyyy-MM-dd').format(fechaSeleccionada);
                    controladorFechaInicial.text = formattedDate;

                    context.read<AppBloc>().add(
                    FiltrarGasto(controladorFechaInicial.text, controladorFechaFinal.text, controladorCategoriaSeleccionada.text, controladorVehiculoSeleccionado.text, controladorLugar.text));
                    
                    
                  }
                 });
            },
            controller: controladorFechaInicial,
            decoration: const InputDecoration(labelText: 'Fecha Inicial'),
            readOnly: true,
          ),
          TextFormField(
            onTap: () async {
              DateTime? fechaSeleccionada = await showDatePicker(context: context,
               initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                 lastDate: DateTime.now()
                 );
                 setState(() {
                   if(fechaSeleccionada !=null){
                    String formattedDate =  DateFormat('yyyy-MM-dd').format(fechaSeleccionada);
                    controladorFechaFinal.text = formattedDate;
                    context.read<AppBloc>().add(
                    FiltrarGasto(controladorFechaInicial.text, controladorFechaFinal.text, controladorCategoriaSeleccionada.text, controladorVehiculoSeleccionado.text, controladorLugar.text));
                    
                  }
                 });
            },
            controller: controladorFechaFinal,
            decoration: const InputDecoration(labelText: 'Fecha Final'),
          ),
          DropdownButtonFormField<Categoria>(
            decoration: const InputDecoration(labelText: 'Categoria'),
          value: categoriaSeleccionada,
          onChanged: (value) {
            
            updateCategoriaSeleccionada(value);
          },
          items: [
             DropdownMenuItem(
              value: todasLasCategorias,
              child: const Text('Todas las categorias'),
            ),
            ...categorias.map<DropdownMenuItem<Categoria>>((categoria) {
            return DropdownMenuItem<Categoria>(
              value: categoria,
              child: Text(categoria.nombre),
            );
          }).toList(),
      ]
        ),
          DropdownButtonFormField<Vehiculo>(
            decoration: const InputDecoration(labelText: 'Vehiculo'),
            value: vehiculoSeleccionado,
            onChanged: (value) {
              
              updateVehiculoSeleccionado(value);
              
            },
            items: [
              DropdownMenuItem(
                value: todosLosVehiculos,
                child: const Text("Todos los vehiculos"),
                ),
              ...vehiculos.map<DropdownMenuItem<Vehiculo>>((vehiculo) {
              return DropdownMenuItem<Vehiculo>(
                value: vehiculo,
                child: Text('${vehiculo.marca} ${vehiculo.matricula}'),
              );
            }).toList(),
            ]
          ),
          DropdownButtonFormField<Gasto>(
            decoration: const InputDecoration(labelText: 'Lugar'),
            value: gastoSeleccionado,
            onChanged: (value) {
              updateLugarSeleccionado(value);
            },
            items: [
            DropdownMenuItem(
            value: todosLosGastos,
            child: const Text('Todos los lugares'),
            ),
            ...gastos.map<DropdownMenuItem<Gasto>>((gasto) {
              return DropdownMenuItem<Gasto>(
                value: gasto,
                child: Text(gasto.lugar),
              );
            }).toList(),
            ]
          ),
          

        Expanded(
          child: SizedBox(
            //width: 500,
            height: 200,
            child: BlocBuilder<AppBloc, AppEstado>(
              builder: (context, state) {
                if(state is Operacional){
                  
                  if (state.listaGastosFiltrados.isEmpty) {
                    
                    return const Center(
                      child: Text('No hay gastos disponibles'),
                    );
                  }
                  
                  return 
                  ListView.builder(
                    itemCount: state.listaGastosFiltrados.length,
                    itemBuilder: (context, index) {
                      final gasto = state.listaGastosFiltrados[index];
                      final categorias = state.listaCategorias;
                      final vehiculos = state.listaVehiculos;
                  
                      
                    
                      print(estado);
                      late int x ;
                      for (var vehiculo in vehiculos) {
                        if(vehiculo.vehiculo_id == gasto.vehiculo_id){
                          x = vehiculos.indexOf(vehiculo);
                          break;
                        }
                      }
                      print(x);
                      
                      return ListTile(
                        title: Text('${vehiculos[x].marca.toString()} ${vehiculos[x].matricula.toString()} '),
                        subtitle: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(gasto.fecha.substring(0,10)),
                            Text(gasto.cantidad.toStringAsFixed(2)),
                          ],
                        ),
                        
                        onTap: () {
                          Categoria categoriaDelGasto = categorias[gasto.categoria_id];

                          Vehiculo vehiculoDelGasto = vehiculos[gasto.vehiculo_id];
                          
                          
                          
                          Navigator.push(context,
                          MaterialPageRoute(
                            builder: (BuildContext context){
                              return Scaffold(
                                  appBar: AppBar(
                                    title:  Text('Gasto: ${gasto.lugar}' ),
                                  ),
                                  body: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Categoria: ${categoriaDelGasto.nombre}', style: const TextStyle(fontSize: 20)),
                                      Text('Vehiculo: ${vehiculoDelGasto.marca} ${vehiculoDelGasto.matricula} ',style: const TextStyle(fontSize: 20)),
                                      Text('Descripcion: ${gasto.descripcion}', style: const TextStyle(fontSize: 20)),
                                      Text('Lugar: ${gasto.lugar}', style: const TextStyle(fontSize: 20)),
                                      Text('Cantidad: ${gasto.cantidad}', style: const TextStyle(fontSize: 20)),
                                      Text('Fecha: ${gasto.fecha.substring(0,10)}', style: const TextStyle(fontSize: 20)),
                                    ],
                                  ),
                                  floatingActionButton: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      FloatingActionButton(onPressed: () {
                                        eliminarGasto(gasto.gastoId);
                                      },
                                      tooltip: 'Borrar Gasto',
                                      child: const Icon(Icons.delete),
                                      ),
                                      const SizedBox(height: 16),
                                      FloatingActionButton(onPressed: () {
              
                                        final controladorVehiculoId = TextEditingController(text: gasto.vehiculo_id.toString()); 
                                        final controladorCategoriaId = TextEditingController(text: gasto.categoria_id.toString());
                                        final controladorDescripcion = TextEditingController(text: gasto.descripcion);
                                        final controladorLugar = TextEditingController(text: gasto.lugar);
                                        final controladorGasto = TextEditingController(text: gasto.cantidad.toString());
                                        final controladorFecha = TextEditingController(text: gasto.fecha);
              
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('Editar gasto'),
                                              content: Column(
                                                children: [
                                                  //TODO agregar widget de editar
                                                  TextFormField(
                                                    controller: controladorCategoriaId,
                                                    decoration: const InputDecoration(labelText: 'Categoria'),
                                                  ),
                                                  TextFormField(
                                                    controller: controladorDescripcion,
                                                    decoration: const InputDecoration(labelText: 'Descripcion'),
                                                  ),
                                                  TextFormField(
                                                    controller: controladorLugar,
                                                    decoration: const InputDecoration(labelText: 'Lugar'),
                                                  ),
                                                  TextFormField(
                                                    controller: controladorGasto,
                                                    decoration: const InputDecoration(labelText: 'Gasto'),
                                                  ),
                                                  TextFormField(
                                                    controller: controladorFecha,
                                                    decoration: const InputDecoration(labelText: 'Fecha'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          });
                                          
              
              
                                        
                                        
                                      })
                                      
                                    ],
                                  ),
                                );
                              }
                            )
                          );
                        },
                      );
                    },
                  );
                  
                }else{
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Valor: ${cantidadGastada.toStringAsFixed(2)}'),
        
        BotonAgregarGasto(),
      ],
      
    );
  }
}

class BotonAgregarGasto extends StatelessWidget {
  final TextEditingController vehiculoController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController lugarController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController fechaController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  final TextEditingController idCategoriaSeleccionada = TextEditingController(text: '1');
  final TextEditingController idVehiculoSeleccionado = TextEditingController(text: '1');

  
  BotonAgregarGasto({super.key});

  @override
  Widget build(BuildContext context) {
    

    void agregarGasto(String descripcion, String lugar, double cantidad, String fecha, int categoriaId, int vehiculoId){
      Gasto nuevoGasto = Gasto(descripcion: descripcion, lugar: lugar, cantidad: cantidad, fecha: fecha, categoria_id: categoriaId, vehiculo_id: vehiculoId);
      context.read<AppBloc>().add(AgregarGasto(gasto: nuevoGasto));
    }

    List<Categoria> categorias = [];
    List<Vehiculo> vehiculos = [];
    var estado = context.watch<AppBloc>().state;

    if(estado is Operacional) {
      categorias = (estado).listaCategorias;
      vehiculos = (estado.listaVehiculos);

    }

    final Categoria categoriaSeleccionada = categorias[0];
    final Vehiculo vehiculoSeleccionado = vehiculos[0];
    


    return ElevatedButton(
      onPressed: () {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Agregar Gasto'),
          content: FormularioGasto(
            vehiculoSeleccionado: vehiculoSeleccionado,
            descripcionController: descripcionController,
            lugarController: lugarController,
            cantidadController: cantidadController,
            fechaController: fechaController,
            categorias: categorias,
            vehiculos: vehiculos,
            categoriaSeleccionada: categoriaSeleccionada,
            idCategoriaSeleccionada: idCategoriaSeleccionada,
            idVehiculoSeleccionado: idVehiculoSeleccionado,
            ),
            actions: [
              TextButton(onPressed: () {
                Navigator.pop(context);
              }, 
              child: const Text('Cancelar')
              ),
              TextButton(onPressed: () {
                
                

                int categoriaId = int.parse(idCategoriaSeleccionada.text);
                int vehiculoId = int.parse(idVehiculoSeleccionado.text);
                String descripcion = descripcionController.text.toUpperCase();
                String lugar = lugarController.text.toUpperCase();
                double cantidad = double.parse(cantidadController.text);
                String fecha = DateTime.parse(fechaController.text).toString();
          
                agregarGasto(descripcion, lugar, cantidad, fecha, categoriaId , vehiculoId);

                
                vehiculoController.clear();
                descripcionController.clear();
                lugarController.clear();
                cantidadController.clear();
                fechaController.clear();

                Navigator.pop(context);

              },
               child: const Text('Guardar'))
            ],
          )
       );
    },
     child: const Text('Agregar Gasto'));
  }
}

class FormularioGasto extends StatefulWidget {
  
  final TextEditingController descripcionController;
  final TextEditingController lugarController;
  final TextEditingController cantidadController;
  final TextEditingController fechaController;
  final List<Categoria> categorias;
  final List<Vehiculo> vehiculos;
  final TextEditingController idCategoriaSeleccionada;
  final TextEditingController idVehiculoSeleccionado;

  Vehiculo? vehiculoSeleccionado;
  Object? categoriaSeleccionada;

   FormularioGasto({
    Key? key,
    required this.categorias,
    required this.vehiculos,
    required this.vehiculoSeleccionado,
    required this.descripcionController,
    required this.lugarController,
    required this.cantidadController,
    required this.fechaController,
    required this.categoriaSeleccionada,
    required this.idCategoriaSeleccionada,
    required this.idVehiculoSeleccionado,
  }) : super(key: key);

  @override
  _FormularioGastoState createState() => _FormularioGastoState();
}

class _FormularioGastoState extends State<FormularioGasto> {


  void _updateCategoriaSeleccionada(Object? value){
    setState(() {
     widget.categoriaSeleccionada = value;
     widget.idCategoriaSeleccionada.text = (value as Categoria).categoria_id.toString();
     
    });
  }

  void _updateVehiculoSeleccionado(Vehiculo? value){
    setState(() {
      widget.vehiculoSeleccionado = value;
      widget.idVehiculoSeleccionado.text = (value as Vehiculo).vehiculo_id.toString();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<Object>(
          decoration: const InputDecoration(
            labelText: 'Categoria', 
            icon: Icon(Icons.category_rounded),
            iconColor: Color.fromARGB(255, 57, 127, 136),
            labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
            )
            ),
          value: widget.categoriaSeleccionada,
          onChanged: (value) {
            _updateCategoriaSeleccionada(value);
          },
          items: widget.categorias.map<DropdownMenuItem<Object>>((Categoria categoria) {
            return DropdownMenuItem<Object>(
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
              borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
            )
            ),
          value: widget.vehiculoSeleccionado,
          onChanged: (value) {
            _updateVehiculoSeleccionado(value);
          },
          items: widget.vehiculos.map<DropdownMenuItem<Vehiculo>>((Vehiculo vehiculo) {
            return DropdownMenuItem<Vehiculo>(
              value: vehiculo,
              child: Text('${vehiculo.marca} ${vehiculo.matricula}'),
            );
          }).toList(),
        ),
        TextFormField(
          controller: widget.descripcionController,
          decoration: const InputDecoration(
            labelText: 'Descripcion',
            icon: Icon(Icons.description_rounded),
            iconColor: Color.fromARGB(255, 57, 127, 136),
            labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
            )
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(40)],
        ),
        TextFormField(
          controller: widget.lugarController,
          decoration: const InputDecoration(
            labelText: 'Lugar',
            icon: Icon(Icons.place),
            iconColor: Color.fromARGB(255, 57, 127, 136),
            labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
            )
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [LengthLimitingTextInputFormatter(8)]
        ),
        TextFormField(
          controller: widget.cantidadController,
          decoration: const InputDecoration(
            labelText: 'Cantidad',
            icon: Icon(Icons.attach_money_outlined),
            iconColor: Color.fromARGB(255, 57, 127, 136),
            labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
            )
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
              ],
        ),
        TextFormField(
          controller: widget.fechaController,
          decoration: const InputDecoration(
            icon: Icon(Icons.calendar_today),
            labelText: 'Fecha',
            iconColor: Color.fromARGB(255, 57, 127, 136),
            labelStyle: TextStyle(color: Color.fromARGB(255, 57, 127, 136)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 57, 127, 136))
            )
            ),
            
            readOnly: true,
            onTap: () async {
              
              DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1950),
              lastDate: DateTime(2101),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    primaryColor: const Color.fromARGB(255, 57, 127, 136), // Cambia el color principal
                    colorScheme: const ColorScheme.light(primary: Color.fromARGB(255, 57, 127, 136)),
                    buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                  ),
                  child: child!,
                );
              },
            );

              if (selectedDate != null) {
                String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
                widget.fechaController.text = formattedDate;
              }
              }, 
              keyboardType: TextInputType.datetime,
        ),
        
      ],
    );
  }
}

