import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Bucoride_Driver/utils/app_constants.dart';
import 'package:Bucoride_Driver/utils/dimensions.dart';
import 'package:Bucoride_Driver/utils/images.dart';
import 'package:Bucoride_Driver/widgets/loading.dart';

class SubscriptionWidget extends StatefulWidget {
  final DateTime? nextPaymentDate;

  const SubscriptionWidget({super.key, required this.nextPaymentDate});

  @override
  State<SubscriptionWidget> createState() => _SubscriptionWidgetState();
}

class _SubscriptionWidgetState extends State<SubscriptionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int daysLeft = 0;

  @override
  void initState() {
    super.initState();
    _calculateDaysLeft();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  void _calculateDaysLeft() {
    final today = DateTime.now();
    daysLeft = widget.nextPaymentDate != null
        ? widget.nextPaymentDate!.difference(today).inDays
        : 0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _fadeAnimation == null
        ? Center(child: Loading())
        : FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppConstants.lightPrimary, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(100),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Subscription',
              style: TextStyle(
                fontSize: Dimensions.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: Dimensions.paddingSizeSmall),

            // Circular Progress Indicator with Better Spacing
            _buildCircularProgress(),
            SizedBox(height: Dimensions.paddingSizeSmall),

            // Payment Date Information
            Text(
              "Next Payment: ${daysLeft > 0 ? "$daysLeft days left" : "No Active Subscription"}",
              style: TextStyle(
                fontSize: Dimensions.fontSizeDefault,
                fontWeight: FontWeight.w500,
                color: daysLeft <= 5 ? Colors.red : Colors.green,
              ),
            ),
            SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              "Due on: ${widget.nextPaymentDate != null ? DateFormat.yMMMd().format(widget.nextPaymentDate!) : 'N/A'}",
              style: TextStyle(
                fontSize: Dimensions.fontSizeDefault,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: Dimensions.paddingSizeLarge),

            // Vehicle Image Centered Below
            Image.asset(
              Images.car,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgress() {
    double percentage = daysLeft > 0 ? (daysLeft / 30).clamp(0.0, 1.0) : 0.0;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                    daysLeft <= 5 ? Colors.red : AppConstants.lightPrimary),
                strokeWidth: 8,
              ),
            ),
            Text(
              "$daysLeft",
              style: TextStyle(
                fontSize: Dimensions.fontSizeExtraLarge,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
