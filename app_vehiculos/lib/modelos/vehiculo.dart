import 'package:equatable/equatable.dart';

class Vehiculo with EquatableMixin {
  String marca;
  int modelo;
  String color;
  String matricula;
  String categoria;

  Vehiculo({required this.marca, required this.modelo, required this.color, required this.matricula, required this.categoria});

  
  @override
  List<Object?> get props => [];

}