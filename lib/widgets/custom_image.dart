import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

cachedNetworkImage(String mediaUrl) {
  final image = CachedNetworkImage(
    imageUrl: mediaUrl,
    fit: BoxFit.cover,
    placeholder: (context, url) => Padding(
      child: CircularProgressIndicator(),
      padding: EdgeInsets.all(20.0),
    ),
    errorWidget: (context, url, error) => RaisedButton.icon(
        onPressed: cachedNetworkImage(mediaUrl),
        icon: Icon(Icons.error),
        label: Text("Could not load image.")),
  );
  return image;
}
