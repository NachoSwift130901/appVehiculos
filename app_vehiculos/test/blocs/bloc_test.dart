import 'package:app_vehiculos/blocs/bloc.dart';
import 'package:app_vehiculos/modelos/gastos.dart';
import 'package:app_vehiculos/modelos/vehiculo.dart';
import 'package:bloc_test/bloc_test.dart';

void main() {
  blocTest<AppBloc, AppEstado>(
    'Se inicializan las categorias',
    build: () => AppBloc(),
    act: (bloc) => bloc.add(Inicializado()),
    expect: () => <AppEstado>[Operacional(listaCategorias: [], listaVehiculos: [], listaGastos: [])],
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
        listaGastos: [],

      ),
      Operacional(
        listaCategorias: ['Encerado', 'Aceite', 'Aspirada','Repintada'], 
        listaVehiculos: [],
        listaGastos: [],
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
        listaGastos: [],
      ),
      Operacional(
        listaCategorias: ['Encerado', 'Aceite', 'Aspirada','Repintada'], 
        listaVehiculos: [],
        listaGastos: [],
      ),
      Operacional(
        listaCategorias: ['Encerado', 'Aspirada','Repintada'], 
        listaVehiculos: [],
        listaGastos: [],
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
        listaGastos: [],
      ),
      Operacional(
        listaCategorias: ['Encerado', 'Aceite', 'Aspirada','Repintada'], 
        listaVehiculos: [],
        listaGastos: [],

      ),
      Operacional(
        listaCategorias: ['Encerado', 'Aspirada','Repintada'], 
        listaVehiculos: [],
        listaGastos: [],
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
        listaGastos: [],
      ),
      Operacional(
        listaCategorias: ['Encerado', 'Aceite', 'Aspirada','Repintada'], 
        listaVehiculos: [],
        listaGastos: [],
      ),
      Operacional(
        listaCategorias: ['Encerado', 'Aspirada','Repintada'], 
        listaVehiculos: [],
        listaGastos: [],
      ),
      Operacional(
        listaCategorias: ['Encerado', 'Limpieza','Repintada'], 
        listaVehiculos: [],
        listaGastos: [],
      ),
    ],
  );

  blocTest<AppBloc, AppEstado>(
    'Se agregan vehiculos',
    build: () => AppBloc(),
    act: (bloc) => [
      bloc.add(Inicializado()),
      bloc.add(AgregarVehiculo(vehiculoAAgregar: Vehiculo(marca: 'Tesla', modelo: 2012, color: 'Blanco', matricula: 'LOI23', categoria: 'Aspirada', gastos: [],))),

    ],
    expect: () => [
      Operacional(
        listaCategorias: ['Encerado', 'Aceite', 'Aspirada'], 
        listaVehiculos: [
          Vehiculo(marca: 'Nissan', modelo: 2012, color: 'Azul', matricula: 'V2JS',categoria: 'Encerado', gastos: []),
          Vehiculo(marca: 'Chevron', modelo: 2032, color: 'Amarillo', matricula: 'V3GI', categoria: 'Encerado', gastos: []),
          Vehiculo(marca: 'Testla', modelo: 2001, color: 'Rojo', matricula: 'P9JS', categoria: 'Encerado', gastos: []),
          Vehiculo(marca: 'Tesla', modelo: 2012, color: 'Blanco', matricula: 'LOI23', categoria: 'Aspirada', gastos: []),
          ],
      ),
    ],
  );

  blocTest<AppBloc, AppEstado>(
    'Se eliminan vehiculos',
    build: () => AppBloc(),
    act: (bloc) => [
      bloc.add(Inicializado()),
      bloc.add(AgregarVehiculo(vehiculoAAgregar: Vehiculo(marca: 'Tesla', modelo: 2012, color: 'Blanco', matricula: 'LOI23', categoria: 'Aspirada', gastos: []))),
      bloc.add(EliminarVehiculo(vehiculoAEliminar: Vehiculo(marca: 'Chevron', modelo: 2032, color: 'Amarillo', matricula: 'V3GI', categoria: 'Encerado', gastos: []))),
      bloc.add(EliminarVehiculo(vehiculoAEliminar: Vehiculo(marca: 'Nissan', modelo: 2012, color: 'Azul', matricula: 'V2JS',categoria: 'Encerado', gastos: []))),

    ],
    expect: () => [
      Operacional(
        listaCategorias: ['Encerado', 'Aceite', 'Aspirada'], 
        listaVehiculos: [
          Vehiculo(marca: 'Testla', modelo: 2001, color: 'Rojo', matricula: 'P9JS', categoria: 'Encerado', gastos: []),
          Vehiculo(marca: 'Tesla', modelo: 2012, color: 'Blanco', matricula: 'LOI23', categoria: 'Aspirada', gastos: []),
          ],
      ),
    ],
  );

  blocTest<AppBloc, AppEstado>(
    'Se actualizan vehiculos',
    build: () => AppBloc(),
    act: (bloc) => [
      bloc.add(Inicializado()),
      bloc.add(AgregarVehiculo(vehiculoAAgregar: Vehiculo(marca: 'Tesla', modelo: 2012, color: 'Blanco', matricula: 'LOI23', categoria: 'Aspirada', gastos: []))),
      bloc.add(EliminarVehiculo(vehiculoAEliminar: Vehiculo(marca: 'Chevron', modelo: 2032, color: 'Amarillo', matricula: 'V3GI', categoria: 'Encerado', gastos: []))),
      bloc.add(EliminarVehiculo(vehiculoAEliminar: Vehiculo(marca: 'Nissan', modelo: 2012, color: 'Azul', matricula: 'V2JS',categoria: 'Encerado', gastos: []))),
      bloc.add(ActualizarVehiculo(
        vehiculoAnterior: Vehiculo(marca: 'Testla', modelo: 2001, color: 'Rojo', matricula: 'P9JS', categoria: 'Encerado', gastos: []), 
        vehiculoActualizado: Vehiculo(marca: 'Tesla', modelo: 2001, color: 'Arcoiris', matricula: 'P9JS', categoria: 'Encerado', gastos: []))
      ),

    ],
    expect: () => [
      Operacional(
        listaCategorias: ['Encerado', 'Aceite', 'Aspirada'], 
        listaVehiculos: [
          Vehiculo(marca: 'Testla', modelo: 2001, color: 'Rojo', matricula: 'P9JS', categoria: 'Encerado', gastos: []),
          Vehiculo(marca: 'Tesla', modelo: 2012, color: 'Blanco', matricula: 'LOI23', categoria: 'Aspirada', gastos: []),
          ],
      ),
    ],
  );

  blocTest<AppBloc, AppEstado>(
    'Se agregan gastos',
    build: () => AppBloc(),
    act: (bloc) => [
      bloc.add(Inicializado()),
      bloc.add(AgregarGasto('V2JS', Gasto(descripcion: 'Se le hizo una encerada a la puerta', lugar: 'Taller chuy', cantidad: 750.99, fecha: DateTime(2023,9,13))))
    ],
    expect: () => [
      Operacional(
        listaCategorias: ['Encerado', 'Aceite', 'Aspirada'], 
        listaVehiculos: [
        Vehiculo(marca: 'Nissan', modelo: 2012, color: 'Azul', matricula: 'V2JS',categoria: 'Encerado', gastos: [Gasto(descripcion: 'Se le hizo una encerada a la puerta', lugar: 'Taller chuy', cantidad: 750.99, fecha: DateTime(2023, 9, 13))]),     
        ],
      ),
    ],
  );

  blocTest<AppBloc, AppEstado>(
    'Se eliminan gastos',
    build: () => AppBloc(),
    act: (bloc) => [
      bloc.add(Inicializado()),
      bloc.add(AgregarGasto('V2JS', Gasto(descripcion: 'Se le hizo una encerada a la puerta', lugar: 'Taller chuy', cantidad: 750.99, fecha: DateTime(2023,9,13)))),
      bloc.add(AgregarGasto('V2JS', Gasto(descripcion: 'Se le hizo una encerada a la puerta', lugar: 'Taller chuy', cantidad: 750.99, fecha: DateTime(2023,9,13)))),
    ],
    expect: () => [
      Operacional(
        listaCategorias: ['Encerado', 'Aceite', 'Aspirada'], 
        listaVehiculos: [
        Vehiculo(marca: 'Nissan', modelo: 2012, color: 'Azul', matricula: 'V2JS',categoria: 'Encerado', gastos: [Gasto(descripcion: 'Se le hizo una encerada a la puerta', lugar: 'Taller chuy', cantidad: 750.99, fecha: DateTime(2023, 9, 13))]),     
        ],
      ),
    ],
  );
}