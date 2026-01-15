import 'package:app_automation/features/categories/models/link_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class LinkMetadataService {
  /// Fetches metadata (title, image, price) from a URL
  Future<LinkPreview?> fetchLinkPreview(String url) async {
    debugPrint("Fetch Link Preview: Start fetching for URL: $url");

    final uri = Uri.tryParse(url);
    if (uri == null) {
      debugPrint("Invalid URL: $url");
      return null;
    }

    try {
      debugPrint("Fetch Link Preview: Sending HTTP GET request to $url");
      final response = await http.get(uri);

      debugPrint("Fetch Link Preview: Status Code: ${response.statusCode}");

      if (response.statusCode != 200) return null;

      final document = parser.parse(response.body);

      String getMeta(String property) {
        return document
                .querySelector('meta[property="$property"]')
                ?.attributes['content'] ??
            '';
      }

      final title = getMeta('og:title');
      final imageUrl = getMeta('og:image');
      final price = getMeta('product:price:amount');

      debugPrint("og:title = $title");
      debugPrint("og:image = $imageUrl");
      debugPrint("product:price:amount = $price");

      return LinkPreview(
        url: url,
        title: title,
        imageUrl: imageUrl,
        price: price,
      );
    } catch (e, stack) {
      debugPrint("Fetch Link Preview: Exception occurred: $e");
      debugPrint("Stack trace: $stack");
      return null;
    }
  }
}
