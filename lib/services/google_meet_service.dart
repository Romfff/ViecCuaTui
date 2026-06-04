import 'package:url_launcher/url_launcher.dart';

class GoogleMeetService {
  // Mở Google Meet để tuyển dụng tạo phòng họp
  Future<bool> openGoogleMeet() async {
    try {
      final Uri uri = Uri.parse('https://meet.google.com/new');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Lỗi mở Google Meet: $e');
      return false;
    }
  }

  // Mở link Meet cụ thể
  Future<bool> launchMeetingLink(String meetLink) async {
    try {
      // Nếu link không có protocol, thêm https://
      String url = meetLink;
      if (!meetLink.startsWith('http')) {
        url = 'https://meet.google.com/$meetLink';
      }
      
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Lỗi mở Meet link: $e');
      return false;
    }
  }

  // Kiểm tra link Google Meet có hợp lệ không
  bool isValidMeetLink(String link) {
    return link.contains('meet.google.com') || 
           RegExp(r'^[a-z]{3}-[a-z]{4}-[a-z]{3}$').hasMatch(link);
  }
}
