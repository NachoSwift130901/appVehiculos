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
        body: const ListaCategorias(),
      ),
      
    );
  }
}

class ListaCategorias extends StatelessWidget {
  const ListaCategorias({super.key});

  @override
  Widget build(BuildContext context) {
    var estado = context.watch<AppBloc>().state;
    if(estado is Inicial) return const Text('Oh no');
    List<String> categorias = (estado as Operacional).listaCategorias;
    return SizedBox(
      width: 200,
      height: 600,
      child: ListView.builder(
        itemCount: categorias.length,
        itemBuilder:(context, index) {
          return TileCategoria(categoria: categorias[index],);
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
    return ListTile(
      title: Text(categoria),
    );
  }
}