import 'package:flutter/material.dart';
import '../../../model/menu.dart';
import '../../../controllers/profile_controller.dart';
import '../../../utils/rive_utils.dart';
 // Update this path to match your project structure

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  Menu selectedSideMenu = sidebarMenus.first;
  late ProfileController profileController;
  
  @override
  void initState() {
    super.initState();
    profileController = ProfileController();
  }
  
  // Existing formatFullName method...
  
  @override
  Widget build(BuildContext context) {
    // Your existing code for profileDataStudent, formattedName and carreraText...
    
    return SafeArea(
      child: Container(
        width: 288,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF17203A),
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // InfoCard...
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                child: Text(
                  "BROWSE ",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white70),
                ),
              ),
              // Updated Profile button
              ListTile(
                leading: const Icon(Icons.person),
                titleTextStyle: const TextStyle(color: Colors.white),
                title: const Text('Perfil'),
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              // Add more menu items as needed...
            ],
          ),
        ),
      ),
    );
  }
}
