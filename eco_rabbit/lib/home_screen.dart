import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _budget = 1500;
  String _selectedChip = "Near MRT"; // 默认选中的筛选

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度，做简单的响应式
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // 更柔和的背景灰
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. 顶部 Header (渐变色 + 个人数据) ---
            _buildHeaderSection(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  
                  // --- 2. 搜索框 (悬浮感) ---
                  _buildSearchField(),
                  
                  const SizedBox(height: 25),

                  // --- 3. 预算与 Vibe 调节 (合并在一个卡片里) ---
                  _buildFilterCard(),

                  const SizedBox(height: 25),

                  // --- 4. 快速筛选 Chips (横向滚动) ---
                  const Text("Quick Filters", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildChoiceChip("Near MRT", Icons.directions_subway),
                        _buildChoiceChip("Safe Zone", Icons.security),
                        _buildChoiceChip("Student", Icons.school),
                        _buildChoiceChip("Family", Icons.family_restroom),
                        _buildChoiceChip("Low Carbon", Icons.eco),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- 5. 推荐列表 ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("AI Top Picks For You", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () {}, child: const Text("See All", style: TextStyle(color: Colors.teal))),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 这里的布局逻辑：如果是宽屏，并排显示；窄屏垂直显示
                  isDesktop 
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildPropertyCard(
                            imageUrl: "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
                            title: "Cheras Green Condo",
                            price: "RM 1,300",
                            location: "Cheras • 400m to MRT",
                            matchRate: 98,
                            tags: ["High Connectivity", "Value"],
                            isRecommended: true,
                          )),
                          const SizedBox(width: 20),
                          Expanded(child: _buildPropertyCard(
                            imageUrl: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
                            title: "Bangsar South Loft",
                            price: "RM 1,800",
                            location: "Bangsar South • 200m to LRT",
                            matchRate: 92,
                            tags: ["Luxury", "Vibrant"],
                            isRecommended: false,
                          )),
                        ],
                      )
                    : Column(
                        children: [
                          _buildPropertyCard(
                            imageUrl: "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
                            title: "Cheras Green Condo",
                            price: "RM 1,300",
                            location: "Cheras • 400m to MRT",
                            matchRate: 98,
                            tags: ["High Connectivity", "Value"],
                            isRecommended: true,
                          ),
                          const SizedBox(height: 20),
                          _buildPropertyCard(
                            imageUrl: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
                            title: "Bangsar South Loft",
                            price: "RM 1,800",
                            location: "Bangsar South • 200m to LRT",
                            matchRate: 92,
                            tags: ["Luxury", "Vibrant"],
                            isRecommended: false,
                          ),
                          const SizedBox(height: 20),
                          // 再加一个反面教材卡片，展示对比
                          _buildPropertyCard(
                            imageUrl: "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
                            title: "Setapak Budget Flat",
                            price: "RM 1,100",
                            location: "Setapak • Car Dependent",
                            matchRate: 45,
                            tags: ["Traffic Jam Risk"],
                            isRecommended: false,
                            isWarning: true, // 特殊的警告样式
                          ),
                        ],
                      ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget 1: 漂亮的头部 ---
  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF009688), Color(0xFF4DB6AC)], // Teal gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Good Morning, Alex! ☀️", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("Ready to find your green home?", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                ],
              ),
              const CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=11"),
                backgroundColor: Colors.white,
              )
            ],
          ),
          const SizedBox(height: 25),
          // Impact Card (个人数据展示)
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.eco, color: Colors.teal),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Your Commute Impact", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text("12.5 kg CO₂ Saved", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- Widget 2: 搜索框 ---
  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Enter Workplace (e.g., KL Sentral)",
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Colors.teal),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.tune, color: Colors.white, size: 20),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  // --- Widget 3: 筛选卡片 ---
  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Budget Range", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("RM ${_budget.round()}", style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(trackHeight: 6, activeTrackColor: Colors.teal, thumbColor: Colors.teal, overlayColor: Colors.teal.withOpacity(0.2)),
            child: Slider(
              value: _budget,
              min: 500, max: 5000, divisions: 45,
              onChanged: (v) => setState(() => _budget = v),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget 4: 标签 Chips ---
  Widget _buildChoiceChip(String label, IconData icon) {
    bool isSelected = _selectedChip == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedChip = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isSelected ? Colors.teal : Colors.grey[300]!),
          boxShadow: isSelected ? [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey[600]),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[700], fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // --- Widget 5: 房源卡片 (视觉核心) ---
  Widget _buildPropertyCard({
    required String imageUrl,
    required String title,
    required String price,
    required String location,
    required int matchRate,
    required List<String> tags,
    required bool isRecommended,
    bool isWarning = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
        border: isRecommended ? Border.all(color: Colors.teal, width: 2) : (isWarning ? Border.all(color: Colors.red[200]!) : null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片区域
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.network(
                  imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // AI Match Badge
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isWarning ? Colors.red : (matchRate > 90 ? Colors.teal : Colors.orange),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text("$matchRate% Match", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题和价格
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
                    Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 5),
                // 地点
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(location, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 标签 Tags
                Wrap(
                  spacing: 8,
                  children: tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                    child: Text(tag, style: TextStyle(color: Colors.grey[700], fontSize: 10)),
                  )).toList(),
                ),
                
                const SizedBox(height: 15),
                // Commute Bar (视觉化数据)
                const Text("Daily Commute Impact", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: isWarning ? 8 : (isRecommended ? 2 : 5),
                        child: Container(height: 6, color: isWarning ? Colors.red : Colors.green),
                      ),
                      Expanded(
                        flex: isWarning ? 2 : (isRecommended ? 8 : 5),
                        child: Container(height: 6, color: Colors.grey[200]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isWarning ? "High Carbon" : "Low Carbon", style: TextStyle(fontSize: 10, color: isWarning ? Colors.red : Colors.green)),
                    Text(isRecommended ? "Save 40 mins" : (isWarning ? "Lose 1 hr" : "Average"), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}