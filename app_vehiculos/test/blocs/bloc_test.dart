import 'package:app_vehiculos/blocs/bloc.dart';
import 'package:app_vehiculos/modelos/categoria.dart';
import 'package:app_vehiculos/modelos/gastos.dart';
import 'package:app_vehiculos/modelos/vehiculo.dart';
import 'package:bloc_test/bloc_test.dart';

void main() {
  blocTest<AppBloc, AppEstado>(
    'Se inicializan las categorias',
    build: () => AppBloc(),
    act: (bloc) => bloc.add(Inicializado()),
    expect: () => <AppEstado>[Operacional(listaCategorias: [], listaVehiculos: [], listaGastos: [], listaGastosFiltrados: [])],
  );

  blocTest<AppBloc, AppEstado>(
    'Se agregan categorias',
    build: () => AppBloc(),
    act: (bloc) => [
      bloc.add(Inicializado()),
      bloc.add(AgregarCategoria(categoriaAAgregar: 'Repintada'))
    ],
    expect: () => [
      Operacional(
        listaCategorias: [], 
        listaVehiculos: [],
        listaGastos: [],
        listaGastosFiltrados: [],

      ),
      Operacional(
        listaCategorias: [Categoria(nombre: 'Repintada', categoria_id: 1)], 
        listaVehiculos: [],
        listaGastos: [],
        listaGastosFiltrados: [],
      ),
    ],
  );

  blocTest<AppBloc, AppEstado>(
    'Se eliminar categorias',
    build: () => AppBloc(),
    act: (bloc) => [
      bloc.add(Inicializado()),
      bloc.add(AgregarCategoria(categoriaAAgregar: 'Aceite')),
      bloc.add(EliminarCategoria(categoriaAEliminar: Categoria(nombre: 'Aceite', categoria_id: 1))),

    ],
    expect: () => [
      Operacional(
        listaCategorias: [], 
        listaVehiculos: [],
        listaGastos: [],
        listaGastosFiltrados: []
      ),
      Operacional(
        listaCategorias: [Categoria(nombre: 'Aceite', categoria_id: 1)], 
        listaVehiculos: [],
        listaGastos: [],
        listaGastosFiltrados: []
      ),
      Operacional(
        listaCategorias: [], 
        listaVehiculos: [],
        listaGastos: [],
        listaGastosFiltrados: []
      ),
    ],
  );

  blocTest<AppBloc, AppEstado>(
    'Se eliminar categorias',
    build: () => AppBloc(),
    act: (bloc) => [
      bloc.add(Inicializado()),
      bloc.add(AgregarCategoria(categoriaAAgregar: 'Repintada')),
      bloc.add(EliminarCategoria(categoriaAEliminar: Categoria(nombre: 'Repintada', categoria_id: 1))),

    ],
    expect: () => [
      Operacional(
        listaCategorias: [], 
        listaVehiculos: [],
        listaGastos: [],
        listaGastosFiltrados: [],
      ),
      Operacional(
        listaCategorias: [Categoria(nombre: 'Repintada', categoria_id: 1)], 
        listaVehiculos: [],
        listaGastos: [],
        listaGastosFiltrados: []

      ),
      Operacional(
        listaCategorias: [], 
        listaVehiculos: [],
        listaGastos: [],
        listaGastosFiltrados: []
      ),
    ],
  );

  blocTest<AppBloc, AppEstado>(
    'Se actualizan categorias',
    build: () => AppBloc(),
    act: (bloc) => [
      bloc.add(Inicializado()),
      bloc.add(AgregarCategoria(categoriaAAgregar: 'Repintada')),
      bloc.add(ActualizarCategoria(oldCategoria: 'Repintada', newCategoria: 'Limpieza')),

    ],
    expect: () => [
      Operacional(
        listaCategorias: [], 
        listaVehiculos: [],
        listaGastos: [],
        listaGastosFiltrados: [],
      ),
      Operacional(
        listaCategorias: [Categoria(nombre: 'Repintada', categoria_id: 1)], 
        listaVehiculos: [],
        listaGastos: [],
        listaGastosFiltrados: [],
      ),
      Operacional(
        listaCategorias: [Categoria(nombre: 'Limpieza', categoria_id: 1)], 
        listaVehiculos: [],
        listaGastos: [],
        listaGastosFiltrados: [],
      ),
    ],
  );

  blocTest<AppBloc, AppEstado>(
    'Se agregan vehiculos',
    build: () => AppBloc(),
    act: (bloc) => [
      bloc.add(Inicializado()),
      bloc.add(AgregarVehiculo(marca: 'Nissan', modelo: 2012, color: 'BLUE', matricula: 'SDK2J32')),

    ],
    expect: () => [
      Operacional(
        listaCategorias: [], 
        listaVehiculos: [
          Vehiculo(marca: 'Nissan', modelo: 2012, color: 'BLUE', matricula: 'SDK2J32')
          ],
        listaGastos: [],
        listaGastosFiltrados: []
      ),
    ],
  );

  blocTest<AppBloc, AppEstado>(
    'Se eliminan vehiculos',
    build: () => AppBloc(),
    act: (bloc) => [
      bloc.add(Inicializado()),
      bloc.add(AgregarVehiculo(marca: 'NISSAN', modelo: 2012, color: 'AZUL', matricula: 'SJDK23')),
      bloc.add(EliminarVehiculo(vehiculo: Vehiculo(marca: 'NISSAN', modelo: 2012, color: 'AZUL', matricula: 'SJDK23'))),
    ],
    expect: () => [
      Operacional(
        listaCategorias: [], 
        listaVehiculos: [ ],
        listaGastos: [],
        listaGastosFiltrados: [],
      ),
      Operacional(
        listaCategorias: [], 
        listaVehiculos: [Vehiculo(marca: 'NISSAN', modelo: 2012, color: 'AZUL', matricula: 'SJDK23')], 
        listaGastos: [], 
        listaGastosFiltrados: []
        ),
      Operacional(
        listaCategorias: [], 
        listaVehiculos: [], 
        listaGastos: [], 
        listaGastosFiltrados: []
        )
    ],
  );

  blocTest<AppBloc, AppEstado>(
    'Se actualizan vehiculos',
    build: () => AppBloc(),
    act: (bloc) => [
      bloc.add(Inicializado()),
      bloc.add(AgregarVehiculo(marca: 'NISSAN', modelo: 2012, color: 'AZUL', matricula: 'ABC123')),
      bloc.add(ActualizarVehiculo('ABC1234', 'CHEVROLET', 2015.toString(), 'AZUL', '1')),

    ],
    expect: () => [
      Operacional(
        listaCategorias: [], 
        listaVehiculos: [],
        listaGastos: [],
        listaGastosFiltrados: [],
      ),
      Operacional(
        listaCategorias: [], 
        listaVehiculos: [Vehiculo(marca: 'NISSAN', modelo: 2012, color: 'AZUL', matricula: 'ABC123')],
        listaGastos: [],
        listaGastosFiltrados: [],
      ),
      Operacional(
        listaCategorias: [], 
        listaVehiculos: [Vehiculo(marca: 'CHEVROLET', modelo: 2015, color: 'AZUL', matricula: 'ABC1234')],
        listaGastos: [],
        listaGastosFiltrados: [],
      ),
    ],
  );

  blocTest<AppBloc, AppEstado>(
    'Se agregan gastos',
    build: () => AppBloc(),
    act: (bloc) => [
      bloc.add(Inicializado()),
      bloc.add(AgregarGasto(gasto: Gasto(descripcion: 'ABC', lugar: 'ABC', cantidad: 1234, fecha: '2021-01-01', categoria_id: 1, vehiculo_id: 1)))
    ],
    expect: () => [
      Operacional(
        listaCategorias: [], 
        listaVehiculos: [],
        listaGastos: [],
        listaGastosFiltrados: [],
      ),
      Operacional(
        listaCategorias: [], 
        listaVehiculos: [],
        listaGastos: [ Gasto(descripcion: 'ABC', lugar: 'ABC', cantidad: 1234, fecha: '2021-01-01', categoria_id: 1, vehiculo_id: 1)],
        listaGastosFiltrados: [],
      ),

    ],
  );

  blocTest<AppBloc, AppEstado>(
    'Se eliminan gastos',
    build: () => AppBloc(),
    act: (bloc) => [
      bloc.add(Inicializado()),
      bloc.add(AgregarGasto(gasto: Gasto(descripcion: 'HOLA', lugar: 'AUTOZONE', cantidad: 1313, fecha: '2023-09-1', categoria_id: 1, vehiculo_id: 1))),
      bloc.add(EliminarGasto(1)),
    ],
    expect: () => [
      Operacional(
        listaCategorias: [], 
        listaVehiculos: [],
        listaGastos: [],
        listaGastosFiltrados: [],
      ),
    ],
  );
}