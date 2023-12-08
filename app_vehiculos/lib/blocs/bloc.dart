// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: depend_on_referenced_packages, prefer_final_fields

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:app_vehiculos/modelos/categoria.dart';
import 'package:app_vehiculos/modelos/gastos.dart';
import 'package:app_vehiculos/modelos/vehiculo.dart';
// import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';


late Database db;
class RepositorioBD {
  

  Future<void> inicializar() async {
  
  var fabricaBaseDatos = databaseFactory;
  String rutaBaseDatos = '${await fabricaBaseDatos.getDatabasesPath()}/baseMovil2.db';
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
          modelo INTEGER NOT NULL,
          color TEXT NOT NULL,
          matricula TEXT NOT NULL
        );
      ''');

      await db.execute('''
        CREATE TABLE gastos (
          id INTEGER PRIMARY KEY,
          vehiculo_id INTEGER,
          categoria_id INTEGER,
          descripcion TEXT,
          lugar TEXT,
          cantidad REAL,
          fecha DATE,
          FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(id) ON DELETE CASCADE,
          FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE CASCADE

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
  final List<Categoria> listaCategorias;
  final List<Vehiculo> listaVehiculos;
  final List<Gasto> listaGastos;
  final List<Gasto> listaGastosFiltrados;

  Operacional({required this.listaCategorias, required this.listaVehiculos, required this.listaGastos, required this.listaGastosFiltrados});
  
  @override
  List<Object?> get props => [listaCategorias, listaVehiculos, listaGastos, listaGastosFiltrados];
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
  final Categoria categoriaAEliminar;

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
  final Vehiculo vehiculo;

  EliminarVehiculo({required this.vehiculo});
}

class ActualizarVehiculo extends AppEvento{
  final String matricula;
  final String marca;
  final String modelo;
  final String color;
  final String matriculaId;
  

  ActualizarVehiculo(this.matricula, this.marca, this.modelo, this.color, this.matriculaId);
}

//Gastos

class AgregarGasto extends AppEvento{
  final Gasto gasto;

  AgregarGasto({required this.gasto});
}

class EliminarGasto extends AppEvento{
  final int id;

  EliminarGasto(this.id);
}

class EditarGasto extends AppEvento{
  final Gasto gastoViejo;
  final Gasto gastoNuevo;

  EditarGasto({required this.gastoViejo, required this.gastoNuevo});
}

class FiltrarGasto extends AppEvento {
  final String fechaIncial;
  final String fechaFinal;
  final String categoriaId;
  final String vehiculoId;
  final String lugar;

  FiltrarGasto(this.fechaIncial, this.fechaFinal, this.categoriaId, this.vehiculoId, this.lugar);

}


/* ----------------------------------------*/

class AppBloc extends Bloc<AppEvento, AppEstado> {
  List<Categoria> _listaCategorias = [];
  List<Vehiculo> _listaVehiculos = [];
  List<Gasto> _listaGastos = [];
  List<Gasto> _listaGastosFiltrados = [];

  RepositorioBD repo = RepositorioBD();

  

  Future<void> todasLasCategorias() async {
    await repo.inicializar();
    var resultadoConsulta = await db.rawQuery("SELECT * FROM categorias");
    _listaCategorias = resultadoConsulta.map((e) => Categoria.fromMap(e)).toList();
  }
  Future<void> todosLosVehiculos() async{
    await repo.inicializar();
    var resultadoConsulta = await db.rawQuery("SELECT * FROM vehiculos ORDER BY marca ASC");
    _listaVehiculos = resultadoConsulta.map((e) => Vehiculo.fromMap(e)).toList();
  }
  Future<void> todosLosGastos() async{
    await repo.inicializar();
    var resultadoConsulta = await db.rawQuery("SELECT * FROM gastos");
    _listaGastos = resultadoConsulta.map((e) => Gasto.fromMap(e)).toList();
    

  }

  Future<void> agregarCategoria(categoriaAAgregar) async{
    await db.rawInsert('INSERT INTO categorias (categoria) VALUES(?)', [categoriaAAgregar]);  
    todasLasCategorias();
  }
  Future<void> eliminarCategoria(Categoria categoriaAEliminar) async{
    await db.rawDelete('DELETE FROM categorias where categoria = ?', [categoriaAEliminar.nombre]); 
    await db.rawDelete('DELETE FROM gastos WHERE categoria_id = ?', [categoriaAEliminar.categoria_id]);
  }
  Future<void> actualizarCategoria(oldCategoria, newCategoria) async {
    await db.rawUpdate('UPDATE categorias SET categoria = ? WHERE categoria = ?', [newCategoria, oldCategoria]);
  }
  
  Future<void> agregarVehiculo(String marca, int modelo, String color, String matricula) async{
    
    await db.rawInsert('''INSERT INTO vehiculos (marca, modelo, color, matricula) VALUES (?, ?, ?, ?) ''', [
      marca, modelo, color, matricula
    ]);
    await todosLosVehiculos();
  }
  Future<void> eliminarVehiculo(Vehiculo vehiculo) async {
    await db.rawDelete("DELETE FROM vehiculos WHERE matricula = ?", [vehiculo.matricula]);
    await db.rawDelete("DELETE from gastos WHERE vehiculo_id = ?", [vehiculo.vehiculo_id]);
    
  }
  Future<void> actualizarVehiculo(matricula, marca, int modelo, color, matriculaVieja) async {
    await db.rawUpdate("UPDATE vehiculos SET matricula = ?, modelo = ?, color = ?, marca = ? WHERE matricula = ?",
                        [matricula, modelo, color, marca, matriculaVieja]);
  }

  Future<void>agregarGasto(Gasto gasto) async{

    DateTime fechaNoFormateada = DateTime.parse(gasto.fecha);

    DateTime fechaSiFormateada = DateTime(fechaNoFormateada.year, fechaNoFormateada.month, fechaNoFormateada.day, 23, 59);
    String fechaFormateada = fechaSiFormateada.toString();
    
    await db.rawInsert('''INSERT INTO gastos (descripcion, lugar, cantidad, fecha, categoria_id, vehiculo_id) VALUES (?, ?, ?, ?, ?, ?)''',
                       [gasto.descripcion, gasto.lugar, gasto.cantidad, fechaFormateada, gasto.categoria_id, gasto.vehiculo_id]);
  }
  Future<void>eliminarGasto(id) async{
    
    await db.rawDelete("DELETE FROM gastos WHERE id = ?", [id]);
    await todosLosGastos();

  
  }
  Future<void>editarGasto(Gasto gastoViejo, Gasto gastoNuevo) async{
    await db.rawUpdate("UPDATE gastos SET vehiculo_id = ?, categoria_id = ?, descripcion = ?, lugar = ?, cantidad = ?, fecha = ? WHERE id = ?" ,
                      [gastoNuevo.vehiculo_id, gastoNuevo.categoria_id, gastoNuevo.descripcion, gastoNuevo.lugar, gastoNuevo.cantidad, gastoNuevo.fecha, gastoViejo.gastoId]);

    
  }

  Future<void> filtrarGasto(fechaInicial, fechaFinal ,categoriaId,vehiculoId, lugar) async {
    

    DateTime fechaNoFormateada = DateTime.parse(fechaFinal);

    DateTime fechaSiFormateada = DateTime(fechaNoFormateada.year, fechaNoFormateada.month, fechaNoFormateada.day, 23, 59);
    String fechaFormateada = fechaSiFormateada.toString();

    String condicionCategoria = ((categoriaId) == '999' || (categoriaId) == 'TODAS LAS CATEGORIAS')? '' : 'AND categoria_id = $categoriaId';
    
    String condicionVehiculo = ((vehiculoId) == '999' || (vehiculoId) == 'TODOS LOS VEHICULOS')? '' : 'AND vehiculo_id = $vehiculoId'; 

    String condicionLugar = (lugar == 'TODOS LOS LUGARES')? '' : 'AND lugar = \'$lugar\'';
    
    // String test= 'SELECT * FROM gastos WHERE fecha BETWEEN $fechaInicial AND $fechaFormateada $condicionCategoria $condicionVehiculo $condicionLugar';
    
    
    var resultadoConsulta = await db.rawQuery('SELECT * FROM gastos WHERE fecha BETWEEN ? AND ? $condicionCategoria $condicionVehiculo $condicionLugar',
    [fechaInicial, fechaFormateada]);

    
    
    
    _listaGastosFiltrados = resultadoConsulta.map((e) => Gasto.fromMap(e)).toList();
    
  
  }
 
  AppBloc() : super(Inicial()) {
    on<Inicializado>((event, emit) async{
      await todasLasCategorias();
      await todosLosGastos();
      await todosLosVehiculos();

      _listaGastosFiltrados = _listaGastos;
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos, listaGastos: _listaGastos, listaGastosFiltrados: _listaGastosFiltrados));
    });

    on<AgregarCategoria>((event, emit) async{
      agregarCategoria(event.categoriaAAgregar);
      await todasLasCategorias();
      
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos, listaGastos: _listaGastos, listaGastosFiltrados: _listaGastosFiltrados));
    });
    on<EliminarCategoria>((event, emit) async {
      await eliminarCategoria(event.categoriaAEliminar);
      await todasLasCategorias();
      await todosLosGastos();
      _listaGastosFiltrados = _listaGastos;
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos, listaGastos: _listaGastos, listaGastosFiltrados: _listaGastosFiltrados));
    });
    on<ActualizarCategoria>((event, emit) async {
      actualizarCategoria(event.oldCategoria, event.newCategoria);
      await todasLasCategorias();
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos, listaGastos: _listaGastos, listaGastosFiltrados: _listaGastosFiltrados));
    });

    on<AgregarVehiculo>((event, emit) async{
      await agregarVehiculo(event.marca, event.modelo, event.color, event.matricula);
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos, listaGastos: _listaGastos, listaGastosFiltrados: _listaGastosFiltrados));
    });
    on<EliminarVehiculo>((event, emit) async {
      await eliminarVehiculo(event.vehiculo);
      await todosLosVehiculos();
      await todosLosGastos();
      _listaGastosFiltrados = _listaGastos;


      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos, listaGastos: _listaGastos, listaGastosFiltrados: _listaGastosFiltrados));
    });
    on<ActualizarVehiculo>((event, emit) async {
      
      await actualizarVehiculo(event.matricula, event.marca, int.parse(event.modelo), event.color, event.matriculaId);
      await todosLosVehiculos();
      
      
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos, listaGastos: _listaGastos, listaGastosFiltrados: _listaGastosFiltrados));
    });

    on<AgregarGasto>((event, emit) async {
      await agregarGasto(event.gasto);
      await todosLosGastos();
      _listaGastosFiltrados = _listaGastos;

      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos, listaGastos: _listaGastos, listaGastosFiltrados: _listaGastosFiltrados));
    });
    on<EliminarGasto>((event, emit)async{
      await eliminarGasto(event.id);
      _listaGastosFiltrados = _listaGastos;
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos, listaGastos: _listaGastos, listaGastosFiltrados: _listaGastosFiltrados));
    });
    on<EditarGasto>((event, emit)async{
      await editarGasto(event.gastoViejo, event.gastoNuevo);
      await todosLosGastos();
      _listaGastosFiltrados = _listaGastos;
      
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos, listaGastos: _listaGastos, listaGastosFiltrados: _listaGastosFiltrados));
    });

    on<FiltrarGasto>((event, emit)async{
      await filtrarGasto(event.fechaIncial, event.fechaFinal, event.categoriaId, event.vehiculoId, event.lugar);
      
      emit(Operacional(listaCategorias: _listaCategorias, listaVehiculos: _listaVehiculos, listaGastos: _listaGastos, listaGastosFiltrados: _listaGastosFiltrados));
    });

  }
}

// final List<String> categorias = ['Encerado', 'Aceite', 'Aspirada'];
// final List<Vehiculo> vehiculos = [
//   Vehiculo(marca: 'Nissan', modelo: 2012, color: 'Azul', matricula: 'V2JS',categoria: 'Encerado',gastos: []),

// ];