import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saved URLs',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const UrlListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UrlListPage extends StatefulWidget {
  const UrlListPage({super.key});

  @override
  State<UrlListPage> createState() => _UrlListPageState();
}

class _UrlListPageState extends State<UrlListPage> {
  List<Map<String, String>> savedUrls = [];

  @override
  void initState() {
    super.initState();
    loadUrls();
  }

  Future<void> loadUrls() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('saved_urls');
    if (data != null) {
      setState(() {
        savedUrls = List<Map<String, String>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> saveUrl(String name, String url) async {
    final prefs = await SharedPreferences.getInstance();
    savedUrls.add({'name': name, 'url': url});
    await prefs.setString('saved_urls', jsonEncode(savedUrls));
    setState(() {});
  }

  void showAddDialog() {
    final nameController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add URL"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: "URL"),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              String name = nameController.text.trim();
              String url = urlController.text.trim();
              if (!url.startsWith('http')) {
                url = 'https://$url';
              }
              saveUrl(name, url);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void openWebView(String name, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewPage(title: name, url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Saved URLs')),
      body: savedUrls.isEmpty
          ? const Center(child: Text("No URLs saved. Click + to add one."))
          : ListView.builder(
              itemCount: savedUrls.length,
              itemBuilder: (_, index) {
                final item = savedUrls[index];
                return ListTile(
                  title: Text(item['name'] ?? 'Untitled'),
                  subtitle: Text(item['url'] ?? ''),
                  onTap: () => openWebView(item['name']!, item['url']!),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class WebViewPage extends StatelessWidget {
  final String url;
  final String title;

  const WebViewPage({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
      ),
    );
  }
}
