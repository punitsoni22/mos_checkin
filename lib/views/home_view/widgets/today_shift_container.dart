import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import '../../../routes/app_routes.dart';
import '../controller/home_controller.dart';

class ApproveShiftContainer extends StatelessWidget {
  final ColorScheme colorScheme;
  final HomeController controller;

  const ApproveShiftContainer({
    super.key,
    required this.colorScheme,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      double calculatedHeight = _calculateDynamicHeight();
      return SizedBox(
        width: 330.w,
        height: calculatedHeight,
        child: _buildContent(context),
      );
    });
  }

  double _calculateDynamicHeight() {
    if (controller.isApprovedShiftsLoading.value) {
      return 160.h;
    } else if (controller.displayApprovedShifts.isEmpty) {
      return 70.h;
    } else {
      int itemCount = controller.displayApprovedShifts.length;
      double itemHeight = 80.h; // Increased for detailed cards
      double maxHeight = 240.h; // Increased to accommodate more content
      return (itemCount * itemHeight).clamp(90.h, maxHeight);
    }
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 6.w),
      child: _buildContentBody(),
    );
  }

  Widget _buildContentBody() {
    if (controller.isApprovedShiftsLoading.value) {
      return _buildShimmerEffect();
    }
    if (controller.displayApprovedShifts.isEmpty) {
      return Center(
        child: Text(
          "No Approved Shifts",
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.6),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    final ScrollController scrollController = ScrollController();

    return Scrollbar(
      controller: scrollController,
      thickness: 6.0,
      radius: Radius.circular(10.r),
      thumbVisibility: true,
      interactive: true,
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.only(right: 8.w),
        physics: const BouncingScrollPhysics(),
        itemCount: controller.displayApprovedShifts.length,
        itemBuilder: (context, index) {
          final shift = controller.displayApprovedShifts[index];
          return _buildShiftItem(shift);
        },
      ),
    );
  }

  Widget _buildShiftItem(Map<String, dynamic> shiftData) {
    final service =(shiftData['ServiceDescription'] as String?)?.trim() ?? 'Unknown Service';
    final shiftStatus = (shiftData['Status'] as String?)?.trim() == 'A' ? 'Approved' : 'Unknown';
    final clientInfo = 'Client ID: ${shiftData['ClientID'] ?? 'Unknown'}'; // Using ClientID as placeholder

    // Format shift time
    String shiftTime = '';
    try {
      final shiftDate = shiftData['ShiftDate'] as String?;
      final startTime = shiftData['ShiftStart'] as String?;
      final endTime = shiftData['ShiftEnd'] as String?;
      if (shiftDate != null && startTime != null && endTime != null) {
        final startDateTime = DateTime.parse('$shiftDate $startTime');
        final endDateTime = DateTime.parse('$shiftDate $endTime');
        final timeFormat = DateFormat('h:mm a');
        shiftTime = '${timeFormat.format(startDateTime)} - ${timeFormat.format(endDateTime)}';
      } else {
        shiftTime = 'Time not available';
      }
    } catch (e) {
      log('Error parsing shift time: $e');
      shiftTime = 'Time not available';
    }

    // Choose status color
    Color statusColor;
    switch (shiftStatus) {
      case 'Approved':
        statusColor = Color(0xff570b90);
        break;
      default:
        statusColor = Colors.amber;
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First row: Service and Status
          Row(
            children: [
              Expanded(
                child: Text(
                  service,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  shiftStatus,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),

          // Second row: Client info and time
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16.sp,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  clientInfo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.8),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.access_time,
                size: 16.sp,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              SizedBox(width: 6.w),
              Text(
                shiftTime,
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.8),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceVariant,
      highlightColor: colorScheme.surface.withOpacity(0.8),
      child: Column(
        children: List.generate(
          1,
              (index) => Container(
            margin: EdgeInsets.symmetric(vertical: 6.h),
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // First row shimmer
                Row(
                  children: [
                    Container(
                      width: 180.w,
                      height: 14.h,
                      color: Colors.white,
                    ),
                    Spacer(),
                    Container(
                      width: 60.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ],
                ),
                // Second row shimmer
                Row(
                  children: [
                    Container(
                      width: 16.w,
                      height: 16.h,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      width: 100.w,
                      height: 12.h,
                      color: Colors.white,
                    ),
                    Spacer(),
                    Container(
                      width: 100.w,
                      height: 12.h,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}