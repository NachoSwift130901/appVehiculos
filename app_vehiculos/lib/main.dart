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
          return TileCategoria(categoria: categorias[index]);
        },
      ),
    );
  }
}

class TileCategoria extends StatelessWidget {


  final String categoria;

  const TileCategoria({super.key, required this.categoria});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoria,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
            context.read<AppBloc>().add(EliminarCategoria(categoriaAEliminar: categoria));
            
          }, 
          ),
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