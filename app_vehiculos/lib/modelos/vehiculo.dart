import 'package:equatable/equatable.dart';
import 'package:app_vehiculos/modelos/gastos.dart';

class Vehiculo with EquatableMixin {
  String marca;
  int modelo;
  String color;
  String matricula;
  
  

  Vehiculo({required this.marca, required this.modelo, required this.color, required this.matricula});

  factory Vehiculo.fromMap(Map<String, dynamic> map){
    return Vehiculo(
      marca: map['marca']??'', 
      modelo: map['modelo']??0, 
      color: map['color']??'', 
      matricula: map['matricula']??'', 
      );
  }

  
  @override
  List<Object?> get props => [marca, modelo, color, matricula];
  
}