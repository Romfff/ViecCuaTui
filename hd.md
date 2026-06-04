# Hướng dẫn Tích hợp Google Meet tự động

Tài liệu này hướng dẫn chi tiết cách tích hợp tính năng tạo phòng họp Google Meet thật ngay trên ứng dụng **ViecCuaTui** dành cho Nhà tuyển dụng.

---

### Bước 0: Cập nhật thư viện (pubspec.yaml)
Mở file `pubspec.yaml` trong thư mục `demo` và thêm các thư viện cần thiết vào phần `dependencies`:

```yaml
dependencies:
  google_sign_in: ^6.2.1
  googleapis: ^11.4.0
  googleapis_auth: ^2.3.1
  extension_google_sign_in_as_googleapis_auth: ^3.0.0
  url_launcher: ^6.2.1
```
*Sau đó, mở Terminal tại thư mục `demo` và chạy lệnh: `flutter pub get`*

---

### Bước 1: Tạo file dịch vụ Google Meet
Tạo một file mới tại đường dẫn `lib/services/google_meet_service.dart` và dán đoạn mã sau vào:

```dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class GoogleMeetService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [calendar.CalendarApi.calendarEventsScope],
    // ClientId này được lấy từ Google Cloud Console
    clientId: '971858551246-4m66iq79g55hk8rdl6s5sim3974bj46l.apps.googleusercontent.com',
  );

  Future<String?> createMeeting() async {
    try {
      // 1. Đăng nhập
      GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      account ??= await _googleSignIn.signIn();
      if (account == null) return null;

      // 2. Lấy Client đã xác thực (Hàm từ extension)
      final auth.Client? authClient = await account.authenticatedClient();
      if (authClient == null) return null;

      final calendarApi = calendar.CalendarApi(authClient);

      // 3. Cấu hình sự kiện và link Meet
      final event = calendar.Event()
        ..summary = 'Phỏng vấn ViecCuaTui'
        ..description = 'Cuộc họp phỏng vấn ứng viên từ ứng dụng ViecCuaTui'
        ..start = (calendar.EventDateTime()
          ..dateTime = DateTime.now().add(const Duration(minutes: 10)).toUtc()
          ..timeZone = 'UTC')
        ..end = (calendar.EventDateTime()
          ..dateTime = DateTime.now().add(const Duration(hours: 1, minutes: 10)).toUtc()
          ..timeZone = 'UTC')
        ..conferenceData = (calendar.ConferenceData()
          ..createRequest = (calendar.CreateConferenceRequest()
            ..requestId = DateTime.now().millisecondsSinceEpoch.toString()
            ..conferenceSolutionKey = (calendar.ConferenceSolutionKey()
              ..type = 'hangoutsMeet')));

      final createdEvent = await calendarApi.events.insert(
        event,
        'primary',
        conferenceDataVersion: 1,
      );

      return createdEvent.hangoutLink;
    } catch (e) {
      print('Lỗi tạo Meet: $e');
      return null;
    }
  }
}
```

---

### Bước 2: Cập nhật giao diện màn hình Phỏng vấn
Trong file `lib/screen/recruiter/recruiter_home_screen.dart`, bạn tìm đến phần `_InterviewsPage` và cập nhật giao diện để có nút **"Tạo Meet"** (sử dụng StatefulWidget để quản lý link).

---

### Bước 3: Cấu hình Quyền truy cập (Android)
Mở file `android/app/src/main/AndroidManifest.xml` và thêm đoạn sau vào trong thẻ `<queries>`:

```xml
<queries>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="https" />
    </intent>
</queries>
```
