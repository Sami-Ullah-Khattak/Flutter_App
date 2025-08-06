import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    openLastOpened();
  }

  Future<void> loadUrls() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('saved_urls');
    if (data != null) {
      final decodedList = jsonDecode(data);
      if (decodedList is List) {
        setState(() {
          savedUrls = decodedList.map<Map<String, String>>((e) {
            return {
              'name': e['name'].toString(),
              'url': e['url'].toString(),
            };
          }).toList();
        });
      }
    }
  }

  Future<void> saveUrl(String name, String url) async {
    final prefs = await SharedPreferences.getInstance();
    savedUrls.add({'name': name, 'url': url});
    await prefs.setString('saved_urls', jsonEncode(savedUrls));
    setState(() {});
  }

  Future<void> deleteUrl(int index) async {
    final prefs = await SharedPreferences.getInstance();
    savedUrls.removeAt(index);
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

  Future<void> openWebView(String name, String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_opened', jsonEncode({'name': name, 'url': url}));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewPage(title: name, url: url),
      ),
    );
  }

  Future<void> openLastOpened() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString('last_opened');
    if (last != null) {
      final data = jsonDecode(last);
      openWebView(data['name'], data['url']);
    }
  }

  void exportUrls() async {
    final exportData = jsonEncode(savedUrls);
    await Clipboard.setData(ClipboardData(text: exportData));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Exported to clipboard")),
    );
  }

  void importUrls() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Import URLs"),
        content: TextField(
          controller: controller,
          maxLines: 10,
          decoration: const InputDecoration(hintText: "Paste exported JSON here"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                final imported = jsonDecode(controller.text);
                if (imported is List) {
                  savedUrls = List<Map<String, String>>.from(imported);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('saved_urls', jsonEncode(savedUrls));
                  setState(() {});
                  Navigator.pop(context);
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invalid JSON")),
                );
              }
            },
            child: const Text("Import"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Saved URLs'),
        actions: [
          IconButton(onPressed: exportUrls, icon: const Icon(Icons.upload)),
          IconButton(onPressed: importUrls, icon: const Icon(Icons.download)),
        ],
      ),
      body: savedUrls.isEmpty
          ? const Center(child: Text("No URLs saved. Click + to add one."))
          : ListView.builder(
              itemCount: savedUrls.length,
              itemBuilder: (_, index) {
                final item = savedUrls[index];
                return ListTile(
                  title: Text(item['name'] ?? 'Untitled'),
                  subtitle: Text(item['url'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteUrl(index),
                  ),
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

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const WebViewPage({super.key, required this.url, required this.title});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late InAppWebViewController webViewController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            supportZoom: true,
            javaScriptCanOpenWindowsAutomatically: true,
            supportMultipleWindows: true,
            useOnDownloadStart: true,
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false,
          ),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onCreateWindow: (controller, createWindowRequest) async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebViewPage(
                  url: createWindowRequest.request.url?.toString() ?? widget.url,
                  title: widget.title,
                ),
              ),
            );
            return true;
          },
          shouldOverrideUrlLoading: (controller, action) async {
            return NavigationActionPolicy.ALLOW;
          },
        ),
      ),
    );
  }
}
