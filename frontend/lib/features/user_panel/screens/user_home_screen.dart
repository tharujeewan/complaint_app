import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../models/complaint_model.dart';
import '../widgets/complaint_card.dart';
import '../widgets/home_bottom_nav.dart';
import 'issues_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;

  // Tab screens (Issues, Map, Account are separate screens)
  final List<Widget> _screens = const [
    SizedBox.shrink(), // Home content handled separately below
    IssuesScreen(),
    MapScreen(),
    ProfileScreen(),
  ];

  // Sample complaint data
  final List<Complaint> _complaints = const [
    Complaint(
      title: 'Massive Pothole on Main Road',
      date: 'Jul 17, 2025',
      status: 'PENDING',
      icon: Icons.warning_amber_rounded,
    ),
    Complaint(
      title: 'Garbage on Sidewalk',
      date: 'Jul 17, 2025',
      status: 'IN PROGRESS',
      icon: Icons.delete_outline,
    ),
    Complaint(
      title: 'Broken Streetlight near Chowk',
      date: 'Jul 19, 2025',
      status: 'RESOLVED',
      icon: Icons.lightbulb_outline,
    ),
    Complaint(
      title: 'Issues: Pothole on Road',
      date: 'Jul 17, 2025',
      status: 'PENDING',
      icon: Icons.report_problem_outlined,
    ),
    Complaint(
      title: 'Water Pipeline Leaking',
      date: 'Aug 02, 2025',
      status: 'IN PROGRESS',
      icon: Icons.water_drop_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // For non-home tabs, show the tab's own Scaffold
    if (_currentIndex != 0) {
      return Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: HomeBottomNav(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      );
    }

    // Home tab
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryTeal,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 50,
            width: 50,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          const Text(
            'LocalCare',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  // ── Body ───────────────────────────────────────────────
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ward Header
          _buildWardHeader(),
          const SizedBox(height: 16),

          // Stats Row
          _buildStatsRow(),
          const SizedBox(height: 20),

          // Complaints List
          ..._complaints.map((c) => ComplaintCard(complaint: c)),
        ],
      ),
    );
  }

  // ── Ward Header ────────────────────────────────────────
  Widget _buildWardHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Reduced from 14 to 4
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          isDense: true, // Added isDense
          hintText: 'Search complaints',
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.7),
            fontSize: 15,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ), // Added constraints to reduce icon padding
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10, // Reduced from 14 to 10
          ),
        ),
      ),
    );
  }

  // ── Stats Row ──────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.groups_outlined,
            label: 'ACTIVE ISSUES',
            count: '24',
            iconColor: AppColors.primaryTeal,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_box_outlined,
            label: 'RESOLVED',
            count: '142',
            iconColor: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String count,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: iconColor),
              const SizedBox(width: 8),
              Text(
                count,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── FAB ────────────────────────────────────────────────
  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {},
      backgroundColor: AppColors.primaryTeal,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Report Issue',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
