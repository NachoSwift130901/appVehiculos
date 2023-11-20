// ignore_for_file: non_constant_identifier_names

import 'package:equatable/equatable.dart';


class Vehiculo with EquatableMixin {
  int? vehiculo_id;
  String marca;
  int modelo;
  String color;
  String matricula;
  
  

  Vehiculo({required this.marca, required this.modelo, required this.color, required this.matricula, this.vehiculo_id});

  factory Vehiculo.fromMap(Map<String, dynamic> map){
    return Vehiculo(
      vehiculo_id: map['id']??0,
      marca: map['marca']??'', 
      modelo: map['modelo']??0, 
      color: map['color']??'', 
      matricula: map['matricula']??'', 
      );
  }

  
  @override
  List<Object?> get props => [vehiculo_id,marca, modelo, color, matricula];
  
}