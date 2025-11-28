import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _budget = 1500;
  double _vibeValue = 0.5;

  @override
  Widget build(BuildContext context) {
    // 简单的 Web 头部设计
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
             // 只有在手机版才显示这个 Logo，因为 Web 版侧边栏已经有了
             if (MediaQuery.of(context).size.width < 800) 
               const Icon(Icons.eco, color: Colors.teal),
             const SizedBox(width: 10),
             const Text("EcoRabbit Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          // 假装用户已登录
          Center(child: Text("Hi, Alex Tan ", style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold))),
          const SizedBox(width: 10),
          const CircleAvatar(
            backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=11"),
            radius: 18,
          ),
          const SizedBox(width: 20),
        ],
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Smart Commute Search",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 5),
            Text("Find a home that saves your time and the planet.", style: TextStyle(color: Colors.grey[600])),
            
            const SizedBox(height: 30),

            // --- Feature 1: Search Card ---
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Web 布局优化：如果是宽屏，把输入框和滑块并排显示
                  LayoutBuilder(builder: (context, constraints) {
                    return Wrap(
                      spacing: 30,
                      runSpacing: 20,
                      children: [
                        SizedBox(
                          width: constraints.maxWidth > 600 ? constraints.maxWidth * 0.45 : constraints.maxWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Workplace Location", style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: "e.g., KL Sentral, TRX",
                                  prefixIcon: const Icon(Icons.work_outline, color: Colors.teal),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: constraints.maxWidth > 600 ? constraints.maxWidth * 0.45 : constraints.maxWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Budget", style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text("RM ${_budget.round()}", style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Slider(
                                value: _budget,
                                min: 500, max: 5000, divisions: 45, activeColor: Colors.teal,
                                onChanged: (v) => setState(() => _budget = v),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                  
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  const Text("Preferred Vibe (Feature 2 Filter)", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.park, color: Colors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Slider(
                          value: _vibeValue, onChanged: (v) => setState(() => _vibeValue = v),
                          activeColor: Colors.orangeAccent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.local_fire_department, color: Colors.red),
                    ],
                  ),
                  Center(child: Text(_vibeValue < 0.5 ? "Currently: Quiet Area" : "Currently: Vibrant Area", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                  
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.search),
                      label: const Text("Find Eco-Homes"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            const Text("Top AI Recommendations", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // --- Feature 1: Recommendations ---
            // 如果是 Web 宽屏，我们用 GridView 显示卡片；如果是窄屏，用 ListView
            LayoutBuilder(builder: (context, constraints) {
               if (constraints.maxWidth > 700) {
                 return Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Expanded(child: _buildPropertyCard(
                        title: "Cheras Green Condo", price: "RM 1,300", 
                        score: 92, commute: "35 min (MRT)", isTop: true
                      )),
                     const SizedBox(width: 20),
                     Expanded(child: _buildPropertyCard(
                        title: "Setapak Apartment", price: "RM 1,100", 
                        score: 45, commute: "1h 10m (Car)", isTop: false
                      )),
                   ],
                 );
               } else {
                 return Column(
                   children: [
                     _buildPropertyCard(
                        title: "Cheras Green Condo", price: "RM 1,300", 
                        score: 92, commute: "35 min (MRT)", isTop: true
                      ),
                     const SizedBox(height: 20),
                     _buildPropertyCard(
                        title: "Setapak Apartment", price: "RM 1,100", 
                        score: 45, commute: "1h 10m (Car)", isTop: false
                      ),
                   ],
                 );
               }
            }),
          ],
        ),
      ),
    );
  }

  // --- Card 组件保持不变 ---
  Widget _buildPropertyCard({required String title, required String price, required int score, required String commute, required bool isTop}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: isTop ? Border.all(color: Colors.teal, width: 2) : Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 18)),
          ]),
          const SizedBox(height: 5),
          if (isTop) 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(5)),
              child: const Text("Top Pick", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 15),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isTop ? Colors.green[100] : Colors.orange[100],
                borderRadius: BorderRadius.circular(8)
              ),
              child: Text("Eco-Score: $score", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isTop ? Colors.green[800] : Colors.orange[800])),
            ),
            const Spacer(),
            Icon(Icons.directions_transit, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 5),
            Text(commute, style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 15),
          // Commute Simulator Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                Expanded(flex: isTop ? 3 : 7, child: Container(height: 8, color: isTop ? Colors.green : Colors.red)),
                Expanded(flex: isTop ? 7 : 3, child: Container(height: 8, color: Colors.grey[100])),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(isTop ? "🌱 Saves 3.5kg Carbon/day vs Car" : "🚗 High Car Dependency", style: TextStyle(fontSize: 12, color: isTop ? Colors.green : Colors.red, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}