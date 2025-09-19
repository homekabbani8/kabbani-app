import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../widgets/custom_widgets.dart';
import '../profile/profile_screen.dart';
import '../search/advanced_search_screen.dart';
import '../search/barcode_scanner_screen.dart';
import '../search/search_by_id_screen.dart';
import '../products/all_products_screen.dart';
import '../products/category_products_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? workerName;
  final String? workerEmail;

  const HomeScreen({Key? key, this.workerName, this.workerEmail})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Product> _recentSearches = [];

  // ✅ Add these variables to store loaded user data
  String? _currentWorkerName;
  String? _currentWorkerEmail;
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  // ✅ New method to load user data
  Future<void> _initializeUserData() async {
    try {
      // Use passed parameters first, then fallback to SharedPreferences
      if (widget.workerName != null && widget.workerEmail != null) {
        setState(() {
          _currentWorkerName = widget.workerName;
          _currentWorkerEmail = widget.workerEmail;
          _isLoadingUserData = false;
        });
        print('🔵 Using passed parameters - Name: $_currentWorkerName, Email: $_currentWorkerEmail');
        return;
      }

      // Load from SharedPreferences if no parameters passed
      final prefs = await SharedPreferences.getInstance();
      final storedName = prefs.getString('workerName');
      final storedEmail = prefs.getString('workerEmail');

      setState(() {
        _currentWorkerName = storedName;
        _currentWorkerEmail = storedEmail;
        _isLoadingUserData = false;
      });

      print('🔵 Loaded from SharedPreferences - Name: $_currentWorkerName, Email: $_currentWorkerEmail');
    } catch (e) {
      print('❌ Error loading user data: $e');
      setState(() {
        _currentWorkerName = widget.workerName ?? 'Worker';
        _currentWorkerEmail = widget.workerEmail;
        _isLoadingUserData = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ Updated method to use current user data
  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const BarcodeScannerScreen();
      case 2:
        return const AdvancedSearchScreen();
      case 3:
        return ProfileScreen(
          workerName: _currentWorkerName, // ✅ Use loaded data
          workerEmail: _currentWorkerEmail, // ✅ Use loaded data
        );
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    final l10n = AppLocalizations.of(context)!;

    // ✅ Show loading indicator while loading user data
    if (_isLoadingUserData) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF4B4B),
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Worker Name
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.welcomeBackWorker,
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Text(
                        _currentWorkerName ?? 'Worker', // ✅ Use loaded data
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Profile avatar
                      GestureDetector(
                        onTap: () => setState(
                              () => _selectedIndex = 3,
                        ), // Go to profile tab
                        child: CircleAvatar(
                          backgroundColor: const Color(0xFFFF4B4B),
                          child: Text(
                            _getInitials(_currentWorkerName ?? 'W'), // ✅ Use loaded data
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Custom Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomSearchBar(
                hintText: l10n.searchHint,
                onTap: () =>
                    setState(() => _selectedIndex = 2), // Go to search tab
              ),
            ),

            const SizedBox(height: 25),

            // Quick Actions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.quickActions,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.qr_code_scanner,
                          title: l10n.scanProduct,
                          subtitle: l10n.quickScan,
                          color: const Color(0xFFFF4B4B),
                          onTap: () => setState(
                                () => _selectedIndex = 1,
                          ), // Go to scanner tab
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.search,
                          title: l10n.searchID,
                          subtitle: l10n.manualSearch,
                          color: const Color(0xFF667EEA),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SearchByIdScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Categories Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.browseCategory,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllProductsScreen(),
                            ),
                          );
                        },
                        child: Text(
                          l10n.viewAll,
                          style: const TextStyle(color: Color(0xFFFF4B4B)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CategoryChip(
                          label: l10n.all,
                          isSelected: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const CategoryProductsScreen(
                                  category: 'All',
                                ),
                              ),
                            );
                          },
                        ),
                        CategoryChip(
                          label: l10n.furniture,
                          isSelected: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const CategoryProductsScreen(
                                  category: 'Furniture',
                                ),
                              ),
                            );
                          },
                        ),
                        CategoryChip(
                          label: l10n.carpets,
                          isSelected: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const CategoryProductsScreen(
                                  category: 'Carpets',
                                ),
                              ),
                            );
                          },
                        ),
                        CategoryChip(
                          label: l10n.linens,
                          isSelected: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const CategoryProductsScreen(
                                  category: 'Linens',
                                ),
                              ),
                            );
                          },
                        ),
                        CategoryChip(
                          label: l10n.general,
                          isSelected: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const CategoryProductsScreen(
                                  category: 'General',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Departments
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.departments,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DepartmentCard(
                        name: l10n.carpets,
                        icon: Icons.texture,
                        color: const Color(0xFFFF6B9D),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const CategoryProductsScreen(
                                category: 'Carpets',
                              ),
                            ),
                          );
                        },
                      ),
                      DepartmentCard(
                        name: l10n.furniture,
                        icon: Icons.weekend,
                        color: const Color(0xFF667EEA),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const CategoryProductsScreen(
                                category: 'Furniture',
                              ),
                            ),
                          );
                        },
                      ),
                      DepartmentCard(
                        name: l10n.linens,
                        icon: Icons.king_bed,
                        color: const Color(0xFF48C9B0),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const CategoryProductsScreen(
                                category: 'Linens',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get initials from name for avatar
  String _getInitials(String name) {
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return nameParts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: _getSelectedPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        selectedItemColor: const Color(0xFFFF4B4B),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.home),
          BottomNavigationBarItem(
            icon: const Icon(Icons.qr_code_scanner),
            label: l10n.scan,
          ),
          BottomNavigationBarItem(icon: const Icon(Icons.search), label: l10n.search),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: l10n.profile),
        ],
      ),
    );
  }
}