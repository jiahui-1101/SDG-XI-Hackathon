import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'secrets.dart';

class ChatScreen extends StatefulWidget {
  // 接收从 Home 传来的上下文 (可选)
  final Map<String, dynamic>? initialContext;

  const ChatScreen({super.key, this.initialContext});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ✅ 1. 配置 API Key
  static const String _apiKey = googleGeminiApiKey;
  
  GenerativeModel? _model;
  
  // 判断是否使用真 AI
  bool get _useRealAI => _apiKey.isNotEmpty;

  // --- 🇲🇾 初始欢迎语文案 (Mock) ---
  
  // 1. Standard Mode (Professional Manglish)
  static const String _standardWelcome =
      "Hello boss! 👋 EcoHabit agent here.\n\n"
      "I connected to **Gemini Pro** already. Can help you check KL traffic, rental price, or see which area 'ong' for you.\n\n"
      "What you want to ask today?";

  // 2. Auntie Mode (Funny Manglish)
  static const String _auntieWelcome = 
      "Hello boy! 👋 Auntie here to help you find house.\n\n"
      "Don't worry, Auntie know everything about KL property and where got jam.\n\n"
      "What you want to know? Cheap one or near MRT?";

  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _isAuntieMode = false;

  @override
  void initState() {
    super.initState();
    _initGemini();
    // 初始化时，清空历史 (isSwitchingMode = false)
    _initConversation(isSwitchingMode: false);
  }

  void _initGemini() {
    if (_useRealAI) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash', // 改回最新的 flash 模型
        apiKey: _apiKey,
        generationConfig: GenerationConfig(temperature: 0.9),
      );
    }
  }

  // ✅ 核心修改：初始化/重置对话逻辑
  void _initConversation({bool isSwitchingMode = false}) {
    String welcomeText;
    
    if (widget.initialContext != null) {
      // 如果是从 Home 卡片进来 (带 Context)
      final ctx = widget.initialContext!;
      if (_isAuntieMode) {
         welcomeText = "Wah! You eyeing **${ctx['title']}** is it? 🏡\n\n"
            "Working at **${ctx['workplace']}**, budget around **${ctx['budget']}**.\n\n"
            "Okay, Auntie tell you truth:\n"
            "1. Got jam or not? (Commute)\n"
            "2. Price worth it meh? (Value)";
      } else {
         welcomeText = "Hi! Looking at **${ctx['title']}**? 🏡\n\n"
            "Workplace: **${ctx['workplace']}**\nBudget: **${ctx['budget']}**\n\n"
            "I can analyze:\n"
            "1. Real commute time (Traffic)\n"
            "2. Hidden costs & Value";
      }
    } else {
      // 如果是 Tab 进来 (无 Context)
      welcomeText = _isAuntieMode ? _auntieWelcome : _standardWelcome;
    }
    
    setState(() {
      // 关键修改：如果是切换模式，不清空，只追加
      // (如果你想清空，就把 !isSwitchingMode 改成 true)
      // 这里根据你的要求：切换 mode 重新发初始信息，不清空旧记录
      // if (!isSwitchingMode) { _messages.clear(); } 
      
      _messages.add({"isUser": false, "text": welcomeText});
    });

    // 如果是切换模式，自动滚动到底部看新消息
    if (isSwitchingMode) {
      _scrollToBottom();
    }
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

    setState(() {
      _messages.add({"isUser": true, "text": text});
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    // 模拟思考 UI
    await Future.delayed(const Duration(seconds: 1));

    final input = text.toLowerCase();
    
    // ====== 1. 特殊 UI 拦截 (Mock 逻辑) ======

    // A. 租金增长图表 (Chart)
    if (input.contains("5 years") || input.contains("growth") || input.contains("chart") || input.contains("rental")) {
      _addChartResponse();
      return;
    }

    // B. 房源推荐 (Property Card)
    if (input.contains("cheras") || input.contains("best match") || input.contains("推荐")) {
       _addPropertyRecommendation();
       return;
    } 
    
    // C. 毒舌模式 (Roast)
    if (input.contains("roast")) {
       String reply;
       if (_isAuntieMode) {
         reply = "Aiyo boy! You still looking at **Setapak**? 👵💢\n\n"
             "You crazy ah? That road jam until you can finish watching whole K-Drama inside car!\n"
             "Your car air-con spoil also never reach home yet.\n\n"
             "Don't be stubborn, listen to Auntie: Find place near MRT lah!";
       } else {
         reply = "😤 **AI Roast Mode:**\n\n"
             "Setapak? Bro, are you trying to speedrun burnout?\n"
             "Living there means donating 15% of your life to traffic jams.\n"
             "Do your mental health a favor: Choose Cheras.";
       }
       _addTextResponse(reply);
       return;
    }

    // ====== 2. 真实 AI 接管 (Gemini API - 联网时) ======
    if (_useRealAI) {
      try {
        // 🔥 动态构建 System Prompt (分类处理)
        String systemInstruction;
        
        if (_isAuntieMode) {
           // Auntie Mode Prompt
           systemInstruction = "You are a funny Malaysian Auntie housing consultant. "
               "Speak in heavy Manglish (lah, meh, aiyo, walao). "
               "Be direct, slightly nagging but caring. Keep it short. "
               "User asks: ";
        } else {
           // Standard Mode Prompt
           systemInstruction = "You are EcoHabit, a professional housing consultant in Malaysia. "
               "Speak in standard Malaysian English (professional but local context). "
               "Be data-driven and concise. Focus on SDG 11. "
               "User asks: ";
        }

        // 发送请求
        final content = [Content.text(systemInstruction + text)];
        
        final response = await _model!.generateContent(content);
        final aiText = response.text ?? "Aiyo, internet connection problem lah.";
        
        _addTextResponse(aiText);
        return; 

      } catch (e) {
        print("Gemini Error: $e");
      }
    }

    // ====== 3. 兜底 Mock 逻辑 (没有 Key 或 断网) ======
    _fallbackMockResponse(input);
  }

  void _fallbackMockResponse(String input) {
     String reply;
     
     if (input.contains("setapak") || input.contains("traffic")) {
        if (_isAuntieMode) {
           reply = "⚠️ **Auntie Warning:**\n\nSetapak jam gila! Morning 7am confirm stuck. Better you find MRT house.";
        } else {
           reply = "⚠️ **Traffic Alert:**\n\nSetapak area has high congestion (Index 9/10). Average speed 15km/h.";
        }
     } else if (input.contains("price") || input.contains("cheap")) {
        if (_isAuntieMode) {
           reply = "💰 **Auntie Math:**\n\nCheap rent but expensive petrol! You count properly. Cheras got MRT, save money save time.";
        } else {
           reply = "💰 **Cost Benefit:**\n\nSetapak has lower rent, but higher hidden costs (fuel + time). Cheras offers better value via public transport.";
        }
     } else {
        reply = _isAuntieMode 
            ? "Aiya, I don't understand. Ask me 'Why Cheras' or click that 'Roast' button lah!" 
            : "Received. Analyzing data... (Demo Mode: Try asking 'Why Cheras' or 'Roast Setapak')";
     }
     
     _addTextResponse(reply);
  }

  void _addTextResponse(String text) {
    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add({"isUser": false, "text": text});
    });
    _scrollToBottom();
  }

  // --- UI Widget Helpers ---

  void _addChartResponse() {
    const baseRent = 1300.0;
    const growthRate = 0.04;
    final List<double> projected = List.generate(
        5, (i) => baseRent * math.pow(1 + growthRate, i).toDouble());

    final explanation = _isAuntieMode
       ? "📈 **See Auntie tell you!**\nPrice go up 4% every year! Buy now wait for durian drop ah?"
       : "📈 **Market Prediction:**\nBased on historical data, expect ~4% yearly rental growth.";

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add({"isUser": false, "text": explanation});
      _messages.add({
        "isUser": false,
        "text": "Rental Forecast",
        "chartData": projected,
      });
    });
    _scrollToBottom();
  }

  void _addPropertyRecommendation() {
      final aiResponse = _isAuntieMode
          ? "Auntie recommend this **Cheras** one! 👍\n\n"
            "• MRT so near, walk 5 mins reach.\n"
            "• No jam in morning, can sleep more.\n"
            "👇 **See this one, very nice:**"
          : "Based on our analysis, **Cheras** is the Top Pick 🌟.\n\n"
            "• **Efficiency:** 40% less time in traffic.\n"
            "• **Connectivity:** 400m to MRT station.\n"
            "👇 **Best Match Property:**";

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
    final bool showBackButton = widget.initialContext != null;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F6),
      appBar: showBackButton 
        ? AppBar(
            title: const Text("AI Insight", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            backgroundColor: Colors.white,
            elevation: 1,
            iconTheme: const IconThemeData(color: Colors.black),
            leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
            actions: [ _buildAuntieSwitch(), const SizedBox(width: 10) ],
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
                    if (!showBackButton) _buildModernHeader(),
                    const SizedBox(height: 8),
                    if (widget.initialContext != null) _buildContextInfoCard(widget.initialContext!),
                    if (widget.initialContext == null) _buildScenarioCard(),
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
                                if (_isTyping && index == _messages.length) return _buildTypingIndicator();
                                final msg = _messages[index];
                                if (msg["chartData"] != null) {
                                  return _buildChartBubble(
                                    text: msg["text"],
                                    data: (msg["chartData"] as List).cast<double>(),
                                  );
                                }
                                if (msg["propertyCard"] != null) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildMessageBubble(isUser: false, text: msg["text"]),
                                      _buildPropertyCardBubble(msg["propertyCard"]),
                                    ],
                                  );
                                }
                                return _buildMessageBubble(
                                  isUser: msg["isUser"] ?? false,
                                  text: msg["text"] ?? "",
                                );
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

  // --- UI WIDGETS (保持不变) ---

  Widget _buildAuntieSwitch() {
    return Row(
      children: [
        Text(_isAuntieMode ? "👵 Auntie" : "🤖 Standard", style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
        Switch(
          value: _isAuntieMode,
          activeColor: Colors.teal,
          onChanged: (value) {
             setState(() {
               _isAuntieMode = value;
               // 切换模式，传入 true 表示保留历史，仅追加新开场白
               _initConversation(isSwitchingMode: true); 
             });
          },
        ),
      ],
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), 
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]), 
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.teal, width: 2)), child: const CircleAvatar(backgroundColor: Colors.teal, radius: 18, child: Icon(Icons.smart_toy, color: Colors.white, size: 20))), 
          const SizedBox(width: 12), 
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("EcoHabit Insight Agent", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
            Row(children: [Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)), const SizedBox(width: 5), Text("Powered by Gemini AI", style: TextStyle(fontSize: 12, color: Colors.grey[600]))])
          ]), 
          const Spacer(), 
          _buildAuntieSwitch(), // 复用 Switch
        ]
      ),
    );
  }

  Widget _buildContextInfoCard(Map<String, dynamic> ctx) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.teal.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.home, size: 16, color: Colors.teal), const SizedBox(width: 8), Text("Discussing: ${ctx['title']}", style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12))]),
    );
  }

  Widget _buildPropertyCardBubble(Map<String, dynamic> data) {
    return Align(alignment: Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 15, left: 4, right: 20), width: 280, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.teal.withOpacity(0.15)), boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), child: Image.network(data['image'], height: 140, width: double.infinity, fit: BoxFit.cover, errorBuilder: (ctx, _, __) => Container(height: 140, color: Colors.grey[200], child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey))))), Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(data['price'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 15)), Text(data['location'], style: TextStyle(color: Colors.grey[600], fontSize: 12))]), const SizedBox(height: 10), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(6)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.eco, size: 14, color: Colors.green), const SizedBox(width: 4), Text("Eco-Score: ${data['score']}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green[800]))])), const SizedBox(height: 12), SizedBox(width: double.infinity, height: 36, child: ElevatedButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Navigating to Map Details..."))); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0), child: const Text("View Details")))]))])));
  }

  Widget _buildScenarioCard() {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))]), child: Wrap(spacing: 8, runSpacing: 4, children: const [_ScenarioChip(icon: Icons.work_outline, label: "Work: KL Sentral"), _ScenarioChip(icon: Icons.account_balance_wallet_outlined, label: "Budget: RM1500"), _ScenarioChip(icon: Icons.directions_subway_outlined, label: "Prefer near MRT")])));
  }

  Widget _buildInputContainer() {
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]), padding: const EdgeInsets.all(16), child: Column(children: [_buildSuggestionChips(), const SizedBox(height: 10), _buildInputArea()]));
  }

  Widget _buildSuggestionChips() {
    final suggestions = ["⚔️ Cheras vs Setapak", "📈 5-year rental growth", "🔥 Roast Setapak"];
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: suggestions.map((s) {
       final isRoast = s.contains("Roast");
       return Padding(padding: const EdgeInsets.only(right: 8), child: ActionChip(label: Text(s, style: TextStyle(color: isRoast ? Colors.red[800] : Colors.teal[800], fontWeight: FontWeight.w600, fontSize: 12)), backgroundColor: isRoast ? Colors.red[50] : Colors.teal[50], side: BorderSide(color: isRoast ? Colors.red.withOpacity(0.3) : Colors.teal.withOpacity(0.2)), avatar: Icon(isRoast ? Icons.local_fire_department : Icons.flash_on, size: 16, color: isRoast ? Colors.red : Colors.teal), onPressed: () => _sendMessage(s)));
    }).toList()));
  }

  Widget _buildInputArea() {
    return Row(children: [Expanded(child: TextField(controller: _controller, onSubmitted: (_) => _sendMessage(), decoration: InputDecoration(hintText: "Ask AI advisor...", filled: true, fillColor: const Color(0xFFF5F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)))), const SizedBox(width: 10), FloatingActionButton(mini: true, onPressed: () => _sendMessage(), backgroundColor: Colors.teal, child: const Icon(Icons.send, size: 18, color: Colors.white))]);
  }

  Widget _buildMessageBubble({required bool isUser, required String text}) {
    return Align(alignment: isUser ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 15), constraints: const BoxConstraints(maxWidth: 320), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), decoration: BoxDecoration(gradient: isUser ? const LinearGradient(colors: [Color(0xFF009688), Color(0xFF4DB6AC)]) : null, color: isUser ? null : Colors.white, borderRadius: BorderRadius.only(topLeft: const Radius.circular(20), topRight: const Radius.circular(20), bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(5), bottomRight: isUser ? const Radius.circular(5) : const Radius.circular(20)), boxShadow: [isUser ? BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)) : BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (!isUser) Padding(padding: const EdgeInsets.only(bottom: 5), child: Text(_isAuntieMode ? "AUNTIE SAYS" : "AI ANALYSIS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal[800], letterSpacing: 1))), Text(text, style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15, height: 1.5))])));
  }

  Widget _buildChartBubble({required String text, required List<double> data}) {
    final maxValue = data.isEmpty ? 0.0 : data.reduce(math.max);
    return Align(alignment: Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 15), padding: const EdgeInsets.all(16), constraints: const BoxConstraints(maxWidth: 360), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 3))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("RENTAL PROJECTION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal, letterSpacing: 1.1)), const SizedBox(height: 6), Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3)), const SizedBox(height: 10), SizedBox(height: 150, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(data.length, (index) { final value = data[index]; final factor = maxValue == 0 ? 0.0 : value / maxValue; return Column(mainAxisAlignment: MainAxisAlignment.end, children: [Container(width: 18, height: 100 * factor, decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), gradient: const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xFF2E7D32), Color(0xFF81C784)])),), const SizedBox(height: 6), Text("Y${index + 1}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)), Text("RM${value.toStringAsFixed(0)}", style: const TextStyle(fontSize: 10, color: Colors.black54))]); }))) ])));
  }

  Widget _buildTypingIndicator() {
    return Align(alignment: Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 15), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.teal)), const SizedBox(width: 10), Text("Thinking...", style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic))])));
  }
}

class _ScenarioChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ScenarioChip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 13, color: Colors.black54), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 11.5))]));
  }
}