import 'package:app_vehiculos/blocs/bloc.dart';
import 'package:app_vehiculos/modelos/vehiculo.dart';
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

  blocTest<AppBloc, AppEstado>(
    'Se agregan vehiculos',
    build: () => AppBloc(),
    act: (bloc) => [
      bloc.add(Inicializado()),
      bloc.add(AgregarVehiculo(vehiculoAAgregar: Vehiculo(marca: 'Tesla', modelo: 2012, color: 'Blanco', matricula: 'LOI23', categoria: 'Aspirada'))),

    ],
    expect: () => [
      Operacional(
        listaCategorias: ['Encerado', 'Aceite', 'Aspirada'], 
        listaVehiculos: [
          Vehiculo(marca: 'Nissan', modelo: 2012, color: 'Azul', matricula: 'V2JS',categoria: 'Encerado'),
          Vehiculo(marca: 'Chevron', modelo: 2032, color: 'Amarillo', matricula: 'V3GI', categoria: 'Encerado'),
          Vehiculo(marca: 'Testla', modelo: 2001, color: 'Rojo', matricula: 'P9JS', categoria: 'Encerado'),
          Vehiculo(marca: 'Tesla', modelo: 2012, color: 'Blanco', matricula: 'LOI23', categoria: 'Aspirada'),
          ],
        listaGastos: []
      ),
    ],
  );

  blocTest<AppBloc, AppEstado>(
    'Se eliminan vehiculos',
    build: () => AppBloc(),
    act: (bloc) => [
      bloc.add(Inicializado()),
      bloc.add(AgregarVehiculo(vehiculoAAgregar: Vehiculo(marca: 'Tesla', modelo: 2012, color: 'Blanco', matricula: 'LOI23', categoria: 'Aspirada'))),
      bloc.add(EliminarVehiculo(vehiculoAEliminar: Vehiculo(marca: 'Chevron', modelo: 2032, color: 'Amarillo', matricula: 'V3GI', categoria: 'Encerado'))),
      bloc.add(EliminarVehiculo(vehiculoAEliminar: Vehiculo(marca: 'Nissan', modelo: 2012, color: 'Azul', matricula: 'V2JS',categoria: 'Encerado'))),

    ],
    expect: () => [
      Operacional(
        listaCategorias: ['Encerado', 'Aceite', 'Aspirada'], 
        listaVehiculos: [
          Vehiculo(marca: 'Testla', modelo: 2001, color: 'Rojo', matricula: 'P9JS', categoria: 'Encerado'),
          Vehiculo(marca: 'Tesla', modelo: 2012, color: 'Blanco', matricula: 'LOI23', categoria: 'Aspirada'),
          ],
        listaGastos: []
      ),
    ],
  );

  blocTest<AppBloc, AppEstado>(
    'Se actualizan vehiculos',
    build: () => AppBloc(),
    act: (bloc) => [
      bloc.add(Inicializado()),
      bloc.add(AgregarVehiculo(vehiculoAAgregar: Vehiculo(marca: 'Tesla', modelo: 2012, color: 'Blanco', matricula: 'LOI23', categoria: 'Aspirada'))),
      bloc.add(EliminarVehiculo(vehiculoAEliminar: Vehiculo(marca: 'Chevron', modelo: 2032, color: 'Amarillo', matricula: 'V3GI', categoria: 'Encerado'))),
      bloc.add(EliminarVehiculo(vehiculoAEliminar: Vehiculo(marca: 'Nissan', modelo: 2012, color: 'Azul', matricula: 'V2JS',categoria: 'Encerado'))),
      bloc.add(ActualizarVehiculo(
        vehiculoAnterior: Vehiculo(marca: 'Testla', modelo: 2001, color: 'Rojo', matricula: 'P9JS', categoria: 'Encerado'), 
        vehiculoActualizado: Vehiculo(marca: 'Tesla', modelo: 2001, color: 'Arcoiris', matricula: 'P9JS', categoria: 'Encerado'))
      ),

    ],
    expect: () => [
      Operacional(
        listaCategorias: ['Encerado', 'Aceite', 'Aspirada'], 
        listaVehiculos: [
          Vehiculo(marca: 'Testla', modelo: 2001, color: 'Rojo', matricula: 'P9JS', categoria: 'Encerado'),
          Vehiculo(marca: 'Tesla', modelo: 2012, color: 'Blanco', matricula: 'LOI23', categoria: 'Aspirada'),
          ],
        listaGastos: []
      ),
    ],
  );


}