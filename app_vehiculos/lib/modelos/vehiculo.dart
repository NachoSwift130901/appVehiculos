import 'package:equatable/equatable.dart';

class Vehiculo with EquatableMixin {
  final String marca;
  final int modelo;
  final String color;
  final String matricula;

  Vehiculo({required this.marca, required this.modelo, required this.color, required this.matricula});

  
  @override
  List<Object?> get props => [];

}