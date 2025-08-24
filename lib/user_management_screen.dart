import 'package:flutter/material.dart';
import 'package:qltinhoc/google_sheets_api.dart';
import 'package:qltinhoc/gaming_widgets.dart';
import 'package:qltinhoc/password_dialog.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<String> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() { _isLoading = true; });
    final users = await GoogleSheetsApi.getUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  // Hàm hiển thị dialog để thêm người dùng mới
  Future<void> _showAddUserDialog() async {
    final nameController = TextEditingController();
    final passwordController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Nhân Viên Mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Nhập tên nhân viên",
                labelText: "Tên nhân viên",
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                hintText: "Nhập mật khẩu cho nhân viên",
                labelText: "Mật khẩu",
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final password = passwordController.text.trim();
              if (name.isNotEmpty && password.isNotEmpty) {
                Navigator.of(context).pop({
                  'name': name,
                  'password': password,
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập đầy đủ tên và mật khẩu!')),
                );
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() { _isLoading = true; });
      final success = await GoogleSheetsApi.addUserWithPassword(
        result['name']!,
        result['password']!,
      );
      if (success) {
        await _loadUsers(); // Tải lại danh sách
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã thêm nhân viên "${result['name']}" thành công!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Thêm thất bại hoặc "${result['name']}" đã tồn tại.')),
          );
          setState(() { _isLoading = false; });
        }
      }
    }
  }

  // Hàm hiển thị dialog xác nhận xóa với xác thực mật khẩu
  Future<void> _showDeleteUserDialog(String name) async {
    // Import password_dialog để sử dụng
    final passwordVerified = await showPasswordDialog(
      context: context,
      ownerName: name,
      action: 'xóa nhân viên',
    );

    if (passwordVerified) {
      // Hiển thị dialog xác nhận cuối cùng
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác Nhận Xóa'),
          content: Text('Bạn có chắc chắn muốn xóa nhân viên "$name"?\n\nHành động này không thể hoàn tác.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        setState(() { _isLoading = true; });
        final success = await GoogleSheetsApi.deleteUser(name);
        if (success) {
          await _loadUsers();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã xóa nhân viên "$name" thành công!')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Xóa thất bại. Vui lòng thử lại.')),
            );
            setState(() { _isLoading = false; });
          }
        }
      }
    } else {
      // Mật khẩu không đúng hoặc người dùng hủy
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xác thực thất bại. Không thể xóa nhân viên.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // Hàm hiển thị dialog đổi mật khẩu nhân viên
  Future<void> _showChangePasswordDialog(String name) async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Đổi Mật Khẩu - $name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              decoration: const InputDecoration(
                hintText: "Nhập mật khẩu hiện tại hoặc mật khẩu Admin",
                labelText: "Mật khẩu hiện tại",
              ),
              obscureText: true,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                hintText: "Nhập mật khẩu mới",
                labelText: "Mật khẩu mới",
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                hintText: "Nhập lại mật khẩu mới",
                labelText: "Xác nhận mật khẩu mới",
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final oldPassword = oldPasswordController.text.trim();
              final newPassword = newPasswordController.text.trim();
              final confirmPassword = confirmPasswordController.text.trim();

              if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')),
                );
                return;
              }

              if (newPassword != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mật khẩu mới không khớp!')),
                );
                return;
              }

              // Kiểm tra mật khẩu cũ
              final isAdmin = await GoogleSheetsApi.verifyAdminPassword(oldPassword);
              final isUser = await GoogleSheetsApi.verifyUserPassword(name, oldPassword);

              if (isAdmin || isUser) {
                if (context.mounted) {
                  Navigator.of(context).pop({
                    'newPassword': newPassword,
                  });
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mật khẩu hiện tại không đúng!')),
                  );
                }
              }
            },
            child: const Text('Đổi Mật Khẩu'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() { _isLoading = true; });
      final success = await GoogleSheetsApi.updateUserPassword(name, result['newPassword']!);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã đổi mật khẩu cho "$name" thành công!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đổi mật khẩu thất bại. Vui lòng thử lại.')),
          );
        }
      }
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '👥 QUẢN LÝ NHÂN VIÊN',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
      ),
      body: _isLoading
          ? const Center(
              child: GamingLoadingWidget(
                size: 80,
                type: 'neon',
                primaryColor: Colors.cyan,
                secondaryColor: Colors.purple,
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    Colors.deepPurple.shade900.withOpacity(0.3),
                    Colors.black,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: RefreshIndicator(
                onRefresh: _loadUsers,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.cyan, Colors.purple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            shadows: [
                              Shadow(blurRadius: 5, color: Colors.cyan),
                            ],
                          ),
                        ),
                        title: Text(
                          user,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            shadows: [
                              Shadow(blurRadius: 3, color: Colors.cyan),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Colors.blue, Colors.cyan],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.lock_reset,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(blurRadius: 5, color: Colors.blue),
                                  ],
                                ),
                                tooltip: 'Đổi mật khẩu',
                                onPressed: () {
                                  _showChangePasswordDialog(user);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                tooltip: 'Xóa nhân viên',
                                onPressed: () {
                                  _showDeleteUserDialog(user);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
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
          onPressed: _showAddUserDialog,
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
