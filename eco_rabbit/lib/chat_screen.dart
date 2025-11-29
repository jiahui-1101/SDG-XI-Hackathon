import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_ai/firebase_ai.dart'; // 🔥 修正：使用 Firebase AI Logic 包
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic>? initialContext;

  const ChatScreen({super.key, this.initialContext});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 🔥 1. 核心组件
  late GenerativeModel _model;
  late stt.SpeechToText _speech;
  late FlutterTts _tts;

  // 🔥 2. 状态变量
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;     // AI 正在思考
  bool _isAuntieMode = false; // 模式切换
  bool _isListening = false;  // 正在录音
  bool _isSpeaking = false;   // 正在朗读

  // --- 文案配置 ---
  static const String _standardWelcome =
      "Hello boss! 👋 EcoHabit agent here.\n\n"
      "Connected via **Firebase AI**. I can help check KL traffic & prices.\n\n"
      "Type or use the Mic 🎤 to ask!";

  static const String _auntieWelcome = 
      "Hello boy! 👋 Auntie here.\n\n"
      "Don't worry, Auntie know everything about KL property.\n\n"
      "Lazy type ah? Press the Mic 🎤 talk to Auntie!";

  @override
  void initState() {
    super.initState();
    _initVoiceFeatures();
    _initFirebaseAI(); // 🔥 初始化 AI
    _initConversation(isSwitchingMode: false);
  }

  // ✅ 初始化语音组件 (TTS & STT)
  void _initVoiceFeatures() async {
    _speech = stt.SpeechToText();
    _tts = FlutterTts();

    // 基础设置
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    // 监听 TTS 状态
    _tts.setStartHandler(() => setState(() => _isSpeaking = true));
    _tts.setCompletionHandler(() => setState(() => _isSpeaking = false));
    _tts.setErrorHandler((msg) => setState(() => _isSpeaking = false));
    
    // 🔥 关键：等待一下让浏览器加载声音列表，然后预加载女声
    await Future.delayed(const Duration(milliseconds: 500));
    _findAndSetFemaleVoice(); 
  }

  // 🔥🔥🔥 超级找女声逻辑 🔥🔥🔥
  Future<void> _findAndSetFemaleVoice() async {
    try {
      var voices = await _tts.getVoices;
      if (voices == null) return;

      // 打印出来看看你电脑里有啥声音 (Debug用)
      print("Available Voices: $voices");

      // 1. 优先找马来西亚或新加坡声音 (Auntie 首选)
      var targetVoice = voices.firstWhere(
        (v) {
            String name = v['name'].toString().toLowerCase();
            String locale = v['locale'].toString().toLowerCase();
            return locale.contains('my') || locale.contains('sg');
        },
        orElse: () => null,
      );

      // 2. 如果没找到，找 Windows 经典女声 "Zira"
      if (targetVoice == null) {
        targetVoice = voices.firstWhere(
          (v) => v['name'].toString().toLowerCase().contains('zira'),
          orElse: () => null,
        );
      }

      // 3. 还没找到？找 Google 的女声
      if (targetVoice == null) {
        targetVoice = voices.firstWhere(
          (v) => v['name'].toString().contains('Google US English'),
          orElse: () => null,
        );
      }
      
      // 4. 还没找到？找任何带 "Female" 标签的声音
      if (targetVoice == null) {
         targetVoice = voices.firstWhere(
          (v) => v['name'].toString().toLowerCase().contains('female'),
          orElse: () => null,
        );
      }

      // 如果找到了目标声音，就强制设置！
      if (targetVoice != null) {
        print("✅ Found Auntie Voice: ${targetVoice['name']}");
        await _tts.setVoice({"name": targetVoice["name"], "locale": targetVoice["locale"]});
      } else {
        print("⚠️ No specific female voice found, using default.");
      }

    } catch (e) {
      print("Error setting female voice: $e");
    }
  }

  // ✅ 核心修正：使用 FirebaseAI.googleAI()
  void _initFirebaseAI() {
    try {
      _model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash', 
        generationConfig: GenerationConfig(temperature: 0.9),
      );
    } catch (e) {
      debugPrint("❌ FirebaseAI Init Error: $e");
    }
  }

  // ✅ 初始化对话
  void _initConversation({bool isSwitchingMode = false}) {
    String welcomeText;
    
    if (widget.initialContext != null) {
      final ctx = widget.initialContext!;
      if (_isAuntieMode) {
         welcomeText = "Wah! You eyeing **${ctx['title']}**? 🏡\n\n"
            "Budget: **${ctx['budget']}**. Auntie check for you:\n1. Got jam or not?\n2. Worth it meh?";
      } else {
         welcomeText = "Hi! Looking at **${ctx['title']}**? 🏡\n\n"
            "Checking data for **${ctx['workplace']}** commute...\n1. Traffic Analysis\n2. Cost Breakdown";
      }
    } else {
      welcomeText = _isAuntieMode ? _auntieWelcome : _standardWelcome;
    }
    
    setState(() {
      _messages.add({"isUser": false, "text": welcomeText});
    });

    if (isSwitchingMode) {
      _stopSpeaking();
      _speak(welcomeText);
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _tts.stop();
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

  // 🔥 语音：开始录音
  Future<void> _startListening() async {
    if (_isSpeaking) await _stopSpeaking(); 

    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          _controller.text = result.recognizedWords; // 实时上屏
          
          if (result.finalResult) {
             _stopListening();
             _sendMessage(result.recognizedWords); // 说完自动发
          }
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  // 🔥 语音：朗读 (Auntie 声音最终优化版)
  Future<void> _speak(String text) async {
    // 1. 清洗特殊符号
    String cleanText = text.replaceAll('*', '').replaceAll('#', '').replaceAll('👇', '');
    
    // 2. 确保使用了我们找到的女声 (再次强制设置一次，防止跑偏)
    if (_isAuntieMode) {
       await _findAndSetFemaleVoice(); // 确保用女声
       await _tts.setPitch(1.2);      // 音调再高一点点，更像 Auntie
       await _tts.setSpeechRate(0.6); // 语速快一点
    } else {
       // 标准模式用回默认
       await _tts.setLanguage("en-US");
       await _tts.setPitch(1.0);
       await _tts.setSpeechRate(0.5);
    }
    
    // 3. 朗读
    await _tts.speak(cleanText);
  }

  Future<void> _stopSpeaking() async {
    await _tts.stop();
    setState(() => _isSpeaking = false);
  }

  // ✅ 发送消息 (整合逻辑)
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

    await Future.delayed(const Duration(seconds: 1));

    final input = text.toLowerCase();

    // --- 1. 本地逻辑 ---
    if (input.contains("growth") || input.contains("rental") || input.contains("5 years")) {
      _addChartResponse();
      return;
    }

    if (input.contains("cheras") || input.contains("best") || input.contains("recommend")) {
       _addPropertyRecommendation();
       return;
    } 
    
    if (input.contains("roast")) {
       String reply = _isAuntieMode 
           ? "Aiyo! Setapak again? 👵💢 Jam until tua (old) inside car!" 
           : "Setapak? High traffic warning. Expect 40 mins delay daily.";
       _addTextResponse(reply);
       return;
    }

    // --- 2. Firebase AI ---
    try {
      String systemInstruction = _isAuntieMode
         ? "You are a funny Malaysian Auntie housing agent. Speak Manglish. Keep it short."
         : "You are EcoHabit, a professional housing AI. Be concise and data-driven.";

      final content = [Content.text(systemInstruction + text)];
      
      final response = await _model.generateContent(content);
      final aiText = response.text ?? "Aiyo, no response from Firebase.";
      
      _addTextResponse(aiText);

    } catch (e) {
      print("FirebaseAI Error: $e");
      _fallbackMockResponse();
    }
  }

  void _fallbackMockResponse() {
     String reply = _isAuntieMode 
         ? "Check internet lah boy! Cannot connect." 
         : "Connection Error. Please check your network.";
     _addTextResponse(reply);
  }

  void _addTextResponse(String text) {
    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add({"isUser": false, "text": text});
    });
    _scrollToBottom();
    _speak(text); // 🔥 自动朗读回复
  }

  // --- UI 构建 ---

  void _addChartResponse() {
    const baseRent = 1300.0;
    const growthRate = 0.04;
    final List<double> projected = List.generate(
        5, (i) => baseRent * math.pow(1 + growthRate, i).toDouble());

    final explanation = _isAuntieMode
       ? "📈 **Auntie Math:** Price go up 4% every year! Better buy now."
       : "📈 **Forecast:** Expect ~4% yearly rental growth based on data.";

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
    _speak(explanation);
  }

  void _addPropertyRecommendation() {
      final aiResponse = _isAuntieMode
          ? "Auntie recommend **Cheras**! 👍 Near MRT, morning no jam."
          : "**Cheras** is the Top Pick. High connectivity, low traffic stress.";

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
      _speak(aiResponse);
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
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
            actions: [ _buildAuntieSwitch(), const SizedBox(width: 10) ],
          )
        : null,
      
      body: Stack(
        children: [
          Positioned(right: -50, top: 100, child: Icon(Icons.eco, size: 300, color: Colors.teal.withOpacity(0.05))),
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
                                  return _buildChartBubble(text: msg["text"], data: (msg["chartData"] as List).cast<double>());
                                }
                                if (msg["propertyCard"] != null) {
                                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildMessageBubble(isUser: false, text: msg["text"]), _buildPropertyCardBubble(msg["propertyCard"])]);
                                }
                                return _buildMessageBubble(isUser: msg["isUser"] ?? false, text: msg["text"] ?? "");
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

  // --- UI Widgets ---
  
  Widget _buildAuntieSwitch() {
    return Row(children: [
      Text(_isAuntieMode ? "👵 Auntie" : "🤖 Standard", style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
      Switch(value: _isAuntieMode, activeColor: Colors.teal, onChanged: (value) { setState(() { _isAuntieMode = value; _initConversation(isSwitchingMode: true); }); }),
    ]);
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), 
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]), 
      child: Row(children: [
        Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.teal, width: 2)), child: const CircleAvatar(backgroundColor: Colors.teal, radius: 18, child: Icon(Icons.smart_toy, color: Colors.white, size: 20))), 
        const SizedBox(width: 12), 
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("EcoHabit Insight Agent", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Row(children: [Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)), const SizedBox(width: 5), Text("Powered by Firebase AI", style: TextStyle(fontSize: 12, color: Colors.grey[600]))])]), 
        const Spacer(), 
        _buildAuntieSwitch(),
      ]),
    );
  }

  Widget _buildInputContainer() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]), 
      padding: const EdgeInsets.all(16), 
      child: Column(children: [_buildSuggestionChips(), const SizedBox(height: 10), _buildInputArea()])
    );
  }

  Widget _buildSuggestionChips() {
    final suggestions = ["⚔️ Cheras vs Setapak", "📈 Rental Growth", "🔥 Roast Setapak"];
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: suggestions.map((s) {
       final isRoast = s.contains("Roast");
       return Padding(padding: const EdgeInsets.only(right: 8), child: ActionChip(label: Text(s, style: TextStyle(color: isRoast ? Colors.red[800] : Colors.teal[800], fontWeight: FontWeight.w600, fontSize: 12)), backgroundColor: isRoast ? Colors.red[50] : Colors.teal[50], side: BorderSide(color: isRoast ? Colors.red.withOpacity(0.3) : Colors.teal.withOpacity(0.2)), avatar: Icon(isRoast ? Icons.local_fire_department : Icons.flash_on, size: 16, color: isRoast ? Colors.red : Colors.teal), onPressed: () => _sendMessage(s)));
    }).toList()));
  }

  Widget _buildInputArea() {
    return Row(children: [
      GestureDetector(
        onTap: _isListening ? _stopListening : _startListening,
        child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _isListening ? Colors.red[50] : Colors.white, shape: BoxShape.circle, border: Border.all(color: _isListening ? Colors.red : Colors.grey[300]!)), child: Icon(_isListening ? Icons.stop : Icons.mic, color: _isListening ? Colors.red : Colors.grey[600])),
      ),
      const SizedBox(width: 8),
      Expanded(child: TextField(controller: _controller, onSubmitted: (_) => _sendMessage(), decoration: InputDecoration(hintText: _isListening ? "Listening..." : "Ask AI advisor...", filled: true, fillColor: const Color(0xFFF5F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)))), 
      const SizedBox(width: 8), 
      FloatingActionButton(mini: true, onPressed: () => _sendMessage(), backgroundColor: Colors.teal, child: const Icon(Icons.send, size: 18, color: Colors.white))
    ]);
  }

  Widget _buildMessageBubble({required bool isUser, required String text}) {
    return Align(alignment: isUser ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 15), constraints: const BoxConstraints(maxWidth: 320), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), decoration: BoxDecoration(gradient: isUser ? const LinearGradient(colors: [Color(0xFF009688), Color(0xFF4DB6AC)]) : null, color: isUser ? null : Colors.white, borderRadius: BorderRadius.only(topLeft: const Radius.circular(20), topRight: const Radius.circular(20), bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(5), bottomRight: isUser ? const Radius.circular(5) : const Radius.circular(20)), boxShadow: [isUser ? BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)) : BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (!isUser) Padding(padding: const EdgeInsets.only(bottom: 5), child: Text(_isAuntieMode ? "AUNTIE SAYS" : "AI ANALYSIS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal[800], letterSpacing: 1))), Text(text, style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15, height: 1.5))])));
  }

  Widget _buildContextInfoCard(Map<String, dynamic> ctx) {
    return Container(margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.teal.withOpacity(0.3))), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.home, size: 16, color: Colors.teal), const SizedBox(width: 8), Text("Discussing: ${ctx['title']}", style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12))]));
  }

  Widget _buildScenarioCard() {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))]), child: Wrap(spacing: 8, runSpacing: 4, children: const [_ScenarioChip(icon: Icons.work_outline, label: "Work: KL Sentral"), _ScenarioChip(icon: Icons.account_balance_wallet_outlined, label: "Budget: RM1500"), _ScenarioChip(icon: Icons.directions_subway_outlined, label: "Prefer near MRT")])));
  }

  Widget _buildPropertyCardBubble(Map<String, dynamic> data) {
    return Align(alignment: Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 15, left: 4, right: 20), width: 280, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.teal.withOpacity(0.15)), boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), child: Image.network(data['image'], height: 140, width: double.infinity, fit: BoxFit.cover, errorBuilder: (ctx, _, __) => Container(height: 140, color: Colors.grey[200], child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey))))), Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(data['price'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 15)), Text(data['location'], style: TextStyle(color: Colors.grey[600], fontSize: 12))]), const SizedBox(height: 10), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(6)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.eco, size: 14, color: Colors.green), const SizedBox(width: 4), Text("Eco-Score: ${data['score']}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green[800]))])), const SizedBox(height: 12), SizedBox(width: double.infinity, height: 36, child: ElevatedButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Navigating to Map Details..."))); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0), child: const Text("View Details")))]))])));
  }

  Widget _buildChartBubble({required String text, required List<double> data}) {
    return Align(alignment: Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 15), padding: const EdgeInsets.all(16), constraints: const BoxConstraints(maxWidth: 360), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 3))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("RENTAL PROJECTION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal, letterSpacing: 1.1)), const SizedBox(height: 6), Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3)), const SizedBox(height: 10), SizedBox(height: 150, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(data.length, (index) { final value = data[index]; final maxValue = data.reduce(math.max); final factor = maxValue == 0 ? 0.0 : value / maxValue; return Column(mainAxisAlignment: MainAxisAlignment.end, children: [Container(width: 18, height: 100 * factor, decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), gradient: const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xFF2E7D32), Color(0xFF81C784)])),), const SizedBox(height: 6), Text("Y${index + 1}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)), Text("RM${value.toStringAsFixed(0)}", style: const TextStyle(fontSize: 10, color: Colors.black54))]); }))) ])));
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