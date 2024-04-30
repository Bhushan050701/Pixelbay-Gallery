import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixabay Gallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PixabayGallery(),
    );
  }
}

class PixabayGallery extends StatefulWidget {
  const PixabayGallery({Key? key}) : super(key: key);

  @override
  _PixabayGalleryState createState() => _PixabayGalleryState();
}

class _PixabayGalleryState extends State<PixabayGallery> {
  late List<dynamic> _images;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final response = await http.get(Uri.parse(
          'https://pixabay.com/api/?key=43645603-46be6ddd4e1b9bdd49870192c&q=nature&image_type=photo&pretty=true'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _images = data['hits'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      // Show a snackbar with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load images: $e'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildImage(BuildContext context, int index) {
    final image = _images[index];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImage(
              imageUrls: _images.map((image) => image['webformatURL'] as String).toList(),
              initialPage: index,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: image['webformatURL'],
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Icon(Icons.favorite, color: Colors.red),
                  Text('${image['likes']}'),
                  const Icon(Icons.remove_red_eye, color: Colors.blue),
                  Text('${image['views']}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pixabay Gallery'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _images.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getNumberOfColumns(context),
          childAspectRatio: 1,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: _buildImage,
      ),
    );
  }

  int _getNumberOfColumns(BuildContext context) {final width = MediaQuery.of(context).size.width; return (width / 200).floor();
  }
}

class FullScreenImage extends StatelessWidget {final List<String> imageUrls; final int initialPage;
  const FullScreenImage({Key? key, required this.imageUrls, this.initialPage = 0,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: PageView.builder(
          itemCount: imageUrls.length,
          controller: PageController(initialPage: initialPage),
          itemBuilder: (context, index) {
            final imageUrl = imageUrls[index];
            return Hero(
              tag: imageUrl,
              child: PhotoView(
                imageProvider: NetworkImage(imageUrl),
              ),
            );
          },
        ),
      ),
    );
  }
}