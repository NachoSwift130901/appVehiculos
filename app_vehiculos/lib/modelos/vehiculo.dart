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

  factory Vehiculo.fromMap(Map<String, dynamic> map){
    return Vehiculo(
      marca: map['marca'], 
      modelo: map['modelo'], 
      color: map['color'], 
      matricula: map['matricula'], 
      categoria: map['categoria'], 
      gastos: map['gastos']);
  }

  
  @override
  List<Object?> get props => [];
  
}