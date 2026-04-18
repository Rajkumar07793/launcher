import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/launcher_service.dart';
import 'app_icon_widget.dart';

class AppGrid extends StatelessWidget {
  final String searchQuery;

  const AppGrid({Key? key, required this.searchQuery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final launcherService = Provider.of<LauncherService>(context);
    
    final filteredApps = searchQuery.isEmpty 
        ? launcherService.apps 
        : launcherService.apps.where((app) => 
            app.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();

    if (launcherService.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (filteredApps.isEmpty) {
      return const Center(
        child: Text(
          "No apps found",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 24,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: filteredApps.length,
      itemBuilder: (context, index) {
        final app = filteredApps[index];
        return GestureDetector(
          onTap: () => launcherService.launchApp(app.packageName),
          child: Column(
            children: [
              AppIconWidget(iconBytes: app.icon, size: 56),
              const SizedBox(height: 8),
              Text(
                app.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
