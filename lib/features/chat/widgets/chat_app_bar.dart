import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// Thanh tiêu đề chat: avatar ElectroShop + tên nhân viên + trạng thái online.
class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.secondary),
        onPressed: () => Navigator.pop(context),
      ),
      leadingWidth: 40,
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Text('ES',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppStrings.supportAgentName,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary)),
              Text(AppStrings.activeStatus,
                  style: TextStyle(fontSize: 11, color: AppColors.success)),
            ],
          ),
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border),
      ),
    );
  }
}
