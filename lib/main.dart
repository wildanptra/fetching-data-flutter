import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Coin Lore',
      home: MyHomePage(
        title: 'Coin Lore Cryptocurrency',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  // Menyiapkan state 
  late List<dynamic> _data = [];
  bool isLoading = false;

  // Function untuk mengambil data
  Future<void> fetchData() async {
    var url = Uri.parse('https://api.coinlore.net/api/tickers/?limit=10');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _data = jsonData['data'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  // Event ketika klik get data 
  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });

    await fetchData().whenComplete(() => {
      setState(() {
        isLoading = false;
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.black,
        ),
        body: ListView(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: loadData,
                      child: const Text('Get Data'),
                    ),
                  ],
                ),
              ),
            ),
            isLoading
            ? const Padding(
                padding: EdgeInsets.all(10.0),
                child: Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ),
                ),
              )
            : _data.isEmpty
              ? const Center(
                  child: Text('Belum mengambil data.'),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Symbol')),
                      DataColumn(label: Text('Harga USD')),
                    ],
                    rows: _data.map((item) {
                      return DataRow(cells: [
                        DataCell(Text(item['name'])),
                        DataCell(Text(item['symbol'])),
                        DataCell(Text(item['price_usd'])),
                      ]);
                    }).toList(),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
