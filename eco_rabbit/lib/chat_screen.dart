import 'package:flutter/material.dart';
import 'dart:math' as math;

class ChatScreen extends StatefulWidget {
  // ✅ 接收从 Home 传来的上下文 (可选)
  final Map<String, dynamic>? initialContext;

  const ChatScreen({super.key, this.initialContext});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 通用开场白 (Tab 3 模式)
  static const String _genericWelcome =
      "Hi Alex! 👋 我是你的 EcoHabit 房产顾问。\n\n"
      "你可以问我关于 KL 任何区域的 **交通预测**、**租金趋势** 或 **宜居程度**。\n\n"
      "试试问：\n"
      "• Compare Cheras and Setapak\n"
      "• 5-year rental growth";

  // 聊天记录列表
  final List<Map<String, dynamic>> _messages = [];

  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // ✅ 初始化：判断是“通用模式”还是“房源分析模式”
    _initConversation();
  }

  void _initConversation() {
    String welcomeText;

    if (widget.initialContext != null) {
      // 模式 B: 从 Home 卡片进来 (有 Context)
      final ctx = widget.initialContext!;
      welcomeText = 
          "Hi! 我看到你对 **${ctx['title']}** 感兴趣。🏡\n\n"
          "已知你的工作地点在 **${ctx['workplace']}**，预算约 **${ctx['budget']}**。\n\n"
          "关于这个房源，你可以问我：\n"
          "1. 它的真实通勤时间 (Commute Reality)？\n"
          "2. 这里的未来租金预测？\n"
          "3. 相比 Setapak 这里的优势？";
    } else {
      // 模式 A: 从底部导航栏进来 (通用)
      welcomeText = _genericWelcome;
    }

    _messages.add({"isUser": false, "text": welcomeText});
  }

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

    // 1. 用户消息上屏
    setState(() {
      _messages.add({"isUser": true, "text": text});
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    // 2. 模拟 AI 思考延迟
    await Future.delayed(const Duration(seconds: 2));

    final input = text.toLowerCase();
    
    // --- 智能逻辑路由 ---

    // A. 租金增长图表 (Chart)
    if (input.contains("5 years") || input.contains("growth") || input.contains("rental") || input.contains("租金")) {
      _addChartResponse();
      return;
    }

    // B. 针对 Context 的特定回答 (如果从 Home 进来)
    if (widget.initialContext != null && (input.contains("commute") || input.contains("time") || input.contains("通勤"))) {
       final workplace = widget.initialContext!['workplace'];
       final title = widget.initialContext!['title'];
       _addTextResponse(
           "根据 GTFS 实时数据，从 **$title** 到 **$workplace**：\n\n"
           "🟢 **MRT:** 35 分钟 (准时)\n"
           "🔴 **开车:** 早高峰需 1小时 10分钟 (高拥堵)\n\n"
           "建议：选择公共交通，每天可节省 35 分钟。"
       );
       return;
    } 

    // C. 通用回答 (Keyword Based)
    if (input.contains("cheras") || input.contains("why") || input.contains("推荐")) {
      // 触发推荐卡片
      _addPropertyRecommendation();
      return;
    } 
    
    if (input.contains("setapak") || input.contains("traffic") || input.contains("堵车")) {
      _addTextResponse(
          "⚠️ **高拥堵风险 (High Traffic Stress)**\n\n"
          "Setapak 区域在 7:30 AM 的拥堵指数高达 9/10。\n"
          "🔴 Jalan Genting Klang 平均车速仅 15km/h。\n\n"
          "除非你居家办公，否则建议避开。"
      );
      return;
    }

    if (input.contains("price") || input.contains("cheap") || input.contains("便宜")) {
      _addTextResponse(
          "💰 **价格 vs 价值分析**\n\n"
          "Setapak 看起来更便宜 (RM1100)，但存在大量隐形成本：\n"
          "❌ Setapak: 房租 1100 + 养车 ~600 ≈ RM 1700+\n"
          "✅ Cheras: 房租 1300 + MRT ~50 ≈ RM 1350\n\n"
          "EcoHabit 帮你算的是**综合生活成本**。"
      );
      return;
    }

    // D. 默认回复
    _addTextResponse(
      "收到！正在调用 Gemini API 分析该区域的 Urban Density 和 Traffic Flow...\n\n"
      "(Demo 提示: 试试问 'Why Cheras' 或 '5 years growth')"
    );
  }

  void _addTextResponse(String text) {
    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add({"isUser": false, "text": text});
    });
    _scrollToBottom();
  }

  void _addChartResponse() {
    const baseRent = 1300.0;
    const growthRate = 0.04;
    final List<double> projected = List.generate(
        5, (i) => baseRent * math.pow(1 + growthRate, i).toDouble());

    const explanation = "📈 基于 Demo 数据的未来 5 年租金增长预测：\n"
        "假设每年约 4% 增长，该区域资产增值潜力巨大。";

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
  }

  void _addPropertyRecommendation() {
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
        "propertyCard": propertyData,
      });
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    // 只有从 Home 跳转过来才显示 AppBar 返回键
    final bool showBackButton = widget.initialContext != null;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F6),
      appBar: showBackButton 
        ? AppBar(
            title: const Text("AI Insight", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            backgroundColor: Colors.white,
            elevation: 1,
            iconTheme: const IconThemeData(color: Colors.black),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          )
        : null,
      
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
                    // 只有 Tab 模式才显示那个漂亮的 Header
                    if (!showBackButton) _buildModernHeader(),
                    
                    const SizedBox(height: 8),
                    
                    // ✅ 如果有 Context，显示房源信息 Chip
                    if (widget.initialContext != null) 
                      _buildContextInfoCard(widget.initialContext!),
                    
                    // ✅ 如果没有 Context，显示通用 Chips
                    if (widget.initialContext == null)
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

                                // 渲染图表
                                if (msg["chartData"] != null) {
                                  return _buildChartBubble(
                                    text: text,
                                    data: (msg["chartData"] as List).cast<double>(),
                                  );
                                }

                                // 渲染卡片
                                if (msg["propertyCard"] != null) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildMessageBubble(isUser: isUser, text: text),
                                      _buildPropertyCardBubble(msg["propertyCard"]),
                                    ],
                                  );
                                }

                                // 渲染普通文字
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

  // --- Widget: 显示当前讨论房源 ---
  Widget _buildContextInfoCard(Map<String, dynamic> ctx) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.home, size: 16, color: Colors.teal),
          const SizedBox(width: 8),
          Text("Discussing: ${ctx['title']}", style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  // --- Widget: 房源推荐卡片 ---
  Widget _buildPropertyCardBubble(Map<String, dynamic> data) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15, left: 4, right: 20),
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.teal.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(color: Colors.teal.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                data['image'],
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) => Container(height: 140, color: Colors.grey[200], child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey))),
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
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Navigating to Map Details...")));
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

  // --- Widget: Header ---
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
            onPressed: () => setState(() { _messages.clear(); _initConversation(); _isTyping = false; }),
          ),
        ],
      ),
    );
  }

  // --- Widget: Scenario Chips ---
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

  // --- Widget: Input Container ---
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

  // --- Widget: Suggestion Chips ---
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

  // --- Widget: Input Area ---
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

  // --- Widget: Text Bubble ---
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

  // --- Widget: Chart Bubble ---
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

  // --- Widget: Typing Indicator ---
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

// --- Widget: Simple Scenario Chip ---
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