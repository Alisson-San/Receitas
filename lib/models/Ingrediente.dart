import 'package:uuid/uuid.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Ingrediente.g.dart';

@JsonSerializable()
class Ingrediente {
  String? id;
  String? receitaId;
  String? nome;
  String? quantidade;

  Ingrediente({
    String ? id,
    required this.receitaId,
    required this.nome,
    this.quantidade,
  }) : id = id ?? const Uuid().v4();

   factory Ingrediente.fromJson(Map<String, dynamic> json) => _$IngredienteFromJson(json);
  Map<String, dynamic> toJson() => _$IngredienteToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'receitaId': receitaId,
      'nome': nome,
      'quantidade': quantidade,
    };
  }

  factory Ingrediente.fromMap(Map<String, dynamic> map) {
    return Ingrediente(
      id: map['id'],
      receitaId: map['receitaId'],
      nome: map['nome'],
      quantidade: map['quantidade'],
    );
  }
}
