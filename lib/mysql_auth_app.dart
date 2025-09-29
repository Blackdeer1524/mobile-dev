import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

void main() {
  runApp(MySqlAuthApp());
}

class MySqlAuthApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'MySQL Auth App',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
      ),
      home: AuthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _databaseController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _hostController.dispose();
    _databaseController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      var settings = ConnectionSettings(
        host: _hostController.text,
        port: 3306,
        user: _loginController.text,
        password: _passwordController.text,
        db: _databaseController.text,
      );
      
      var conn = await MySqlConnection.connect(settings);
      await conn.close();
      
      // If connection successful, navigate to insert screen
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => InsertScreen(
            host: _hostController.text,
            database: _databaseController.text,
            login: _loginController.text,
            password: _passwordController.text,
            username: _usernameController.text,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('MySQL Authorization'),
        backgroundColor: CupertinoColors.systemBlue,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Database Connection',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
              
              CupertinoTextField(
                controller: _hostController,
                placeholder: 'Host',
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.separator),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              SizedBox(height: 16),
              
              CupertinoTextField(
                controller: _databaseController,
                placeholder: 'Database',
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.separator),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              SizedBox(height: 16),
              
              CupertinoTextField(
                controller: _loginController,
                placeholder: 'Login',
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.separator),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              SizedBox(height: 16),
              
              CupertinoTextField(
                controller: _passwordController,
                placeholder: 'Password',
                obscureText: true,
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.separator),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              SizedBox(height: 16),
              
              CupertinoTextField(
                controller: _usernameController,
                placeholder: 'Username',
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.separator),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              SizedBox(height: 20),
              
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemRed.withOpacity(0.1),
                    border: Border.all(color: CupertinoColors.systemRed),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: CupertinoColors.systemRed),
                  ),
                ),
              
              SizedBox(height: 20),
              
              CupertinoButton.filled(
                onPressed: _isLoading ? null : _authenticate,
                child: _isLoading
                    ? CupertinoActivityIndicator(color: CupertinoColors.white)
                    : Text(
                        'Connect to Database',
                        style: TextStyle(fontSize: 18, color: CupertinoColors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class InsertScreen extends StatefulWidget {
  final String host;
  final String database;
  final String login;
  final String password;
  final String username;

  InsertScreen({
    required this.host,
    required this.database,
    required this.login,
    required this.password,
    required this.username,
  });

  @override
  _InsertScreenState createState() => _InsertScreenState();
}

class _InsertScreenState extends State<InsertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  
  bool _isLoading = false;
  String _message = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _insertData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      var settings = ConnectionSettings(
        host: widget.host,
        port: 3306,
        user: widget.login,
        password: widget.password,
        db: widget.database,
      );
      
      var conn = await MySqlConnection.connect(settings);
      
      // Create table if it doesn't exist (using username as table name)
      await conn.query('''
        CREATE TABLE IF NOT EXISTS `${widget.username}` (
          id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
          name VARCHAR(255),
          email VARCHAR(255),
          age INT
        )
      ''');
      
      // Insert data
      var result = await conn.query(
        'INSERT INTO `${widget.username}` (name, email, age) VALUES (?, ?, ?)',
        [_nameController.text, _emailController.text, int.parse(_ageController.text)],
      );
      
      await conn.close();
      
      setState(() {
        _message = 'Data inserted successfully! Row ID: ${result.insertId}';
      });
      
      // Clear form
      _nameController.clear();
      _emailController.clear();
      _ageController.clear();
      
      // Automatically show the table after successful insert
      _viewTable();
      
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _viewTable() async {
    try {
      var settings = ConnectionSettings(
        host: widget.host,
        port: 3306,
        user: widget.login,
        password: widget.password,
        db: widget.database,
      );
      
      var conn = await MySqlConnection.connect(settings);
      var results = await conn.query('SELECT * FROM `${widget.username}`');
      await conn.close();
      
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => TableScreen(
            data: results.toList(),
            host: widget.host,
            database: widget.database,
            login: widget.login,
            password: widget.password,
            username: widget.username,
          ),
        ),
      );
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Text('Error loading table: ${e.toString()}'),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  void _navigateToDelete() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => DeleteScreen(
          host: widget.host,
          database: widget.database,
          login: widget.login,
          password: widget.password,
          username: widget.username,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Insert Data'),
        backgroundColor: CupertinoColors.systemGreen,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Insert New User',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
              
              CupertinoTextField(
                controller: _nameController,
                placeholder: 'Name',
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.separator),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              SizedBox(height: 16),
              
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'Email',
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.separator),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              SizedBox(height: 16),
              
              CupertinoTextField(
                controller: _ageController,
                placeholder: 'Age',
                keyboardType: TextInputType.number,
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.separator),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              SizedBox(height: 20),
              
              if (_message.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _message.contains('Error') 
                        ? CupertinoColors.systemRed.withOpacity(0.1) 
                        : CupertinoColors.systemGreen.withOpacity(0.1),
                    border: Border.all(
                      color: _message.contains('Error') 
                          ? CupertinoColors.systemRed 
                          : CupertinoColors.systemGreen,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _message,
                    style: TextStyle(
                      color: _message.contains('Error') 
                          ? CupertinoColors.systemRed 
                          : CupertinoColors.systemGreen,
                    ),
                  ),
                ),
              
              SizedBox(height: 20),
              
              CupertinoButton.filled(
                onPressed: _isLoading ? null : _insertData,
                child: _isLoading
                    ? CupertinoActivityIndicator(color: CupertinoColors.white)
                    : Text(
                        'Insert Data',
                        style: TextStyle(fontSize: 18, color: CupertinoColors.white),
                      ),
              ),
              
              SizedBox(height: 16),
              
              CupertinoButton.filled(
                onPressed: _viewTable,
                child: Text(
                  'View Table',
                  style: TextStyle(fontSize: 18, color: CupertinoColors.white),
                ),
              ),
              
              SizedBox(height: 16),
              
              CupertinoButton.filled(
                onPressed: _navigateToDelete,
                child: Text(
                  'DELETE',
                  style: TextStyle(fontSize: 18, color: CupertinoColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class DeleteScreen extends StatefulWidget {
  final String host;
  final String database;
  final String login;
  final String password;
  final String username;

  DeleteScreen({
    required this.host,
    required this.database,
    required this.login,
    required this.password,
    required this.username,
  });

  @override
  _DeleteScreenState createState() => _DeleteScreenState();
}

class _DeleteScreenState extends State<DeleteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  
  bool _isLoading = false;
  String _message = '';
  List<ResultRow> _tableData = [];

  @override
  void initState() {
    super.initState();
    _loadTableData();
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _loadTableData() async {
    try {
      var settings = ConnectionSettings(
        host: widget.host,
        port: 3306,
        user: widget.login,
        password: widget.password,
        db: widget.database,
      );
      
      var conn = await MySqlConnection.connect(settings);
      var results = await conn.query('SELECT * FROM `${widget.username}`');
      await conn.close();
      
      setState(() {
        _tableData = results.toList();
      });
    } catch (e) {
      setState(() {
        _message = 'Error loading table: ${e.toString()}';
      });
    }
  }

  Future<void> _deleteData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      var settings = ConnectionSettings(
        host: widget.host,
        port: 3306,
        user: widget.login,
        password: widget.password,
        db: widget.database,
      );
      
      var conn = await MySqlConnection.connect(settings);
      
      // Check if record exists
      var checkResult = await conn.query(
        'SELECT * FROM `${widget.username}` WHERE id = ?',
        [int.parse(_idController.text)],
      );
      
      if (checkResult.isEmpty) {
        setState(() {
          _message = 'No record found with ID ${_idController.text}';
        });
        await conn.close();
        return;
      }
      
      // Delete the record
      await conn.query(
        'DELETE FROM `${widget.username}` WHERE id = ?',
        [int.parse(_idController.text)],
      );
      
      await conn.close();
      
      setState(() {
        _message = 'Record with ID ${_idController.text} deleted successfully!';
      });
      
      _idController.clear();
      
      // Refresh the table data to show updated results
      _loadTableData();
      
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Delete Record'),
        backgroundColor: CupertinoColors.systemRed,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.back, color: CupertinoColors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => InsertScreen(
                  host: widget.host,
                  database: widget.database,
                  login: widget.login,
                  password: widget.password,
                  username: widget.username,
                ),
              ),
            );
          },
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Table display section
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Records',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: _tableData.isEmpty
                          ? Center(
                              child: Text(
                                'No data found',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: [
                                  DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Age', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: _tableData.map((row) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(row[0].toString())),
                                      DataCell(Text(row[1]?.toString() ?? '')),
                                      DataCell(Text(row[2]?.toString() ?? '')),
                                      DataCell(Text(row[3]?.toString() ?? '')),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            // Delete form section
            Container(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Delete User by ID',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
              
                    CupertinoTextField(
                      controller: _idController,
                      placeholder: 'User ID',
                      keyboardType: TextInputType.number,
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.separator),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    SizedBox(height: 16),
              
                    if (_message.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _message.contains('Error') 
                              ? CupertinoColors.systemRed.withOpacity(0.1) 
                              : CupertinoColors.systemGreen.withOpacity(0.1),
                          border: Border.all(
                            color: _message.contains('Error') 
                                ? CupertinoColors.systemRed 
                                : CupertinoColors.systemGreen,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _message,
                          style: TextStyle(
                            color: _message.contains('Error') 
                                ? CupertinoColors.systemRed 
                                : CupertinoColors.systemGreen,
                          ),
                        ),
                      ),
                    
                    SizedBox(height: 16),
                    
                    CupertinoButton.filled(
                      onPressed: _isLoading ? null : _deleteData,
                      child: _isLoading
                          ? CupertinoActivityIndicator(color: CupertinoColors.white)
                          : Text(
                              'Delete Record',
                              style: TextStyle(fontSize: 18, color: CupertinoColors.white),
                            ),
                    ),
                    
                    SizedBox(height: 12),
                    
                    CupertinoButton.filled(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => InsertScreen(
                              host: widget.host,
                              database: widget.database,
                              login: widget.login,
                              password: widget.password,
                              username: widget.username,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Back to Insert',
                        style: TextStyle(fontSize: 16, color: CupertinoColors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TableScreen extends StatelessWidget {
  final List<ResultRow> data;
  final String host;
  final String database;
  final String login;
  final String password;
  final String username;

  TableScreen({
    required this.data,
    required this.host,
    required this.database,
    required this.login,
    required this.password,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('${username}\'s Table'),
        backgroundColor: CupertinoColors.systemPurple,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.back, color: CupertinoColors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => InsertScreen(
                  host: host,
                  database: database,
                  login: login,
                  password: password,
                  username: username,
                ),
              ),
            );
          },
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (data.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No data found',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Age', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: data.map((row) {
                      return DataRow(
                        cells: [
                          DataCell(Text(row[0].toString())),
                          DataCell(Text(row[1]?.toString() ?? '')),
                          DataCell(Text(row[2]?.toString() ?? '')),
                          DataCell(Text(row[3]?.toString() ?? '')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: CupertinoButton.filled(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => InsertScreen(
                        host: host,
                        database: database,
                        login: login,
                        password: password,
                        username: username,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Back to Insert',
                  style: TextStyle(fontSize: 16, color: CupertinoColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
