# ViecCuaTui - Ứng Dụng Tìm Việc & Tuyển Dụng Thông Minh

ViecCuaTui là một ứng dụng di động tìm việc làm và tuyển dụng hiện đại được xây dựng bằng **Flutter** (Frontend) kết hợp với **Firebase** làm cơ sở dữ liệu và **Node.js** làm trạm trung chuyển (proxy) kết nối các dịch vụ trí tuệ nhân tạo (AI Assistant).

---

## 🌟 Tính Năng Nổi Bật
- **Dành cho Ứng viên**: Tìm kiếm việc làm, quản lý hồ sơ, ứng tuyển CV trực tiếp, lên lịch phỏng vấn và chat hỏi đáp nhanh về xu hướng thị trường lao động/mức lương với **Trợ lý HRBot AI**.
- **Dành cho Nhà tuyển dụng**: Đăng tin tuyển dụng, quản lý ứng viên nộp hồ sơ, duyệt CV thông minh, lên lịch hẹn phỏng vấn tích hợp Google Meet và liên hệ trực tiếp với ứng viên qua mục Chat.

---

## 🛠️ Công Nghệ Sử Dụng
1. **Frontend**: Flutter (Dart), State Management (Provider), Local DB (Hive).
2. **Backend Services**: Firebase Core & Auth, Cloud Firestore.
3. **AI Proxy Backend**: Node.js, Express, Google Gemini API.

---

## 🤖 Hướng Dẫn Cấu Hình & Chạy Trợ Lý AI (HRBot Backend Proxy)

Để bảo mật thông tin và giấu API Key của AI tránh bị đánh cắp khi dịch ngược mã nguồn Flutter, ứng dụng sử dụng mô hình **Trạm Trung Chuyển (Middle-man)** bằng một server Node.js chạy độc lập.

### 1. Lấy API Key Gemini Miễn phí
1. Truy cập **[Google AI Studio (aistudio.google.com)](https://aistudio.google.dev/)** và đăng nhập bằng tài khoản Gmail của bạn.
2. Nhấn vào nút **"Get API Key"** ở menu bên trái.
3. Nhấp **"Create API Key"** và sao chép (copy) khóa API vừa tạo.

### 2. Cài Đặt & Chạy Server Node.js
1. Sử dụng Terminal/Command Prompt di chuyển vào thư mục `server`:
   ```bash
   cd server
   ```
2. Nếu máy của bạn gặp lỗi chứng chỉ SSL hoặc kết nối mạng khi tải thư viện, hãy tắt tạm thời kiểm tra SSL của npm:
   ```bash
   npm config set strict-ssl false
   ```
3. Cài đặt các thư viện phụ thuộc:
   ```bash
   npm install
   ```
4. Tạo file `.env` nằm trong thư mục `server/` (file này đã được đưa vào `.gitignore` để tránh bị đẩy công khai lên GitHub) với nội dung sau:
   ```env
   GEMINI_API_KEY=Nhập_Khóa_API_Gemini_Của_Bạn_Ở_Đây
   PORT=3000
   ```
5. Khởi động server:
   ```bash
   node index.js
   ```
   *Khi Terminal xuất hiện dòng `HRBot Backend proxy (Gemini-Fallback) listening on port 3000` nghĩa là server đã sẵn sàng hoạt động.*

### 🛡️ Cơ Chế Tự Động Chuyển Đổi Model Dự Phòng (Fallback)
Server được thiết kế thông minh để tự động chuyển đổi giữa các mô hình Gemini trong danh sách dự phòng (`gemini-flash-latest`, `gemini-2.5-flash`, `gemini-2.0-flash`, `gemini-flash-lite-latest`) nếu mô hình chính gặp lỗi quá tải tạm thời (lỗi 503) hoặc chạm hạn mức miễn phí (Rate Limit - 15 RPM). Điều này giúp cuộc hội thoại của ứng viên luôn diễn ra liên tục, mượt mà.

---

## 📱 Hướng Dẫn Khởi Chạy Ứng Dụng Flutter
1. Đảm bảo bạn đã cài đặt Flutter SDK mới nhất trên máy tính.
2. Tại thư mục gốc dự án, tải về các dependency của Flutter:
   ```bash
   flutter pub get
   ```
3. Khởi chạy ứng dụng bằng cách kết nối thiết bị di động/máy ảo và gõ lệnh:
   ```bash
   flutter run
   ```
4. Trải nghiệm chức năng Chat AI tại tab **Xu Hướng AI** trên màn hình dành cho Ứng viên.
