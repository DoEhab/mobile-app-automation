class LinkPreview {
  final String url;
  final String title;
  final String imageUrl;
  final String price;

  LinkPreview({
    required this.url,
    required this.title,
    required this.imageUrl,
    required this.price,
  });

  bool get hasData =>
      title.isNotEmpty || imageUrl.isNotEmpty || price.isNotEmpty;
}
