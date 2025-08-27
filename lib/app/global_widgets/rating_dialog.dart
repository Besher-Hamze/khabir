import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/app/data/models/order_model.dart';

class RatingDialog extends StatefulWidget {
  final OrderModel order;
  final Function(OrderModel, double, String?) onSubmit;

  const RatingDialog({Key? key, required this.order, required this.onSubmit})
    : super(key: key);

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog>
    with TickerProviderStateMixin {
  double rating = 0;
  final commentController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          Text('Rate ${widget.order.provider.name}'),
          const SizedBox(height: 8),
          Text(
            'How was your experience?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated Star Rating
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        rating = index + 1.0;
                      });
                      _animationController.forward().then((_) {
                        _animationController.reverse();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Transform.scale(
                        scale: index < rating ? _scaleAnimation.value : 1.0,
                        child: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          size: 36,
                          color: index < rating
                              ? Colors.amber
                              : Colors.grey[400],
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),

          const SizedBox(height: 12),

          // Rating Text with animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              rating == 0 ? 'Tap to rate' : '${_getRatingText(rating.toInt())}',
              key: ValueKey(rating),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: rating > 0 ? Colors.amber : Colors.grey[600],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Comment Field
          TextField(
            controller: commentController,
            decoration: InputDecoration(
              labelText: 'Comment (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: 'Share your experience...',
              counterText: '',
            ),
            maxLines: 3,
            maxLength: 500,
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('cancel'.tr),
        ),
        ElevatedButton(
          onPressed: rating == 0
              ? null
              : () {
                  Navigator.of(context).pop();
                  widget.onSubmit(
                    widget.order,
                    rating,
                    commentController.text.trim().isEmpty
                        ? null
                        : commentController.text.trim(),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[600],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('submit'.tr),
        ),
      ],
    );
  }

  String _getRatingText(int stars) {
    switch (stars) {
      case 1:
        return '1 star - Poor';
      case 2:
        return '2 stars - Fair';
      case 3:
        return '3 stars - Good';
      case 4:
        return '4 stars - Very Good';
      case 5:
        return '5 stars - Excellent';
      default:
        return '';
    }
  }
}
