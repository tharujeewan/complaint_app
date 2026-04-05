import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/api_client.dart';

class ComplaintPhotoSection extends StatelessWidget {
  final String? photoFilename;

  const ComplaintPhotoSection({
    super.key,
    this.photoFilename,
  });

  @override
  Widget build(BuildContext context) {
    if (photoFilename == null || photoFilename!.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        color: AppColors.primaryTeal.withOpacity(0.08),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined,
                size: 48, color: AppColors.textSecondary),
            SizedBox(height: 8),
            Text(
              'No photo attached',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final serverBase = ApiClientImpl.isPhysicalDevice 
      ? "http://192.168.1.4:5000" 
      : "http://10.0.2.2:5000";
    final imageUrl = '$serverBase/uploads/$photoFilename';

    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.black12,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryTeal),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 48, color: AppColors.textSecondary),
              SizedBox(height: 8),
              Text('Failed to load image', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
