// information_house_screen.dart
import 'package:flutter/material.dart';
import 'models/property_model.dart';

class InformationHouseScreen extends StatelessWidget {
  final PropertyResult property;

  const InformationHouseScreen({super.key, required this.property});

  // 修复：返回 List<Facility> 而不是 Map
  List<Facility> _getNearbyFacilities(String area) {
    // 根据区域返回不同的设施数据
    final facilitiesMap = {
      'Mont Kiara': [
        Facility('International School of Kuala Lumpur', '1.2 km', Icons.school, 'International'),
        Facility('Mont Kiara International School', '0.8 km', Icons.school, 'Private'),
        Facility('Sunway Medical Centre', '2.1 km', Icons.local_hospital, 'Private Hospital'),
        Facility('Bangsar Shopping Centre', '3.5 km', Icons.shopping_cart, 'Shopping Mall'),
        Facility('KL Sentral Police Station', '4.2 km', Icons.local_police, 'Police'),
        Facility('Taman Tun Park', '1.5 km', Icons.park, 'Recreation'),
      ],
      'Bangsar South': [
        Facility('University of Malaya', '3.2 km', Icons.school, 'Public University'),
        Facility('Bangsar South Primary School', '0.5 km', Icons.school, 'Public School'),
        Facility('Pantai Hospital Bangsar', '1.8 km', Icons.local_hospital, 'Private Hospital'),
        Facility('Mid Valley Megamall', '2.3 km', Icons.shopping_cart, 'Shopping Mall'),
        Facility('Bangsar Police Station', '1.2 km', Icons.local_police, 'Police'),
        Facility('KL Gateway Mall', '0.3 km', Icons.store, 'Shopping'),
      ],
      'KLCC': [
        Facility('KLCC Primary School', '0.8 km', Icons.school, 'Public School'),
        Facility('Prince Court Medical Centre', '1.5 km', Icons.local_hospital, 'Private Hospital'),
        Facility('Suria KLCC', '0.2 km', Icons.shopping_cart, 'Luxury Mall'),
        Facility('KLCC Park', '0.1 km', Icons.park, 'Urban Park'),
        Facility('Dang Wangi Police Station', '1.8 km', Icons.local_police, 'Police'),
        Facility('Avenue K Shopping Mall', '0.5 km', Icons.store, 'Shopping'),
      ],
      'Petaling Jaya': [
        Facility('University of Malaya Medical Centre', '4.2 km', Icons.local_hospital, 'Government Hospital'),
        Facility('SMK Sultan Abdul Samad', '1.2 km', Icons.school, 'Public School'),
        Facility('One Utama Shopping Centre', '3.5 km', Icons.shopping_cart, 'Shopping Mall'),
        Facility('Petaling Jaya Police HQ', '2.1 km', Icons.local_police, 'Police'),
        Facility('Taman Jaya Park', '0.8 km', Icons.park, 'Public Park'),
        Facility('SS2 Mall', '1.5 km', Icons.store, 'Community Mall'),
      ],
      'Cheras': [
        Facility('UKM Medical Centre', '5.2 km', Icons.local_hospital, 'University Hospital'),
        Facility('SMK Cheras', '0.8 km', Icons.school, 'Public School'),
        Facility('EkoCheras Mall', '1.2 km', Icons.shopping_cart, 'Shopping Mall'),
        Facility('Cheras Police Station', '2.3 km', Icons.local_police, 'Police'),
        Facility('Taman Tasik Cheras', '1.8 km', Icons.park, 'Lake Park'),
        Facility('Leisure Mall', '3.1 km', Icons.store, 'Entertainment'),
      ],
    };

    // 修复：直接返回 List<Facility> 或默认列表
    return facilitiesMap[area] ?? [
      Facility('Nearest School', '2.0 km', Icons.school, 'Education'),
      Facility('Nearest Hospital', '3.0 km', Icons.local_hospital, 'Healthcare'),
      Facility('Shopping Mall', '1.5 km', Icons.shopping_cart, 'Shopping'),
      Facility('Police Station', '2.5 km', Icons.local_police, 'Security'),
      Facility('Public Park', '1.2 km', Icons.park, 'Recreation'),
    ];
  }

  // 模拟联系信息
  Map<String, String> _getContactInfo(String propertyName) {
    final contacts = {
      'Green Residence Mont Kiara': {
        'agent': 'Mr. Tan Wei Ming',
        'email': 'tanweiming@greenestate.com',
        'phone': '+603-2389 4567',
        'company': 'Green Estate Agency'
      },
      'Eco Suites Bangsar South': {
        'agent': 'Ms. Sarah Lim',
        'email': 'sarah.lim@ecoproperties.com',
        'phone': '+603-2456 7890',
        'company': 'Eco Properties Sdn Bhd'
      },
      'KLCC Sky View Condo': {
        'agent': 'Mr. Raj Kumar',
        'email': 'raj.kumar@skyview.com',
        'phone': '+603-2112 3344',
        'company': 'Sky View Realty'
      },
      'PJ Eco Living Apartment': {
        'agent': 'Ms. Mei Ling',
        'email': 'meiling@pjhomes.com',
        'phone': '+603-2778 8990',
        'company': 'PJ Homes Agency'
      },
      'Cheras Green Home': {
        'agent': 'Mr. Ahmad Faisal',
        'email': 'ahmad@cherasproperties.com',
        'phone': '+603-2889 9001',
        'company': 'Cheras Properties'
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

    return Scaffold(
      appBar: AppBar(
        title: Text(property.name),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 大图展示
            Container(
              height: 250,
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
                  // Property Header
                  Container(
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
                              Text(
                                property.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                property.area,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
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
                          child: Text(
                            "Eco Score: ${property.ecoScore}",
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Property Specifications
                  _buildInfoSection("Property Specifications", [
                    _buildInfoItem("Monthly Rent", "RM${property.price}"),
                    _buildInfoItem("Bedrooms", "${property.details.bedrooms}"),
                    _buildInfoItem("Bathrooms", "${property.details.bathrooms}"),
                    _buildInfoItem("Size", "${property.details.size} sq ft"),
                    _buildInfoItem("Property Type", "Condominium"),
                    _buildInfoItem("Furnishing", "Fully Furnished"),
                  ]),

                  // Commute Information
                  _buildInfoSection("Commute Information", [
                    _buildInfoItem("Distance to Workplace", "${property.distanceToWork} km"),
                    _buildInfoItem("Estimated Commute Time", "${property.details.commuteTime} minutes"),
                    _buildInfoItem("Distance to Station", "${property.details.distanceToStation} m"),
                    _buildInfoItem("Transport Options", "MRT, Bus, Walking"),
                    _buildInfoItem("Traffic Condition", "Low Congestion"),
                    _buildInfoItem("Parking Availability", "Covered Parking Available"),
                  ]),

                  // Nearby Facilities
                  _buildInfoSection("Nearby Facilities", [
                    const SizedBox(height: 8),
                    ...nearbyFacilities.map((facility) => _buildFacilityItem(facility)).toList(),
                  ]),

                  // Property Amenities
                  _buildInfoSection("Property Amenities", [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: property.details.amenities.map((amenity) => Chip(
                        label: Text(amenity),
                        backgroundColor: Colors.teal.withOpacity(0.1),
                      )).toList(),
                    ),
                  ]),

                  // Contact Information
                  _buildInfoSection("Contact Information", [
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

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${property.name} saved to favorites')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.teal),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark_border, color: Colors.teal),
                          SizedBox(width: 8),
                          Text("Save Property", style: TextStyle(color: Colors.teal)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFacilityItem(Facility facility) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(facility.icon, size: 16, color: Colors.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  facility.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      facility.distance,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        facility.type,
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 设施数据模型
class Facility {
  final String name;
  final String distance;
  final IconData icon;
  final String type;

  Facility(this.name, this.distance, this.icon, this.type);
}