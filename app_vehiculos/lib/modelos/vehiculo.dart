import 'package:equatable/equatable.dart';
import 'package:app_vehiculos/modelos/gastos.dart';

class Vehiculo with EquatableMixin {
  String marca;
  int modelo;
  String color;
  String matricula;
  String categoria;
  List<Gasto>? gastos;

  Vehiculo({required this.marca, required this.modelo, required this.color, required this.matricula, required this.categoria, required this.gastos});

  
  @override
  List<Object?> get props => [];
  
}