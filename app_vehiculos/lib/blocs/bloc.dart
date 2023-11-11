// ignore_for_file: depend_on_referenced_packages, prefer_final_fields

import 'package:app_vehiculos/modelos/gastos.dart';
import 'package:app_vehiculos/modelos/vehiculo.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_vehiculos/extensiones/extensiones.dart';
late Database db;

class RepositorioBD {
  RepositorioBD();

  void inicializar() async {
  var fabricaBaseDatos = databaseFactoryFfi;
  String rutaBaseDatos = '${await fabricaBaseDatos.getDatabasesPath()}/base.db';
  db = await fabricaBaseDatos.openDatabase(rutaBaseDatos,
  options: OpenDatabaseOptions(
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE categorias (
          id INTEGER PRIMARY KEY,
          categoria TEXT NOT NULL
        );
      ''');

      await db.execute('''
        CREATE TABLE vehiculos (
          id INTEGER PRIMARY KEY,
          marca TEXT NOT NULL,
          modelo TEXT NOT NULL,
          color TEXT NOT NULL,
          matricula TEXT NOT NULL,
          categoria TEXT NOT NULL,
          FOREIGN KEY (categoria) REFERENCES categorias(categoria)
        );
      ''');

      await db.execute('''
        CREATE TABLE gastos (
          id INTEGER PRIMARY KEY,
          vehiculo_id INTEGER,
          descripcion TEXT,
          lugar TEXT,
          cantidad REAL,
          fecha TEXT,
          FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(id)
        );
      ''');
    }
    ));
  } 

  Future<List<String>> obtenerCategorias() async {
    var resultadoConsulta = await db.rawQuery("Select categoria from categorias");
    return resultadoConsulta.map((e) => e['categoria'] as String).toList();

  }



}



/* -------------- ESTADOS -----------------*/

sealed class AppEstado with EquatableMixin{}

class Inicial extends AppEstado{
  @override
  List<Object?> get props => [];

}

class Operacional extends AppEstado{
  final List<String> listaCategorias;
  final List<Vehiculo> listaVehiculos;
  final List<Gastos> listaGastos;

  Operacional({required this.listaCategorias, required this.listaVehiculos, required this.listaGastos});
  
  @override
  List<Object?> get props => [listaCategorias];
}

/* -------------- EVENTOS  ----------------*/

sealed class AppEvento {}

class Inicializado extends AppEvento {}

class AgregarCategoria extends AppEvento{
  final String categoriaAAgregar;

  AgregarCategoria({required this.categoriaAAgregar});
}

class EliminarCategoria extends AppEvento{
  final String categoriaAEliminar;

  EliminarCategoria({required this.categoriaAEliminar});
}

class ActualizarCategoria extends AppEvento{
  final String oldCategoria;
  final String newCategoria;

  ActualizarCategoria({required this.oldCategoria, required this.newCategoria});
}






/* ----------------------------------------*/

class AppBloc extends Bloc<AppEvento, AppEstado> {
  List<String> _listaCategorias = [];
  List<Vehiculo> _listaVehiculos = [];
  List<Gastos> _listaGastos= [];

  void agregarCategoria(categoriaAAgregar){
    _listaCategorias = _listaCategorias.toList()..add(categoriaAAgregar);
  }
  void eliminarCategoria(categoriaAEliminar){
    
    _listaCategorias = _listaCategorias.toList()..remove(categoriaAEliminar);    
    
  }
  void actualizarCategoria(oldCategoria, newCategoria){
    final index = _listaCategorias.indexOf(oldCategoria);

    _listaCategorias = _listaCategorias.toList()..remove(oldCategoria);
    _listaCategorias.insert(index, newCategoria);

  }
  
  AppBloc() : super(Inicial()) {
    on<Inicializado>((event, emit) {
      _listaCategorias = _listaCategorias..addAll(categorias);
      _listaVehiculos = _listaVehiculos..addAll(vehiculos);
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos, listaGastos: _listaGastos));
    });

    on<AgregarCategoria>((event, emit){
      agregarCategoria(event.categoriaAAgregar);
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos, listaGastos: _listaGastos));
    });
    
    on<EliminarCategoria>((event, emit){
      eliminarCategoria(event.categoriaAEliminar);
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos, listaGastos: _listaGastos));
    });

    on<ActualizarCategoria>((event, emit){
      actualizarCategoria(event.oldCategoria, event.newCategoria);
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos, listaGastos: _listaGastos));
    });

    


  }
}

final List<String> categorias = ['Encerado', 'Aceite', 'Aspirada'];
final List<Vehiculo> vehiculos = [
  Vehiculo(marca: 'Nissan', modelo: 2012, color: 'Azul', matricula: 'V2JS',categoria: 'Encerado'),
  Vehiculo(marca: 'Chevron', modelo: 2032, color: 'Amarillo', matricula: 'V3GI', categoria: 'Encerado'),
  Vehiculo(marca: 'Testla', modelo: 2001, color: 'Rojo', matricula: 'P9JS', categoria: 'Encerado'),

];