import 'package:flutter/material.dart';
import 'package:qltinhoc/google_sheets_api.dart';
import 'package:qltinhoc/job_screen.dart';
import 'package:qltinhoc/user_management_screen.dart';
import 'package:qltinhoc/password_dialog.dart';
import 'package:qltinhoc/settings_service.dart';
import 'package:qltinhoc/settings_screen.dart';
import 'package:qltinhoc/marquee_text.dart';
import 'package:qltinhoc/splash_screen.dart';
import 'package:qltinhoc/gaming_widgets.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản Lý Công Việc',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6200EE),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFBB86FC),
          secondary: Color(0xFF03DAC6),
          surface: Color(0xFF1E1E1E),
          background: Color(0xFF121212),
          error: Color(0xFFCF6679),
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onBackground: Colors.white,
          onError: Colors.black,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.cyan.withOpacity(0.7), width: 1.5),
          ),
          color: const Color(0xFF1E1E1E).withOpacity(0.8),
          shadowColor: Colors.cyan.withOpacity(0.5),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade800),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFBB86FC), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.cyan, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 5.0,
                  color: Colors.cyan,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            side: const BorderSide(color: Color(0xFFBB86FC)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> _allJobs = [];
  List<Map<String, String>> _displayedJobs = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  String? _selectedUser;
  String? _selectedSeller;
  List<String> _userList = [];
  List<String> _sellerList = [];
  DateTime? _startDate;
  DateTime? _endDate;
  int _totalPoints = 0;

  _HomeScreenState() {
    print('🏠 HomeScreenState constructor called');
  }

  @override
  void initState() {
    print('🚀 initState called');
    super.initState();
    print('🔄 About to call _loadData');
    _loadData();
    print('📝 Adding search listener');
    _searchController.addListener(_filterJobs);
    print('✅ initState completed');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    print('🚀 Starting _loadData...');
    setState(() { _isLoading = true; });

    try {
      print('📋 Getting jobs...');
      final jobs = await GoogleSheetsApi.getAllJobs();
      print('📋 Got ${jobs.length} jobs');

      print('👥 Getting users...');
      final users = await GoogleSheetsApi.getUsers();
      print('👥 Got ${users.length} users');

      print('🛒 Getting sellers...');
      final sellers = await GoogleSheetsApi.getSellers();
      print('🛒 Got ${sellers.length} sellers');

      if (mounted) {
        setState(() {
          _allJobs = jobs;
          _userList = users;
          _sellerList = sellers;
          _filterJobs();
          _isLoading = false;
        });
        print('✅ _loadData completed successfully');
      }
    } catch (e) {
      print('❌ Error in _loadData: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  DateTime? _parseExcelSerialNumber(String dateStr) {
    try {
      final serialNumber = double.parse(dateStr);
      final excelEpoch = DateTime(1899, 12, 30);
      final days = serialNumber.floor();
      final timeFraction = serialNumber - days;
      final hours = (timeFraction * 24).floor();
      final minutes = ((timeFraction * 24 - hours) * 60).floor();
      final seconds = (((timeFraction * 24 - hours) * 60 - minutes) * 60).floor();

      return excelEpoch.add(Duration(
        days: days,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
      ));
    } catch (e) {
      return null;
    }
  }

  String _formatDateForDisplay(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';

    final cleanDateStr = dateStr.trim();
    DateTime? parsedDate;

    if (RegExp(r'^\d+\.?\d*$').hasMatch(cleanDateStr)) {
      parsedDate = _parseExcelSerialNumber(cleanDateStr);
    }

    if (parsedDate == null) {
      final formats = [
        'dd/MM/yyyy HH:mm:ss', 'dd/MM/yyyy', 'yyyy-MM-dd HH:mm:ss', 'yyyy-MM-dd',
        'MM/dd/yyyy HH:mm:ss', 'MM/dd/yyyy', 'dd-MM-yyyy HH:mm:ss', 'dd-MM-yyyy',
      ];

      for (final format in formats) {
        try {
          parsedDate = DateFormat(format).parse(cleanDateStr);
          break;
        } catch (e) {
          continue;
        }
      }
    }

    if (parsedDate != null) {
      return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
    } else {
      return cleanDateStr;
    }
  }

  void _filterJobs() {
    List<Map<String, String>> filteredList = List.from(_allJobs);

    if (_selectedUser != null) {
      filteredList = filteredList.where((job) => job['nguoi_lam'] == _selectedUser).toList();
    }

    if (_selectedSeller != null) {
      filteredList = filteredList.where((job) => job['nguoi_ban'] == _selectedSeller).toList();
    }

    if (_startDate != null || _endDate != null) {
      filteredList = filteredList.where((job) {
        final dateStr = job['ngay_tao'];
        if (dateStr == null || dateStr.isEmpty) return false;

        try {
          final cleanDateStr = dateStr.trim();
          DateTime? jobDate;

          if (RegExp(r'^\d+\.?\d*$').hasMatch(cleanDateStr)) {
            jobDate = _parseExcelSerialNumber(cleanDateStr);
          }

          if (jobDate == null) {
            final formats = [
              'dd/MM/yyyy HH:mm:ss', 'dd/MM/yyyy', 'yyyy-MM-dd HH:mm:ss', 'yyyy-MM-dd',
              'MM/dd/yyyy HH:mm:ss', 'MM/dd/yyyy', 'dd-MM-yyyy HH:mm:ss', 'dd-MM-yyyy',
            ];

            for (final format in formats) {
              try {
                jobDate = DateFormat(format).parse(cleanDateStr);
                break;
              } catch (e) {
                continue;
              }
            }
          }

          if (jobDate == null) {
            return false;
          }

          final jobDateOnly = DateTime(jobDate.year, jobDate.month, jobDate.day);

          if (_startDate != null) {
            final startDateOnly = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
            if (jobDateOnly.isBefore(startDateOnly)) {
              return false;
            }
          }

          if (_endDate != null) {
            final endDateOnly = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
            if (jobDateOnly.isAfter(endDateOnly)) {
              return false;
            }
          }

          return true;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filteredList = filteredList.where((job) {
        return job.values.any((value) => value.toLowerCase().contains(searchQuery));
      }).toList();
    }

    int totalPoints = 0;
    for (final job in filteredList) {
      final rapStr = job['diem_rap'] ?? '0';
      final caiStr = job['diem_cai'] ?? '0';
      final testStr = job['diem_test'] ?? '0';
      final veSinhStr = job['diem_ve_sinh'] ?? '0';
      final ncPcStr = job['diem_nc_pc'] ?? '0';
      final ncLaptopStr = job['diem_nc_laptop'] ?? '0';

      totalPoints += (int.tryParse(rapStr) ?? 0);
      totalPoints += (int.tryParse(caiStr) ?? 0);
      totalPoints += (int.tryParse(testStr) ?? 0);
      totalPoints += (int.tryParse(veSinhStr) ?? 0);
      totalPoints += (int.tryParse(ncPcStr) ?? 0);
      totalPoints += (int.tryParse(ncLaptopStr) ?? 0);
    }

    setState(() {
      _displayedJobs = filteredList;
      _totalPoints = totalPoints;
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _startDate != null && _endDate != null
        ? DateTimeRange(start: _startDate!, end: _endDate!)
        : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _filterJobs();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _filterJobs();
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Icon(Icons.info, color: Color(0xFFBB86FC)),
            SizedBox(width: 12),
            Text('Thông Tin Ứng Dụng'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quản Lý Công Việc',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Phiên bản: GAMING EDITION',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              '© 2025 Tin Học Ngôi Sao',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              'Phát triển bởi Tuấn Khỉ ',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng', style: TextStyle(color: Color(0xFFBB86FC))),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    print('🔄 Starting _refreshData...');
    setState(() { _isLoading = true; });

    try {
      print('📋 Getting jobs...');
      final jobs = await GoogleSheetsApi.getAllJobs();
      print('📋 Got ${jobs.length} jobs');

      print('👥 Getting users...');
      final users = await GoogleSheetsApi.getUsers();
      print('👥 Got ${users.length} users');

      print('🛒 Getting sellers...');
      final sellers = await GoogleSheetsApi.getSellers();
      print('🛒 Got ${sellers.length} sellers');

      if (mounted) {
        setState(() {
          _allJobs = jobs;
          _userList = users;
          _sellerList = sellers;
          _filterJobs();
          _isLoading = false;
        });
        print('✅ _refreshData completed successfully');
      }
    } catch (e) {
      print('❌ Error in _refreshData: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper method để tạo info row (compact version)
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.cyan,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              shadows: [
                Shadow(blurRadius: 3, color: Colors.cyan),
              ],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Ultra simple dropdown - no styling to avoid layout issues
  Widget _buildGamingDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
    required Color color,
  }) {
    return DropdownButton<String>(
      value: value,
      hint: Text(label),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item == 'Tất cả' ? null : item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // Helper method để format ngày
  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Không có ngày';

    try {
      if (dateValue is String) {
        final cleanDateStr = dateValue.trim();

        // Kiểm tra nếu là số Excel serial (như 45885.65945577546)
        if (RegExp(r'^\d+\.?\d*$').hasMatch(cleanDateStr)) {
          final serialNumber = double.parse(cleanDateStr);
          final excelEpoch = DateTime(1899, 12, 30);
          final days = serialNumber.floor();
          final timeFraction = serialNumber - days;
          final hours = (timeFraction * 24).floor();
          final minutes = ((timeFraction * 24 - hours) * 60).floor();

          final date = excelEpoch.add(Duration(
            days: days,
            hours: hours,
            minutes: minutes,
          ));

          return DateFormat('dd/MM/yyyy HH:mm').format(date);
        }

        // Thử parse các format khác
        final date = DateTime.parse(cleanDateStr);
        return DateFormat('dd/MM/yyyy HH:mm').format(date);
      } else if (dateValue is DateTime) {
        return DateFormat('dd/MM/yyyy HH:mm').format(dateValue);
      } else if (dateValue is num) {
        // Xử lý trực tiếp số Excel serial
        final serialNumber = dateValue.toDouble();
        final excelEpoch = DateTime(1899, 12, 30);
        final days = serialNumber.floor();
        final timeFraction = serialNumber - days;
        final hours = (timeFraction * 24).floor();
        final minutes = ((timeFraction * 24 - hours) * 60).floor();

        final date = excelEpoch.add(Duration(
          days: days,
          hours: hours,
          minutes: minutes,
        ));

        return DateFormat('dd/MM/yyyy HH:mm').format(date);
      }
    } catch (e) {
      // Nếu không parse được, trả về string gốc
      return dateValue.toString();
    }

    return dateValue.toString();
  }

  Future<void> _showDeleteDialog(Map<String, String> job) async {
    final jobId = job['id'];
    final ownerName = job['nguoi_lam'];
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (jobId == null || ownerName == null || ownerName.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Công việc không có người làm, không thể xóa.')),
      );
      return;
    }

    final passwordCorrect = await showPasswordDialog(
        context: context, ownerName: ownerName, action: 'xóa');

    if (passwordCorrect) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Xác Nhận Xóa'),
          content:
              Text('Bạn chắc chắn muốn xóa vĩnh viễn công việc của "${job['ten_kh']}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
            TextButton(onPressed: () => Navigator.of(ctx).pop(true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('XÓA')),
          ],
        ),
      );

      if (confirmed == true) {
        setState(() { _isLoading = true; });
        final success = await GoogleSheetsApi.deleteJob(jobId);
        if (success) {
          await _refreshData();
        } else {
          scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Xóa thất bại. Vui lòng thử lại.')));
          if(mounted) {
            setState(() { _isLoading = false; });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const MarqueeText(
          text: 'DANH SÁCH CÔNG VIỆC',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 10.0, color: Colors.cyan, offset: Offset(0, 0)),
              Shadow(blurRadius: 20.0, color: Colors.purple, offset: Offset(0, 0)),
            ],
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade900, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Cài đặt',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.manage_accounts),
            tooltip: 'Quản lý nhân viên',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UserManagementScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Thông tin ứng dụng',
            onPressed: _showAboutDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Gaming Search Bar
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.cyan.withOpacity(0.1),
                        Colors.purple.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.cyan.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: '🔍 Tìm kiếm theo tên, SĐT, mã phiếu...',
                      labelStyle: const TextStyle(
                        color: Colors.cyan,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.cyan),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.red),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Simplified Filter Panel
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.purple.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filter Header
                      Row(
                        children: [
                          const Icon(
                            Icons.filter_list,
                            color: Colors.purple,
                            shadows: [
                              Shadow(blurRadius: 5, color: Colors.purple),
                            ],
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'BỘ LỌC NÂNG CAO',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              shadows: [
                                Shadow(blurRadius: 5, color: Colors.purple),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (_selectedUser != null || _selectedSeller != null || _startDate != null)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedUser = null;
                                  _selectedSeller = null;
                                  _startDate = null;
                                  _endDate = null;
                                });
                                _filterJobs();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.red, Colors.pink],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '🗑️ XÓA BỘ LỌC',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(blurRadius: 3, color: Colors.red),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Filter Options
                      Row(
                        children: [
                          // User Filter
                          Expanded(
                            child: _buildGamingDropdown(
                              label: '👷 Người làm',
                              value: _selectedUser,
                              items: ['Tất cả'] + _userList,
                              onChanged: (value) {
                                setState(() {
                                  _selectedUser = value == 'Tất cả' ? null : value;
                                });
                                _filterJobs();
                              },
                              icon: Icons.person,
                              color: Colors.cyan,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Seller Filter
                          Expanded(
                            child: _buildGamingDropdown(
                              label: '🛒 Người bán',
                              value: _selectedSeller,
                              items: ['Tất cả'] + _sellerList,
                              onChanged: (value) {
                                setState(() {
                                  _selectedSeller = value == 'Tất cả' ? null : value;
                                });
                                _filterJobs();
                              },
                              icon: Icons.store,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Date Filter
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectDateRange,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.withOpacity(0.2),
                                      Colors.red.withOpacity(0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.date_range,
                                      color: Colors.orange,
                                      shadows: [
                                        Shadow(blurRadius: 5, color: Colors.orange),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '📅 Lọc theo ngày',
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _startDate != null && _endDate != null
                                                ? '${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
                                                : 'Chọn khoảng thời gian',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: GamingLoadingWidget(
                      size: 60,
                      type: 'pulse',
                      primaryColor: Colors.cyan,
                      secondaryColor: Colors.purple,
                    ),
                  )
                : _displayedJobs.isEmpty
                    ? const Center(child: Text('Không có dữ liệu'))
                    : ListView.builder(
                        itemCount: _displayedJobs.length,
                        itemBuilder: (context, index) {
                          final job = _displayedJobs[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {
                                  // Kiểm tra password trước khi cho phép sửa
                                  final ownerName = job['nguoi_lam'] ?? 'Chưa phân công';
                                  final passwordCorrect = await showPasswordDialog(
                                    context: context,
                                    ownerName: ownerName,
                                    action: 'sửa'
                                  );

                                  if (passwordCorrect) {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => JobScreen(
                                          job: job,
                                          onSave: _refreshData,
                                          userList: _userList,
                                          sellerList: _sellerList,
                                        ),
                                      ),
                                    );
                                    await _refreshData();
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.deepPurple.shade800.withOpacity(0.6),
                                        Colors.blue.shade800.withOpacity(0.6),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.cyan.withOpacity(0.2),
                                        blurRadius: 4,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header với tên và nút xóa
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '👤 ${job['ten_kh'] ?? 'Không có tên'}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  shadows: [
                                                    Shadow(blurRadius: 5.0, color: Colors.cyan, offset: Offset(0, 0)),
                                                  ],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  colors: [Colors.red, Colors.pink],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.red.withOpacity(0.5),
                                                    blurRadius: 8,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                  shadows: [
                                                    Shadow(blurRadius: 5, color: Colors.red),
                                                  ],
                                                ),
                                                onPressed: () => _showDeleteDialog(job),
                                                tooltip: 'Xóa công việc',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // Thông tin chi tiết (compact)
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: Colors.cyan.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              _buildInfoRow('📱 SĐT:', job['dien_thoai'] ?? 'Không có SĐT'),
                                              const SizedBox(height: 4),
                                              _buildInfoRow('🎫 Mã phiếu:', job['ma_phieu'] ?? 'Không có mã'),
                                              const SizedBox(height: 4),
                                              _buildInfoRow('👷 Người làm:', job['nguoi_lam'] ?? 'Chưa phân công'),
                                              const SizedBox(height: 4),
                                              _buildInfoRow('📅 Ngày tạo:', _formatDate(job['ngay_tao'])),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Tổng điểm: $_totalPoints',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.cyan.withOpacity(0.8),
              Colors.purple.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withOpacity(0.6),
              blurRadius: 15,
              spreadRadius: 3,
            ),
            BoxShadow(
              color: Colors.purple.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 5,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => JobScreen(
                  onSave: _refreshData,
                  userList: _userList,
                  sellerList: _sellerList,
                ),
              ),
            );
            await _refreshData();
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.add,
            size: 28,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 10, color: Colors.cyan),
              Shadow(blurRadius: 20, color: Colors.purple),
            ],
          ),
        ),
      ),
    );
  }
}
