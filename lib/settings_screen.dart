import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:qltinhoc/settings_service.dart';
import 'package:qltinhoc/gaming_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _sheetIdController;
  late final TextEditingController _geminiKeyController;
  bool _isLoading = false;

  // Biến mới để quản lý thông tin file JSON
  String _jsonFileContent = '';
  String _jsonFileName = 'Chưa chọn file';

  @override
  void initState() {
    super.initState();
    // Tải cài đặt hiện có vào các ô
    _sheetIdController = TextEditingController(text: SettingsService.sheetId);
    _geminiKeyController = TextEditingController(text: SettingsService.geminiKey);

    // Kiểm tra và hiển thị trạng thái của file JSON đã lưu
    _jsonFileContent = SettingsService.gsheetJson;
    if (_jsonFileContent.isNotEmpty) {
      _jsonFileName = 'credentials.json (đã có)';
    }
  }

  @override
  void dispose() {
    _sheetIdController.dispose();
    _geminiKeyController.dispose();
    super.dispose();
  }



  // Hàm xử lý việc chọn và đọc file (cách cũ)
  Future<void> _pickJsonFile() async {
    try {
      // Mở trình chọn file, chỉ cho phép chọn file có đuôi .json
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      // Nếu người dùng chọn một file
      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);
        
        // Đọc nội dung file dưới dạng chuỗi ký tự
        final fileContent = await file.readAsString();

        // Cập nhật giao diện để hiển thị tên file và lưu nội dung
        setState(() {
          _jsonFileContent = fileContent;
          _jsonFileName = result.files.single.name;
        });
      } else {
        // Người dùng đã hủy việc chọn file
        print('Hủy chọn file.');
      }
    } catch (e) {
      print("Lỗi khi chọn file: $e");
      // Hiển thị thông báo lỗi nếu có sự cố
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi đọc file: $e')),
        );
      }
    }
  }
  


  // Hàm lưu tất cả cài đặt (cách cũ)
  Future<void> _save() async {
    // Kiểm tra xem người dùng đã chọn file JSON chưa (nếu trước đó chưa có)
    if (_jsonFileContent.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn file credentials.json!')),
        );
       return;
    }

    setState(() { _isLoading = true; });

    // Gọi service để lưu tất cả dữ liệu
    await SettingsService.saveSettings(
      newSheetId: _sheetIdController.text.trim(),
      newGeminiKey: _geminiKeyController.text.trim(),
      newGsheetJson: _jsonFileContent.trim(),
    );

    // Cần phải khởi tạo lại Google Sheets API với thông tin mới
    // GoogleSheetsApi.init(); // <- Tạm thời vô hiệu hóa, sẽ khởi tạo khi cần

    if (mounted) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu cài đặt! Ứng dụng sẽ sử dụng cài đặt mới ở lần làm mới tiếp theo.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '⚙️ CÀI ĐẶT HỆ THỐNG',
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
              child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Gaming Header
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.cyan.withOpacity(0.2),
                        Colors.purple.withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.cyan.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.settings_applications,
                        size: 48,
                        color: Colors.cyan,
                        shadows: [
                          Shadow(blurRadius: 10, color: Colors.cyan),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'CẤU HÌNH HỆ THỐNG',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(blurRadius: 5, color: Colors.cyan),
                            Shadow(blurRadius: 10, color: Colors.purple),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Cấu hình hệ thống để kết nối với Google Sheets và AI',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Gaming Input Fields
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.cyan.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _sheetIdController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: '🔗 ID Google Sheet',
                          labelStyle: const TextStyle(
                            color: Colors.cyan,
                            fontWeight: FontWeight.bold,
                          ),
                          hintText: 'Dán ID sheet của bạn vào đây',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: const Icon(Icons.table_chart, color: Colors.cyan),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.cyan),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.cyan.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.cyan, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _geminiKeyController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: '🤖 API Key của Gemini',
                          labelStyle: const TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                          hintText: 'Dán API key của Gemini vào đây',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: const Icon(Icons.smart_toy, color: Colors.purple),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.purple),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.purple.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.purple, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // KHỐI CHỌN FILE JSON MỚI
                Text(
                  'File Google Credentials (.json)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Hiển thị tên file, có thể bị cắt nếu quá dài
                      Expanded(
                        child: Text(
                          _jsonFileName,
                          style: TextStyle(
                            color: _jsonFileName.startsWith('Chưa') ? Colors.red : Colors.green.shade800,
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Nút bấm để mở trình chọn file
                      ElevatedButton.icon(
                        icon: const Icon(Icons.folder_open),
                        onPressed: _pickJsonFile,
                        label: const Text('Chọn File...'),
                      )
                    ],
                  ),
                ),
                // --- KẾT THÚC KHỐI MỚI ---
                
                const SizedBox(height: 32),
                // Nút Lưu Cài Đặt
                // Gaming Save Button
                Center(
                  child: GamingButton(
                    text: 'LƯU CÀI ĐẶT',
                    icon: Icons.save,
                    onPressed: _save,
                    width: 250,
                    height: 60,
                    primaryColor: Colors.green,
                    secondaryColor: Colors.cyan,
                  ),
                ),
              ],
            ),
          ),
    );
  }
}