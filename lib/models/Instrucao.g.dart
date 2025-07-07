// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Instrucao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Instrucao _$InstrucaoFromJson(Map<String, dynamic> json) => Instrucao(
  id: json['id'] as String?,
  receitaId: json['receitaId'] as String?,
  passo: (json['passo'] as num?)?.toInt(),
  descricao: json['descricao'] as String?,
);

Map<String, dynamic> _$InstrucaoToJson(Instrucao instance) => <String, dynamic>{
  'id': instance.id,
  'receitaId': instance.receitaId,
  'passo': instance.passo,
  'descricao': instance.descricao,
};
