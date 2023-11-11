import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/bloc.dart';


void main() {
  runApp(const AplicacionInyectada());
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
            ListaCategorias(),
            AgregarCategoriaWidget(),
          ],
        ),
      ),
      
    );
  }
}

/* Pantalla de categorias */

class ListaCategorias extends StatelessWidget {
  const ListaCategorias({super.key});

  @override
  Widget build(BuildContext context) {
    var estado = context.watch<AppBloc>().state;
    print(estado);
    if(estado is Inicial) return const Text('Oh no');
    List<String> categorias = (estado as Operacional).listaCategorias;
    return SizedBox(
      width: 200,
      height: 600,
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controlador,
              decoration: const InputDecoration(
                hintText: 'Nueva categoria',
              ),
            ),
          ),
          const SizedBox(width: 10,),
          ElevatedButton(onPressed: () {
            final nuevaCategoria = controlador.text.trim();
            if(nuevaCategoria.isNotEmpty) {
              context.read<AppBloc>().add(AgregarCategoria(categoriaAAgregar: nuevaCategoria));
              controlador.clear();
            }
          }, 
          child: const Text('Agrgar'),
          ),
        ],
      ),
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