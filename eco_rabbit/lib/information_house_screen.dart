// information_house_screen.dart
import 'package:flutter/material.dart';
import 'models/property_model.dart';

class InformationHouseScreen extends StatelessWidget {
  final PropertyResult property;

  const InformationHouseScreen({super.key, required this.property});

  // 计算财务信息
  Map<String, dynamic> _calculateFinancials(PropertyResult property) {
    double baseRent = 1800.0;
    double baseTransportCost = 300.0;
    double baseCommuteTime = 20.0;
    
    double actualRent = property.price.toDouble();
    double actualTransportCost = property.distanceToWork * 40;
    double actualCommuteTime = property.details.commuteTime.toDouble();
    
    double rentDifference = baseRent - actualRent;
    double transportDifference = baseTransportCost - actualTransportCost;
    double timeValueDifference = (baseCommuteTime - actualCommuteTime) * 15;
    
    double totalSavings = rentDifference + transportDifference + timeValueDifference;
    
    int bubbleTeas = (totalSavings.abs() / 15).round();
    int ps5Games = (totalSavings.abs() / 200).round();
    int wakeUpTime = 8 - (actualCommuteTime ~/ 60);
    double carbonReduction = (baseCommuteTime - actualCommuteTime) * 0.1;
    int iceCubes = (carbonReduction * 10).round();
    
    return {
      'rentDifference': rentDifference,
      'transportDifference': transportDifference,
      'timeValueDifference': timeValueDifference,
      'totalSavings': totalSavings,
      'bubbleTeas': bubbleTeas,
      'ps5Games': ps5Games,
      'wakeUpTime': wakeUpTime,
      'iceCubes': iceCubes,
      'isGoodDeal': totalSavings > 0,
    };
  }

  List<Facility> _getNearbyFacilities(String area) {
    final facilitiesMap = {
      'Mont Kiara': [
        Facility('International School of KL', '1.2 km', Icons.school, 'International'),
        Facility('Mont Kiara International', '0.8 km', Icons.school, 'Private'),
        Facility('Sunway Medical Centre', '2.1 km', Icons.local_hospital, 'Hospital'),
        Facility('Bangsar Shopping Centre', '3.5 km', Icons.shopping_cart, 'Mall'),
        Facility('Taman Tun Park', '1.5 km', Icons.park, 'Park'),
      ],
      'Bangsar South': [
        Facility('University of Malaya', '3.2 km', Icons.school, 'University'),
        Facility('Pantai Hospital', '1.8 km', Icons.local_hospital, 'Hospital'),
        Facility('Mid Valley Megamall', '2.3 km', Icons.shopping_cart, 'Mall'),
        Facility('KL Gateway Mall', '0.3 km', Icons.store, 'Shopping'),
      ],
      'KLCC': [
        Facility('Suria KLCC', '0.2 km', Icons.shopping_cart, 'Luxury Mall'),
        Facility('KLCC Park', '0.1 km', Icons.park, 'Urban Park'),
        Facility('Avenue K', '0.5 km', Icons.store, 'Shopping'),
      ],
      'Cheras': [
        Facility('EkoCheras Mall', '1.2 km', Icons.shopping_cart, 'Mall'),
        Facility('Taman Tasik Cheras', '1.8 km', Icons.park, 'Lake Park'),
        Facility('Leisure Mall', '3.1 km', Icons.store, 'Entertainment'),
      ],
    };
    return facilitiesMap[property.area] ?? [];
  }

  Map<String, String> _getContactInfo(String propertyName) {
    final contacts = {
      'Cheras Green Condo': {
        'agent': 'Mr. Tan Wei Ming',
        'email': 'tanweiming@greenestate.com',
        'phone': '+603-2389 4567',
        'company': 'Green Estate Agency'
      },
      'Bangsar South Loft': {
        'agent': 'Ms. Sarah Lim',
        'email': 'sarah.lim@ecoproperties.com',
        'phone': '+603-2456 7890',
        'company': 'Eco Properties Sdn Bhd'
      },
    };
    return contacts[propertyName] ?? {
      'agent': 'Property Agent',
      'email': 'agent@example.com',
      'phone': '+603-2000 0000',
      'company': 'Real Estate Agency'
    };
  }

  @override
  Widget build(BuildContext context) {
    final nearbyFacilities = _getNearbyFacilities(property.area);
    final contactInfo = _getContactInfo(property.name);
    final financials = _calculateFinancials(property);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(property.name),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: isDesktop ? _buildDesktopLayout(context, financials, nearbyFacilities, contactInfo) 
                      : _buildMobileLayout(context, financials, nearbyFacilities, contactInfo),
    );
  }

  // 🖥️ 桌面端布局 - 左右分栏
  Widget _buildDesktopLayout(BuildContext context, Map<String, dynamic> financials, List<Facility> nearbyFacilities, Map<String, String> contactInfo) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左边 - 完整高清图片
        Expanded(
          flex: 2,
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Image.network(
              property.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home, size: 60, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Property Image', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // 右边 - 内容区域
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyHeader(),
                const SizedBox(height: 24),

                // 网格布局 - 2列
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.2,
                  children: [
                    _buildGridCard("💰 Monthly Savings", _buildReceiptContent(financials), Colors.green[50]!),
                    _buildGridCard("📊 Property Details", _buildPropertyDetails(), Colors.blue[50]!),
                    _buildGridCard("🚗 Commute Info", _buildCommuteInfo(), Colors.orange[50]!),
                    _buildGridCard("🏪 Nearby Facilities", _buildFacilitiesContent(nearbyFacilities), Colors.purple[50]!),
                    _buildGridCard("⭐ Amenities", _buildAmenitiesContent(), Colors.teal[50]!),
                    _buildGridCard("📞 Contact Info", _buildContactContent(contactInfo), Colors.indigo[50]!),
                  ],
                ),

                const SizedBox(height: 24),
                _buildSaveButton(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 📱 移动端布局
  Widget _buildMobileLayout(BuildContext context, Map<String, dynamic> financials, List<Facility> nearbyFacilities, Map<String, String> contactInfo) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 300,
            width: double.infinity,
            child: Image.network(
              property.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home, size: 60, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Property Image', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyHeader(),
                const SizedBox(height: 24),
                _buildRealityReceipt(financials),
                const SizedBox(height: 24),
                _buildInfoSection("📊 Property Details", _buildPropertyDetailsList()),
                _buildInfoSection("🚗 Commute Info", _buildCommuteInfoList()),
                _buildInfoSection("🏪 Nearby Facilities", [
                  const SizedBox(height: 8),
                  ...nearbyFacilities.map((facility) => _buildFacilityItem(facility)).toList(),
                ]),
                _buildInfoSection("⭐ Amenities", [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: property.details.amenities.map((amenity) => Chip(
                      label: Text(amenity),
                      backgroundColor: Colors.teal.withOpacity(0.1),
                    )).toList(),
                  ),
                ]),
                _buildInfoSection("📞 Contact Info", [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        _buildContactItem("Agency", contactInfo['company']!, Icons.business),
                        _buildContactItem("Agent", contactInfo['agent']!, Icons.person),
                        _buildContactItem("Email", contactInfo['email']!, Icons.email),
                        _buildContactItem("Phone", contactInfo['phone']!, Icons.phone),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 32),
                _buildSaveButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🏷️ Property Header
  Widget _buildPropertyHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.home, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(property.area, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green),
            ),
            child: Text("Eco Score: ${property.ecoScore}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 🎴 网格卡片
  Widget _buildGridCard(String title, Widget content, Color backgroundColor) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: backgroundColor.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }

  // 💰 Receipt Content - 放大字体并有趣表达
  Widget _buildReceiptContent(Map<String, dynamic> financials) {
    final bool isHighEcoScore = property.ecoScore >= 70;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReceiptLine("Rent", financials['rentDifference'], Colors.green),
        _buildReceiptLine("Transport", financials['transportDifference'], Colors.green),
        _buildReceiptLine("Time Value", financials['timeValueDifference'], Colors.green),
        
        const Divider(),
        
        financials['totalSavings'] >= 0
            ? _buildReceiptLine("TOTAL SAVINGS", financials['totalSavings'], Colors.green, isBold: true)
            : _buildReceiptLine("MONTHLY DRAIN", financials['totalSavings'], Colors.red, isBold: true),
        
        const SizedBox(height: 12),
        
        // 趣味提示
        if (financials['totalSavings'] >= 0 && isHighEcoScore)
          _buildFunContainer("🧋", "Yay! You can buy ${financials['bubbleTeas']} bubble teas every month! 🎉", Colors.pink)
        else if (financials['totalSavings'] >= 0)
          _buildFunContainer("💰", "Nice! You're saving money! ${financials['ps5Games'] > 0 ? 'Almost ${financials['ps5Games']} PS5 game${financials['ps5Games'] > 1 ? 's' : ''}! 🎮' : '💸'}", Colors.green)
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.orange)),
            child: Row(
              children: [
                Text("😭", style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Oh no! This place is draining your wallet!", style: TextStyle(fontSize: 14, color: Colors.orange[800], fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("You'll miss out on ${financials['bubbleTeas']} bubble teas this month! 🧋💔", style: TextStyle(fontSize: 12, color: Colors.orange[700])),
                    ],
                  ),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 8),
        
        // 趣味指数
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: financials['totalSavings'] >= 0 
              ? [
                  _buildFunFact("😴 Wake up at ${financials['wakeUpTime']}:00 AM", Colors.blue, fontSize: 12),
                  _buildFunFact("🐻‍❄️ Saves ${financials['iceCubes']} polar bear ice cubes", Colors.cyan, fontSize: 12),
                  _buildFunFact("🌱 Eco-friendly commute 🌍", Colors.teal, fontSize: 12),
                ]
              : [
                  _buildFunFact("⏰ ${property.details.commuteTime}min daily commute 😫", Colors.blue, fontSize: 12),
                  _buildFunFact("🚗 ${property.distanceToWork}km traffic struggle 🚦", Colors.orange, fontSize: 12),
                  _buildFunFact("💸 Hidden costs alert! 🚨", Colors.red, fontSize: 12),
                ],
        ),
      ],
    );
  }

  Widget _buildReceiptLine(String label, double value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value >= 0 ? "+RM${value.abs().toInt()}" : "-RM${value.abs().toInt()}", style: TextStyle(color: color, fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildFunContainer(String emoji, String text, MaterialColor color) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.shade50, // 使用 .shade50 而不是 [50]
      borderRadius: BorderRadius.circular(10), 
      border: Border.all(color: color)
    ),
    child: Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text, 
            style: TextStyle(
              fontSize: 14, 
              color: color.shade800, // 使用 .shade800 而不是 [800]
              fontWeight: FontWeight.bold
            )
          ),
        ),
      ],
    ),
  );
}

  Widget _buildFunFact(String text, Color color, {double fontSize = 12}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold)),
    );
  }

  // 📊 Property Details Content - 放大字体
  Widget _buildPropertyDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailLine("Rent", "RM${property.price}"),
        _buildDetailLine("Bedrooms", "${property.details.bedrooms}"),
        _buildDetailLine("Bathrooms", "${property.details.bathrooms}"),
        _buildDetailLine("Size", "${property.details.size} sq ft"),
        _buildDetailLine("Type", "Condominium"),
        _buildDetailLine("Furnishing", "Fully Furnished"),
      ],
    );
  }

  List<Widget> _buildPropertyDetailsList() {
    return [
      _buildInfoItem("Monthly Rent", "RM${property.price}"),
      _buildInfoItem("Bedrooms", "${property.details.bedrooms}"),
      _buildInfoItem("Bathrooms", "${property.details.bathrooms}"),
      _buildInfoItem("Size", "${property.details.size} sq ft"),
      _buildInfoItem("Property Type", "Condominium"),
      _buildInfoItem("Furnishing", "Fully Furnished"),
    ];
  }

  // 🚗 Commute Info Content - 放大字体
  Widget _buildCommuteInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailLine("Distance", "${property.distanceToWork} km"),
        _buildDetailLine("Time", "${property.details.commuteTime} min"),
        _buildDetailLine("To Station", "${property.details.distanceToStation} m"),
        _buildDetailLine("Options", "MRT, Bus"),
        _buildDetailLine("Traffic", "Low"),
        _buildDetailLine("Parking", "Available"),
      ],
    );
  }

  List<Widget> _buildCommuteInfoList() {
    return [
      _buildInfoItem("Distance to Work", "${property.distanceToWork} km"),
      _buildInfoItem("Commute Time", "${property.details.commuteTime} minutes"),
      _buildInfoItem("Nearest Station", "${property.details.distanceToStation} m"),
      _buildInfoItem("Transport Options", "MRT, Bus, Walking"),
    ];
  }

  // 🏪 Facilities Content - 放大字体
  Widget _buildFacilitiesContent(List<Facility> facilities) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: facilities.length,
      itemBuilder: (context, index) {
        final facility = facilities[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(facility.icon, size: 16, color: Colors.purple),
              const SizedBox(width: 10),
              Expanded(child: Text(facility.name, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis)),
              Text(facility.distance, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
          ),
        );
      },
    );
  }

  // ⭐ Amenities Content - 放大字体
  Widget _buildAmenitiesContent() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: property.details.amenities.map((amenity) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Colors.teal.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
        child: Text(amenity, style: const TextStyle(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.w500)),
      )).toList(),
    );
  }

  // 📞 Contact Content - 放大字体
  Widget _buildContactContent(Map<String, String> contactInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContactLine("Agency", contactInfo['company']!),
        _buildContactLine("Agent", contactInfo['agent']!),
        _buildContactLine("Email", contactInfo['email']!),
        _buildContactLine("Phone", contactInfo['phone']!),
      ],
    );
  }

  Widget _buildDetailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildContactLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // 💾 Save Button
  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${property.name} saved to favorites! 🎉')));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_add),
            SizedBox(width: 8),
            Text("Save to Favorites", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // 移动端专用方法
  Widget _buildRealityReceipt(Map<String, dynamic> financials) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green, width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: Colors.green[800], size: 24),
              const SizedBox(width: 8),
              Text("💰 Monthly Savings Receipt", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800])),
            ],
          ),
          const SizedBox(height: 16),
          _buildReceiptContent(financials),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFacilityItem(Facility facility) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[200]!)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(facility.icon, size: 18, color: Colors.teal),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(facility.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(facility.distance, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                      child: Text(facility.type, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.teal),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Facility {
  final String name;
  final String distance;
  final IconData icon;
  final String type;

  Facility(this.name, this.distance, this.icon, this.type);
}