import 'package:flutter/material.dart';
import 'dart:math' as math;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 初始 AI 文案
  static const String _initialAiText =
      "Hi Alex! 👋 我是你的 EcoHabit 房产顾问。\n\n"
      "我已经结合 GTFS 交通数据 和 房租趋势 分析了你的情况。\n\n"
      "你可以直接点击下方按钮，或问我任何问题。";

  /// 消息结构：
  /// { 
  ///   "isUser": bool, 
  ///   "text": String, 
  ///   "chartData": List<double>?, 
  ///   "propertyCard": Map<String, dynamic>?  <-- 新增这个字段
  /// }
  final List<Map<String, dynamic>> _messages = [
    {"isUser": false, "text": _initialAiText}
  ];

  bool _isTyping = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  Future<void> _sendMessage([String? preset]) async {
    if (_isTyping) return;

    final text = preset ?? _controller.text.trim();
    if (text.isEmpty) return;

    // 1. 用户消息
    setState(() {
      _messages.add({"isUser": true, "text": text});
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    // 2. 模拟 AI 思考
    await Future.delayed(const Duration(seconds: 2));

    final input = text.toLowerCase();

    // ====== 场景 A：图表 (5 Year Growth) ======
    final bool askRentalGrowth = (
      (input.contains("5 years") || input.contains("5-year") || input.contains("5 year") || input.contains("5年")) &&
      (input.contains("rent") || input.contains("rental") || input.contains("rental fee") || input.contains("租金"))
    );

    if (askRentalGrowth) {
      const baseRent = 1300.0;
      const growthRate = 0.04;
      final List<double> projected = List.generate(
        5,
        (i) => baseRent * math.pow(1 + growthRate, i).toDouble(),
      );

      const explanation = "📈 这是基于 Demo 数据的未来 5 年租金增长预测（以 Cheras 为例）：\n\n"
          "假设每年约 4% 增长，现在签长约会更划算。";

      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add({"isUser": false, "text": explanation});
        _messages.add({
          "isUser": false,
          "text": "未来 5 年租金预测",
          "chartData": projected,
        });
      });
      _scrollToBottom();
      return;
    }

    // ====== 场景 B：房源推荐 (Cheras) -> 触发卡片! ======
    if (input.contains("cheras") || input.contains("推荐") || input.contains("recommend")) {
      const aiResponse =
          "根据模型分析，我强烈推荐 **Cheras** 🌟。\n\n"
          "📊 **关键数据对比：**\n"
          "• Last-Mile：步行 400m 即达 MRT，完美避开拥堵。\n"
          "• 早高峰车速预估比 Setapak 快 45%。\n\n"
          "👇 **我为你锁定了这个高匹配度房源：**";

      // 模拟房源数据
      final propertyData = {
        "title": "Cheras Green Condo",
        "price": "RM 1,300",
        "image": "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
        "score": 92,
        "location": "Cheras, KL"
      };

      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add({
          "isUser": false,
          "text": aiResponse,
          "propertyCard": propertyData, // 这里的 propertyCard 触发卡片渲染
        });
      });
      _scrollToBottom();
      return;
    }

    // ====== 场景 C：普通文本回复 (Setapak / Price / Default) ======
    String aiResponse;
    if (input.contains("setapak") || input.contains("traffic") || input.contains("堵车")) {
      aiResponse =
          "⚠️ **高拥堵风险 (High Traffic Stress)**\n\n"
          "Setapak 虽然房租便宜 (RM1100)，但根据 Kaggle GTFS 数据，\n"
          "该区域在 7:30 AM 的拥堵指数高达 9/10。\n\n"
          "🔴 **痛点：** Jalan Genting Klang 平均车速仅 15km/h，每天多花 50分钟通勤。";
    } else if (input.contains("price") || input.contains("cheap") || input.contains("便宜")) {
      aiResponse =
          "💰 **价格 vs 价值分析**\n\n"
          "Setapak 看起来更便宜 (RM1100)，但存在大量隐形成本：\n"
          "❌ Setapak: 房租 1100 + 养车 ~600 ≈ RM 1700+\n"
          "✅ Cheras: 房租 1300 + MRT ~50 ≈ RM 1350\n\n"
          "EcoHabit 帮你算的是**综合生活成本**。";
    } else {
      aiResponse =
          "收到！正在分析该区域的 Urban Density 和 Traffic Flow...\n\n"
          "(Demo: 试试问 'Why Cheras' 来看**房源推荐卡片**，或问 '5 years rental growth' 看**图表**)";
    }

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add({"isUser": false, "text": aiResponse});
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F6),
      body: Stack(
        children: [
          Positioned(
            right: -50, top: 100,
            child: Icon(Icons.eco, size: 300, color: Colors.teal.withOpacity(0.05)),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    _buildModernHeader(),
                    const SizedBox(height: 8),
                    _buildScenarioCard(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                              itemCount: _messages.length + (_isTyping ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (_isTyping && index == _messages.length) {
                                  return _buildTypingIndicator();
                                }
                                final msg = _messages[index];
                                final isUser = msg["isUser"] as bool? ?? false;
                                final text = msg["text"] as String? ?? "";

                                // 1. 渲染图表气泡
                                if (msg["chartData"] != null) {
                                  return _buildChartBubble(
                                    text: text,
                                    data: (msg["chartData"] as List).cast<double>(),
                                  );
                                }

                                // 2. 渲染房源推荐卡片 (新功能) 🚀
                                if (msg["propertyCard"] != null) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 先显示文字气泡
                                      _buildMessageBubble(isUser: isUser, text: text),
                                      // 再显示卡片
                                      _buildPropertyCardBubble(msg["propertyCard"]),
                                    ],
                                  );
                                }

                                // 3. 普通文字气泡
                                return _buildMessageBubble(isUser: isUser, text: text);
                              },
                            ),
                          ),
                          _buildInputContainer(),
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
    );
  }

  // --- 🔥 新增组件：房源推荐卡片 ---
  Widget _buildPropertyCardBubble(Map<String, dynamic> data) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15, left: 4, right: 20),
        width: 280, // 卡片固定宽度
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.teal.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6)
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 房源图片
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                data['image'],
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) => Container( // 图片加载失败时的占位
                  height: 140,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(data['price'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 15)),
                      Text(data['location'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Eco Score 标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.eco, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Text("Eco-Score: ${data['score']}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green[800])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 按钮
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Navigating to Map Details..."))
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text("View Details"),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- 原有 UI 组件 ---
  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.teal, width: 2)),
            child: const CircleAvatar(backgroundColor: Colors.teal, radius: 18, child: Icon(Icons.smart_toy, color: Colors.white, size: 20)),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("EcoHabit Insight Agent", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text("Powered by Gemini AI", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ]),
          ]),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: () => setState(() { _messages.clear(); _messages.add({"isUser": false, "text": _initialAiText}); _isTyping = false; }),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Wrap(spacing: 8, runSpacing: 4, children: const [
          _ScenarioChip(icon: Icons.work_outline, label: "Work: KL Sentral"),
          _ScenarioChip(icon: Icons.account_balance_wallet_outlined, label: "Budget: RM1500"),
          _ScenarioChip(icon: Icons.directions_subway_outlined, label: "Prefer near MRT"),
        ]),
      ),
    );
  }

  Widget _buildInputContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSuggestionChips(),
          const SizedBox(height: 10),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips() {
    final suggestions = ["⚔️ Cheras vs Setapak", "📈 5-year rental growth"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: suggestions.map((s) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ActionChip(
          label: Text(s, style: TextStyle(color: Colors.teal[800], fontWeight: FontWeight.w600, fontSize: 12)),
          backgroundColor: Colors.teal[50],
          side: BorderSide(color: Colors.teal.withOpacity(0.2)),
          avatar: const Icon(Icons.flash_on, size: 16, color: Colors.teal),
          onPressed: () => _sendMessage(s),
        ),
      )).toList()),
    );
  }

  Widget _buildInputArea() {
    return Row(children: [
      Expanded(
        child: TextField(
          controller: _controller,
          onSubmitted: (_) => _sendMessage(),
          decoration: InputDecoration(
            hintText: "Ask AI advisor...",
            filled: true, fillColor: const Color(0xFFF5F7FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ),
      const SizedBox(width: 10),
      FloatingActionButton(
        mini: true, onPressed: () => _sendMessage(),
        backgroundColor: Colors.teal, child: const Icon(Icons.send, size: 18, color: Colors.white),
      ),
    ]);
  }

  Widget _buildMessageBubble({required bool isUser, required String text}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          gradient: isUser ? const LinearGradient(colors: [Color(0xFF009688), Color(0xFF4DB6AC)]) : null,
          color: isUser ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20), topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(5),
            bottomRight: isUser ? const Radius.circular(5) : const Radius.circular(20),
          ),
          boxShadow: [
            isUser 
              ? BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
              : BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text("AI ANALYSIS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal[800], letterSpacing: 1)),
            ),
            Text(text, style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBubble({required String text, required List<double> data}) {
    final maxValue = data.isEmpty ? 0.0 : data.reduce(math.max);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 3))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("RENTAL PROJECTION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal, letterSpacing: 1.1)),
            const SizedBox(height: 6),
            Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3)),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(data.length, (index) {
                  final value = data[index];
                  final factor = maxValue == 0 ? 0.0 : value / maxValue;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 18, height: 100 * factor,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), gradient: const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xFF2E7D32), Color(0xFF81C784)])),
                      ),
                      const SizedBox(height: 6),
                      Text("Y${index + 1}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                      Text("RM${value.toStringAsFixed(0)}", style: const TextStyle(fontSize: 10, color: Colors.black54)),
                    ],
                  );
                }),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.teal)),
          const SizedBox(width: 10),
          Text("Analyzing traffic & rent data...", style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic)),
        ]),
      ),
    );
  }
}

class _ScenarioChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ScenarioChip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: Colors.black54), const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11.5)),
      ]),
    );
  }
}