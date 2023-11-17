// ignore_for_file: depend_on_referenced_packages, prefer_final_fields

import 'package:app_vehiculos/modelos/gastos.dart';
import 'package:app_vehiculos/modelos/vehiculo.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';




late Database db;
class RepositorioBD {
  RepositorioBD();

  Future<void> inicializar() async {
  var fabricaBaseDatos = databaseFactoryFfiWeb;
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
          matricula TEXT NOT NULL
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

  Operacional({required this.listaCategorias, required this.listaVehiculos});
  
  @override
  List<Object?> get props => [listaCategorias];
}

/* -------------- EVENTOS  ----------------*/

sealed class AppEvento {}

class Inicializado extends AppEvento {}

//Categorias

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

//Vehiculos

class AgregarVehiculo extends AppEvento{
  final String marca;
  final int modelo;
  final String color;
  final String matricula;

  AgregarVehiculo({required this.marca, required this.modelo, required this.color, required this.matricula});

  
}

class EliminarVehiculo extends AppEvento{
  final Vehiculo vehiculoAEliminar;

  EliminarVehiculo({required this.vehiculoAEliminar});
}

class ActualizarVehiculo extends AppEvento{
  final Vehiculo vehiculoAnterior;
  final Vehiculo vehiculoActualizado;

  ActualizarVehiculo({required this.vehiculoAnterior, required this.vehiculoActualizado});
}

//Gastos

class AgregarGasto extends AppEvento{
  final String placaVehiculo;
  final Gasto gastoAAgregar;

  AgregarGasto(this.placaVehiculo, this.gastoAAgregar);

}

class EliminarGasto extends AppEvento{
  final String placaVehiculo;
  final String gastoAEliminar;

  EliminarGasto(this.placaVehiculo, this.gastoAEliminar);
}
/* ----------------------------------------*/

class AppBloc extends Bloc<AppEvento, AppEstado> {
  List<String> _listaCategorias = [];
  List<Vehiculo> _listaVehiculos = [];

  RepositorioBD repo = RepositorioBD();
  

  Future<void> todasLasCategorias() async {
    await repo.inicializar();
    var resultadoConsulta = await db.rawQuery("SELECT categoria FROM categorias");
    _listaCategorias = resultadoConsulta.map((e) => e['categoria'] as String).toList();
  }

  Future<void> todosLosVehiculos() async{
    await repo.inicializar();
    var resultadoConsulta = await db.rawQuery("SELECT * FROM vehiculos");
    _listaVehiculos = resultadoConsulta.map((e) => Vehiculo.fromMap(e)).toList();
  }

  Future<void> todosLosGastos() async{
    await repo.inicializar();
    var resultadoConsulta = await db.rawQuery("SELECT * FROM gastos");

  }

  void agregarCategoria(categoriaAAgregar) async{
    await db.rawInsert('INSERT INTO categorias (categoria) VALUES(?)', [categoriaAAgregar]);  
    todasLasCategorias();
  }
  Future<void>eliminarCategoria(categoriaAEliminar) async{
    await db.rawDelete('DELETE FROM categorias where categoria = ?', [categoriaAEliminar]); 
  }
  Future<void> actualizarCategoria(oldCategoria, newCategoria) async {
    await db.rawUpdate('UPDATE categorias SET categoria = ? WHERE categoria = ?', [newCategoria, oldCategoria]);

  }
  
  void agregarVehiculo(String marca, int modelo, String color, String matricula) async{
    await db.rawInsert(''''"INSEERT INTO vehiculos (marca, modelo, color, matricula) VALUES (?, ?, ?, ?) ''', [
      marca, modelo, color, matricula
    ]);
    todosLosVehiculos();
  }
  void eliminarVehiculo(vehiculoAEliminar) {
    _listaVehiculos = _listaVehiculos.toList()..remove(vehiculoAEliminar);
  }
  void actualizarVehiculo(vehiculoAnterior, vehiculoActualizado){
    final index = _listaVehiculos.indexOf(vehiculoAnterior);

    _listaVehiculos = _listaVehiculos.toList()..remove(vehiculoAnterior);
    _listaVehiculos.insert(index, vehiculoActualizado);
  }

  void agregarGasto(placaVehiculo, gastoAAgregar){
  final vehiculoEnLista = _listaVehiculos.firstWhere((v) => v.matricula == placaVehiculo);

  // vehiculoEnLista.gastos.add(gastoAAgregar);
    
  }
  void eliminarGasto(placaVehiculo, gastoAEliminar){
    final vehiculoEnLista = _listaVehiculos.firstWhere((v) => v.matricula == placaVehiculo);

  // vehiculoEnLista.gastos.remove(gastoAEliminar);
  }
  
  AppBloc() : super(Inicial()) {
    on<Inicializado>((event, emit) async{
      await todasLasCategorias();
      await todosLosVehiculos();
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos));
    });

    on<AgregarCategoria>((event, emit) async{
      agregarCategoria(event.categoriaAAgregar);
      await todasLasCategorias();
      
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos));
    });
    on<EliminarCategoria>((event, emit) async {
      await eliminarCategoria(event.categoriaAEliminar);
      await todasLasCategorias();
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos));
    });
    on<ActualizarCategoria>((event, emit) async {
      actualizarCategoria(event.oldCategoria, event.newCategoria);
      await todasLasCategorias();
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos));
    });

    on<AgregarVehiculo>((event, emit){
      // agregarVehiculo(event.vehiculoAAgregar);
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos));
    });
    on<EliminarVehiculo>((event, emit){
      // agregarVehiculo(event.vehiculoAEliminar);
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos));
    });
    on<ActualizarVehiculo>((event, emit){
      actualizarVehiculo(event.vehiculoAnterior, event.vehiculoActualizado);
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos));
    });

    on<AgregarGasto>((event, emit){
      agregarGasto(event.placaVehiculo, event.gastoAAgregar);
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos));
    });
    on<EliminarGasto>((event, emit){
      agregarGasto(event.placaVehiculo, event.gastoAEliminar);
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos));
    });

  }
}

// final List<String> categorias = ['Encerado', 'Aceite', 'Aspirada'];
// final List<Vehiculo> vehiculos = [
//   Vehiculo(marca: 'Nissan', modelo: 2012, color: 'Azul', matricula: 'V2JS',categoria: 'Encerado',gastos: []),

// ];