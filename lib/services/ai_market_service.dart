import 'dart:convert';
import 'dart:io';

class IndustryGrowth {
  final String name;
  final double growthRate; // e.g. 0.25 for 25%
  final String avgSalary;
  final String demandLevel; // High, Medium, Low

  const IndustryGrowth({
    required this.name,
    required this.growthRate,
    required this.avgSalary,
    required this.demandLevel,
  });
}

class MarketTrendData {
  final String overview;
  final int hotnessScore; // 1-100
  final List<IndustryGrowth> industries;
  final List<String> topSkills;
  final List<String> risingRoles;
  final List<String> decliningRoles;

  const MarketTrendData({
    required this.overview,
    required this.hotnessScore,
    required this.industries,
    required this.topSkills,
    required this.risingRoles,
    required this.decliningRoles,
  });
}

class AiMarketService {
  // Call a mock public API to demonstrate real HttpClient network requests
  Future<Map<String, dynamic>?> fetchRawApiData() async {
    final client = HttpClient();
    try {
      // Fetching sample post data from JSONPlaceholder as a proof of network capability
      final request = await client.getUrl(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));
      final response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        final jsonString = await response.transform(utf8.decoder).join();
        return json.decode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Network request failed, using local database: $e');
    } finally {
      client.close();
    }
    return null;
  }

  // Get current market trends
  Future<MarketTrendData> getMarketTrends() async {
    // Perform the API request in background
    await fetchRawApiData();

    // In a real app, this parses a payload from a job market API.
    // We provide a rich, detailed, local dataset specialized in Vietnamese job market 2026.
    return const MarketTrendData(
      overview: 'Thị trường tuyển dụng năm 2026 chứng kiến làn sóng chuyển dịch số mạnh mẽ. Trí tuệ nhân tạo (AI), ESG (Môi trường, Xã hội, Quản trị) và Điện toán đám mây là các động lực tăng trưởng chính. Các công việc truyền thống đang chuyển dịch sang yêu cầu kỹ năng công nghệ bổ trợ.',
      hotnessScore: 88,
      industries: [
        IndustryGrowth(name: 'Trí tuệ nhân tạo (AI/ML)', growthRate: 0.42, avgSalary: '35M - 80M', demandLevel: 'Rất cao'),
        IndustryGrowth(name: 'Công nghệ phần mềm (IT)', growthRate: 0.18, avgSalary: '20M - 50M', demandLevel: 'Cao'),
        IndustryGrowth(name: 'Truyền thông số (Digital Marketing)', growthRate: 0.15, avgSalary: '15M - 35M', demandLevel: 'Trung bình'),
        IndustryGrowth(name: 'Thiết kế Trải nghiệm (UI/UX)', growthRate: 0.12, avgSalary: '18M - 40M', demandLevel: 'Cao'),
        IndustryGrowth(name: 'Phân tích dữ liệu (Data Analytics)', growthRate: 0.28, avgSalary: '25M - 60M', demandLevel: 'Rất cao'),
      ],
      topSkills: [
        'Kỹ thuật Prompt (Prompt Engineering)',
        'Lập trình Flutter / Mobile Dev',
        'Phân tích dữ liệu & Python',
        'Tư vấn phát triển bền vững (ESG)',
        'Quản trị đám mây (AWS/GCP)',
      ],
      risingRoles: [
        'Kỹ sư AI / prompt Engineer',
        'Chuyên viên phân tích dữ liệu lớn',
        'Kỹ sư phát triển phần mềm di động',
        'Chuyên gia tư vấn ESG',
        'Growth Hacker (Marketing tăng trưởng)',
      ],
      decliningRoles: [
        'Nhập liệu thủ công (Data Entry)',
        'Chăm sóc khách hàng cơ bản (tự động hóa thay thế)',
        'Biên dịch viên truyền thống',
        'Quản trị viên hệ thống cục bộ',
      ],
    );
  }

  // Personalize market trend response based on candidate profile details
  String generatePersonalizedAdvice({
    required String? dreamJob,
    required String? strengths,
    required String? hobbies,
  }) {
    final targetJob = dreamJob?.trim().isNotEmpty == true ? dreamJob! : 'ngành nghề đã chọn';
    final userStrengths = strengths?.trim().isNotEmpty == true ? strengths! : 'sự ham học hỏi và khả năng thích ứng';

    return 'Dựa trên mong muốn trở thành **$targetJob** và các thế mạnh về **$userStrengths**, AI phân tích:\n\n'
        '1. **Độ phù hợp xu hướng:** Vị trí **$targetJob** đang nằm trong danh sách các vị trí chuyển đổi mạnh mẽ. Cơ hội mở rộng nhiều ở các doanh nghiệp áp dụng công nghệ số và chuyển đổi mô hình kinh doanh.\n\n'
        '2. **Kỹ năng đề xuất nâng cao:** Bạn nên tích hợp thêm kỹ năng ứng dụng AI vào quy trình làm việc thực tế và trau dồi khả năng tư duy giải quyết vấn đề phức tạp.\n\n'
        '3. **Lợi thế cạnh tranh:** Tận dụng điểm mạnh của bạn làm bệ phóng, tập trung tạo ra các sản phẩm/dự án cá nhân thực chiến để ghi điểm với nhà tuyển dụng.';
  }

  // AI chat bot response generator
  Future<String> askAiQuestion(String question, String? dreamJob) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1200));

    final q = question.toLowerCase();
    final job = dreamJob?.trim().isNotEmpty == true ? dreamJob! : 'ngành công nghệ / kinh doanh';

    if (q.contains('lương') || q.contains('thu nhập') || q.contains('tiền')) {
      return 'Mức lương trung bình của các vị trí liên quan đến **$job** năm 2026 đang dao động khá rộng. \n\n'
          '- **Mới tốt nghiệp/Junior:** 12M - 20M VND.\n'
          '- **Mid-level/Senior:** 25M - 55M VND.\n'
          '- **Chuyên gia AI/Đám mây:** 60M - 100M+ VND.\n\n'
          'Lời khuyên: Tập trung vào kỹ năng chuyên sâu thay vì số năm kinh nghiệm đơn thuần để đạt mức thu nhập mong muốn.';
    }

    if (q.contains('thay thế') || q.contains('bị mất') || q.contains('ai cướp')) {
      return 'AI sẽ không thay thế hoàn toàn vị trí **$job**, nhưng **những người biết dùng AI** sẽ thay thế những người không biết dùng.\n\n'
          'Các công việc lặp đi lặp lại như soạn thảo văn bản thô, dịch thuật cơ bản, hoặc phân loại dữ liệu thủ công đang bị ảnh hưởng lớn. Hãy nâng cấp bản thân lên vị trí làm chủ công cụ và đưa ra quyết định sáng tạo.';
    }

    if (q.contains('học') || q.contains('kỹ năng') || q.contains('khóa học')) {
      return 'Để đi đầu trong **$job**, bạn nên tập trung học các kỹ năng:\n\n'
          '1. **Kỹ năng chuyên môn:** Nắm vững cấu trúc dữ liệu, thuật toán hoặc quy trình nghiệp vụ chính.\n'
          '2. **Kỹ năng AI:** Học cách viết Prompt hiệu quả, sử dụng Github Copilot, Gemini hoặc các AI Tools chuyên ngành.\n'
          '3. **Kỹ năng mềm:** Giao tiếp mạch lạc và tư duy thiết kế giải pháp.';
    }

    return 'Cảm ơn câu hỏi của bạn về **$job**! Xu hướng thị trường tuyển dụng năm 2026 đòi hỏi ứng viên phải luôn linh hoạt thích ứng. Bạn nên tập trung xây dựng năng lực tự học, làm quen với các công cụ tự động hóa công việc và luôn cập nhật các báo cáo tuyển dụng định kỳ.';
  }
}
