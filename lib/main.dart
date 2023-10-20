import 'package:flutter/material.dart';
import 'sql_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> items;

  @override
  void initState() {
    super.initState();
    items = SQLHelper.getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQLite Demo'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: items,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index]['titulo']),
                  subtitle: Text(snapshot.data![index]['descricao']),
                  trailing: PopupMenuButton<String>(
                    onSelected: (String value) async {
                      if (value == 'Update') {
                        await SQLHelper.updateItem(
                            snapshot.data![index]['id'], 'Updated Item', 'This is an updated item');
                        setState(() {
                          items = SQLHelper.getItems();
                        });
                      } else if (value == 'Delete') {
                        await SQLHelper.deleteItem(snapshot.data![index]['id']);
                        setState(() {
                          items = SQLHelper.getItems();
                        });
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'Update',
                          child: Text('Update'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Delete',
                          child: Text('Delete'),
                        ),
                      ];
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          return CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final id = await SQLHelper.createItem('New Item', 'This is a new item');
          setState(() {
            items = SQLHelper.getItems();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}