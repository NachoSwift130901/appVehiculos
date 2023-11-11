import 'package:equatable/equatable.dart';

class Vehiculo with EquatableMixin {
  final String marca;
  final int modelo;
  final String color;
  final String matricula;
  final String categoria;

  Vehiculo({required this.marca, required this.modelo, required this.color, required this.matricula, required this.categoria});

  
  @override
  List<Object?> get props => [];

}