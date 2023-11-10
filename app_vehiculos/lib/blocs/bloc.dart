// ignore_for_file: depend_on_referenced_packages

import 'package:app_vehiculos/modelos/gastos.dart';
import 'package:app_vehiculos/modelos/vehiculo.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
  List<Object?> get props => [];
}
/* -------------- EVENTOS  ----------------*/

sealed class AppEvento {}

class Inicializado extends AppEvento {}


/* ----------------------------------------*/

class AppBloc extends Bloc<AppEvento, AppEstado> {
  List<String> _listaCategorias = [];
  List<Vehiculo> _listaVehiculos = [];
  List<Gastos> _listaGastos= [];

  

  AppBloc() : super(Inicial()) {
    on<Inicializado>((event, emit) {
      _listaCategorias = _listaCategorias..addAll(categorias);
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos, listaGastos: _listaGastos));
    });

  }
}

final List<String> categorias = ['Encerado, Cambio de aceite', 'Aspirada'];