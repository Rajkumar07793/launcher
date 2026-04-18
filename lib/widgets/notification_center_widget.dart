import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../services/launcher_service.dart';

class NotificationCenterWidget extends StatelessWidget {
  const NotificationCenterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context);
    final launcherService = Provider.of<LauncherService>(context);

    if (notificationService.notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            "NOTIFICATIONS",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: notificationService.notifications.length.clamp(0, 3), // Show only top 3
          itemBuilder: (context, index) {
            final notification = notificationService.notifications[index];
            final appIcon = launcherService.apps.firstWhere(
              (a) => a.packageName == notification.packageName,
              orElse: () => launcherService.apps.first,
            ).icon;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.transparent,
                    backgroundImage: MemoryImage(appIcon),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          notification.text,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (notificationService.notifications.length > 3)
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 4),
            child: Text(
              "+ ${notificationService.notifications.length - 3} more",
              style: const TextStyle(color: Colors.white24, fontSize: 10),
            ),
          ),
      ],
    );
  }
}
