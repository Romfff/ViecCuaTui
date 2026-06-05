import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../services/ai_market_service.dart';

const _kBg = Color(0xFFF8F9FB);
const _kNavy = Color(0xFF0D1B4B);
const _kAccent = Color(0xFF0FB488);
const _kAccentLight = Color(0xFF43E8D8);
const _kTextSub = Color(0xFF8E8E93);

class MarketTrendScreen extends StatefulWidget {
  const MarketTrendScreen({super.key});

  @override
  State<MarketTrendScreen> createState() => _MarketTrendScreenState();
}

class _MarketTrendScreenState extends State<MarketTrendScreen> {
  final AiMarketService _aiService = AiMarketService();
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  bool _isLoading = true;
  MarketTrendData? _trendData;
  final List<Map<String, String>> _chatMessages = [];
  bool _isAiTyping = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Add default greeting
    _chatMessages.add({
      'sender': 'ai',
      'text': 'Xin chào! Tôi là Trợ lý AI phân tích thị trường. Bạn muốn hỏi điều gì về xu hướng việc làm, mức lương hay kỹ năng cần học cho định hướng của mình?',
    });
  }

  Future<void> _loadData() async {
    try {
      final data = await _aiService.getMarketTrends();
      setState(() {
        _trendData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _askQuestion(String dreamJob) async {
    final text = _questionController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatMessages.add({
        'sender': 'user',
        'text': text,
      });
      _questionController.clear();
      _isAiTyping = true;
    });
    _scrollToBottom();

    try {
      final answer = await _aiService.askAiQuestion(text, dreamJob);
      setState(() {
        _chatMessages.add({
          'sender': 'ai',
          'text': answer,
        });
        _isAiTyping = false;
      });
    } catch (e) {
      setState(() {
        _chatMessages.add({
          'sender': 'ai',
          'text': 'Rất tiếc, tôi đang gặp gián đoạn kết nối. Hãy thử lại sau nhé!',
        });
        _isAiTyping = false;
      });
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dreamJob = auth.dreamJob ?? 'ngành nghề đã chọn';

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _kBg,
        body: Center(child: CircularProgressIndicator(color: _kAccent)),
      );
    }

    final personalizedAdvice = _aiService.generatePersonalizedAdvice(
      dreamJob: auth.dreamJob,
      strengths: auth.strengths,
      hobbies: auth.hobbies,
    );

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Xu Hướng Thị Trường AI',
          style: TextStyle(
            color: _kNavy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Market Overview Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng quan xu hướng',
                        style: TextStyle(
                          color: _kNavy,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _kAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Hot Score: ${_trendData?.hotnessScore ?? 80}/100',
                          style: const TextStyle(
                            color: _kAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _trendData?.overview ?? '',
                    style: const TextStyle(
                      color: _kNavy,
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Growth Chart Card
            if (_trendData != null)
              _MarketChart(industries: _trendData!.industries),
            const SizedBox(height: 20),

            // Skills & Roles Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kỹ năng bứt phá năm 2026',
                    style: TextStyle(
                      color: _kNavy,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...?_trendData?.topSkills.map((skill) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: _kAccent, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                skill,
                                style: const TextStyle(color: _kNavy, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Personalized Advice Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _kAccent.withOpacity(0.06),
                    _kAccentLight.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kAccent.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology, color: _kAccent),
                      SizedBox(width: 8),
                      Text(
                        'AI gợi ý riêng cho bạn',
                        style: TextStyle(
                          color: _kNavy,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    personalizedAdvice,
                    style: const TextStyle(
                      color: _kNavy,
                      height: 1.6,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Q&A Chat Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hỏi đáp nhanh với Trợ lý AI',
                    style: TextStyle(
                      color: _kNavy,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Chat window
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _kBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListView.builder(
                      controller: _chatScrollController,
                      itemCount: _chatMessages.length + (_isAiTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _chatMessages.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'AI đang phân tích...',
                                style: TextStyle(color: _kTextSub, fontSize: 11, fontStyle: FontStyle.italic),
                              ),
                            ),
                          );
                        }
                        final msg = _chatMessages[index];
                        final isAi = msg['sender'] == 'ai';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Align(
                            alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isAi ? Colors.white : _kAccent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isAi
                                    ? [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4)]
                                    : null,
                              ),
                              child: Text(
                                msg['text'] ?? '',
                                style: TextStyle(
                                  color: isAi ? _kNavy : Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Chat input bar
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _questionController,
                          style: const TextStyle(fontSize: 13, color: _kNavy),
                          decoration: InputDecoration(
                            hintText: 'Hỏi AI (lương, xu hướng, kỹ năng...)',
                            fillColor: _kBg,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _askQuestion(dreamJob),
                        icon: const Icon(Icons.send_rounded, color: _kAccent),
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
}

class _MarketChart extends StatelessWidget {
  final List<IndustryGrowth> industries;

  const _MarketChart({required this.industries});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tốc độ tăng trưởng năm 2026',
            style: TextStyle(
              color: _kNavy,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ...industries.map((ind) {
            final percent = (ind.growthRate * 100).toStringAsFixed(0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ind.name,
                        style: const TextStyle(
                          color: _kNavy,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '+$percent%',
                        style: const TextStyle(
                          color: _kAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween<double>(begin: 0, end: ind.growthRate),
                        builder: (context, value, child) {
                          return FractionallySizedBox(
                            widthFactor: value,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    _kAccentLight,
                                    _kAccent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Lương TB: ${ind.avgSalary}',
                        style: const TextStyle(color: _kTextSub, fontSize: 11),
                      ),
                      const Spacer(),
                      Text(
                        'Nhu cầu: ${ind.demandLevel}',
                        style: TextStyle(
                          color: ind.demandLevel == 'Rất cao' ? _kAccent : _kNavy,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
