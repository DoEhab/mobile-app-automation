import 'dart:convert';

import 'package:app_automation/features/categories/data/link_metadata_service.dart';
import 'package:app_automation/features/categories/models/link_preview.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CategoryLinksScreen extends StatefulWidget {
  final String categoryName;

  const CategoryLinksScreen({super.key, required this.categoryName});

  @override
  State<CategoryLinksScreen> createState() => _CategoryLinksScreenState();
}

class _CategoryLinksScreenState extends State<CategoryLinksScreen> {
  final TextEditingController _controller = TextEditingController();
  final LinkMetadataService _metadataService = LinkMetadataService();

  List<LinkPreview> _previews = [];

  String get _prefsKey => 'links_${widget.categoryName}';

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  /// Load saved previews from SharedPreferences
  Future<void> _loadLinks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_prefsKey) ?? [];

    setState(() {
      _previews = jsonList.map((jsonStr) {
        final map = jsonDecode(jsonStr);
        return LinkPreview(
          url: map['url'] ?? '',
          title: map['title'] ?? '',
          imageUrl: map['imageUrl'] ?? '',
          price: map['price'] ?? '',
        );
      }).toList();
    });
  }

  /// Add a new link, fetch metadata, save to state and SharedPreferences
  Future<void> _addLink() async {
    final link = _controller.text.trim();
    if (link.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    // Fetch metadata
    final preview = await _metadataService.fetchLinkPreview(link);
    if (preview == null) {
      debugPrint("Failed to fetch preview for: $link");
      return;
    }

    setState(() {
      _previews.add(preview);
    });

    // Save previews as JSON
    final List<String> jsonList = _previews
        .map(
          (p) => jsonEncode({
            'url': p.url,
            'title': p.title,
            'imageUrl': p.imageUrl,
            'price': p.price,
          }),
        )
        .toList();

    await prefs.setStringList(_prefsKey, jsonList);

    _controller.clear();
  }

  /// Remove a preview from the list and SharedPreferences
  Future<void> _removeLink(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _previews.removeAt(index);
    });

    // Save updated list
    final List<String> jsonList = _previews
        .map(
          (p) => jsonEncode({
            'title': p.title,
            'imageUrl': p.imageUrl,
            'price': p.price,
          }),
        )
        .toList();

    await prefs.setStringList(_prefsKey, jsonList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Paste product link',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addLink, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 16),
            // List of previews
            Expanded(
              child: _previews.isEmpty
                  ? const Center(child: Text('No links added yet'))
                  : ListView.separated(
                      itemCount: _previews.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final preview = _previews[index];

                        return ListTile(
                          onTap: () => _openLink(preview.url), // 👈 clickable
                          leading: preview.imageUrl.isNotEmpty
                              ? Image.network(
                                  preview.imageUrl,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.link),
                          title: Text(
                            preview.title.isNotEmpty
                                ? preview.title
                                : preview.url,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                preview.url,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (preview.price.isNotEmpty)
                                Text('Price: ${preview.price}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeLink(index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _openLink(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    debugPrint('Could not launch $url');
  }
}

