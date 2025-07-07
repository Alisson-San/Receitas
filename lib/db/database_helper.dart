import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final String _nomeBancoDeDados = "receitas.db";
  static final int _versaoBancoDeDados = 2;


  static Database? _bancoDeDados; 


  DatabaseHelper._privateConstructor();
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_bancoDeDados != null) {
      return _bancoDeDados!; // Já inicializado, retorna
    }
    _bancoDeDados = await _initDatabase(); 
    return _bancoDeDados!;
  }

  
  Future<Database> _initDatabase() async {
    String caminhoBanco = join(await getDatabasesPath(), _nomeBancoDeDados);
    return await openDatabase(
      caminhoBanco,
      version: _versaoBancoDeDados,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE receitas (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        dataCriacao TEXT NOT NULL,
        userId TEXT NOT NULL
      )
    ''');

    await db.execute('''
    CREATE TABLE ingredientes (
      id TEXT PRIMARY KEY NOT NULL,
      receitaId TEXT NOT NULL,
      nome TEXT NOT NULL,
      quantidade TEXT NOT NULL,
      FOREIGN KEY (receitaId) REFERENCES receitas (id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE TABLE instrucoes (
      id TEXT PRIMARY KEY NOT NULL,
      receitaId TEXT NOT NULL,
      passo INTEGER NOT NULL,
      descricao TEXT NOT NULL,
      FOREIGN KEY (receitaId) REFERENCES receitas (id) ON DELETE CASCADE
    )
  ''');
  }

  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion != newVersion) {
      await db.execute('DROP TABLE IF EXISTS receitas');
      await db.execute('DROP TABLE IF EXISTS ingredientes');
      await db.execute('DROP TABLE IF EXISTS instrucoes');
      await _onCreate(db, newVersion); // Recria as tabelas
    }
      
     
  }

  
  Future<int> inserir(String tabela, Map<String, Object?> valores) async {
    final db = await database;
    return await db.insert(tabela, valores);
  }

  Future<List<Map<String, Object?>>> obterTodos(String tabela,
      {String? condicao, List<Object>? conidcaoArgs}) async {
    final db = await database;
    return await db.query(tabela,
        where: condicao, whereArgs: conidcaoArgs);
  }


  Future<int> atualizar(String tabela, Map<String, Object?> valores, {String? condicao, List<Object>? conidcaoArgs}) async {
    final db = await database;
    return await db.update(
      tabela,
      valores,
      where: condicao,
      whereArgs: conidcaoArgs,
    );
  }

  Future<int> deletar(String tabela, {String? condicao, List<Object>? conidcaoArgs}) async {
    final db = await database;
    return await db.delete(
      tabela,
      where: condicao,
      whereArgs: conidcaoArgs,
    );
  }
}