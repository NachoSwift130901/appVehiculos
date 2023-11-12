import 'package:app_vehiculos/blocs/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

void main() {
  blocTest<AppBloc, AppEstado>(
    'Se inicializan las categorias',
    build: () => AppBloc(),
    act: (bloc) => bloc.add(Inicializado()),
    expect: () => <AppEstado>[Operacional(listaCategorias: categorias, listaVehiculos: [], listaGastos: [])],
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
        listaCategorias: ['Encerado', 'Aceite', 'Aspirada'], 
        listaVehiculos: [],
        listaGastos: []
      ),
      Operacional(
        listaCategorias: ['Encerado', 'Aceite', 'Aspirada','Repintada'], 
        listaVehiculos: [],
        listaGastos: []
      ),
    ],
  );

  blocTest<AppBloc, AppEstado>(
    'Se eliminar categorias',
    build: () => AppBloc(),
    act: (bloc) => [
      bloc.add(Inicializado()),
      bloc.add(AgregarCategoria(categoriaAAgregar: 'Repintada')),
      bloc.add(EliminarCategoria(categoriaAEliminar: 'Aceite')),

    ],
    expect: () => [
      Operacional(
        listaCategorias: ['Encerado', 'Aceite', 'Aspirada'], 
        listaVehiculos: [],
        listaGastos: []
      ),
      Operacional(
        listaCategorias: ['Encerado', 'Aceite', 'Aspirada','Repintada'], 
        listaVehiculos: [],
        listaGastos: []
      ),
      Operacional(
        listaCategorias: ['Encerado', 'Aspirada','Repintada'], 
        listaVehiculos: [],
        listaGastos: []
      ),
    ],
  );

  blocTest<AppBloc, AppEstado>(
    'Se eliminar categorias',
    build: () => AppBloc(),
    act: (bloc) => [
      bloc.add(Inicializado()),
      bloc.add(AgregarCategoria(categoriaAAgregar: 'Repintada')),
      bloc.add(EliminarCategoria(categoriaAEliminar: 'Aceite')),

    ],
    expect: () => [
      Operacional(
        listaCategorias: ['Encerado', 'Aceite', 'Aspirada'], 
        listaVehiculos: [],
        listaGastos: []
      ),
      Operacional(
        listaCategorias: ['Encerado', 'Aceite', 'Aspirada','Repintada'], 
        listaVehiculos: [],
        listaGastos: []
      ),
      Operacional(
        listaCategorias: ['Encerado', 'Aspirada','Repintada'], 
        listaVehiculos: [],
        listaGastos: []
      ),
    ],
  );

  blocTest<AppBloc, AppEstado>(
    'Se actualizan categorias',
    build: () => AppBloc(),
    act: (bloc) => [
      bloc.add(Inicializado()),
      bloc.add(AgregarCategoria(categoriaAAgregar: 'Repintada')),
      bloc.add(EliminarCategoria(categoriaAEliminar: 'Aceite')),
      bloc.add(ActualizarCategoria(oldCategoria: 'Aspirada', newCategoria: 'Limpieza')),

    ],
    expect: () => [
      Operacional(
        listaCategorias: ['Encerado', 'Aceite', 'Aspirada'], 
        listaVehiculos: [],
        listaGastos: []
      ),
      Operacional(
        listaCategorias: ['Encerado', 'Aceite', 'Aspirada','Repintada'], 
        listaVehiculos: [],
        listaGastos: []
      ),
      Operacional(
        listaCategorias: ['Encerado', 'Aspirada','Repintada'], 
        listaVehiculos: [],
        listaGastos: []
      ),
      Operacional(
        listaCategorias: ['Encerado', 'Limpieza','Repintada'], 
        listaVehiculos: [],
        listaGastos: []
      ),
    ],
  );




}