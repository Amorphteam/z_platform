import 'package:flutter/material.dart';
import 'package:cupertino_native/cupertino_native.dart';

class LiquidGlassTestScreen extends StatefulWidget {
  const LiquidGlassTestScreen({Key? key}) : super(key: key);

  @override
  State<LiquidGlassTestScreen> createState() => _LiquidGlassTestScreenState();
}

class _LiquidGlassTestScreenState extends State<LiquidGlassTestScreen> {
  // State variables for different widgets
  double _sliderValue = 50.0;
  bool _switchValue = true;
  int _selectedIndex = 0;
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liquid Glass Widgets Test'),

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Cupertino Native Liquid Glass Widgets',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Slider Section
            _buildSection(
              title: '1. CNSlider - Liquid Glass Slider',
              child: Column(
                children: [
                  Text('Value: ${_sliderValue.toStringAsFixed(1)}'),
                  const SizedBox(height: 10),
                  CNSlider(
                    value: _sliderValue,
                    min: 0,
                    max: 100,
                    onChanged: (value) {
                      setState(() {
                        _sliderValue = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Switch Section
            _buildSection(
              title: '2. CNSwitch - Liquid Glass Switch',
              child: Row(
                children: [
                  Text('Switch is ${_switchValue ? "ON" : "OFF"}'),
                  const SizedBox(width: 20),
                  CNSwitch(
                    value: _switchValue,
                    onChanged: (value) {
                      setState(() {
                        _switchValue = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Segmented Control Section
            _buildSection(
              title: '3. CNSegmentedControl - Liquid Glass Segmented Control',
              child: Column(
                children: [
                  Text('Selected: ${_selectedIndex + 1}'),
                  const SizedBox(height: 10),
                  CNSegmentedControl(
                    labels: const ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
                    selectedIndex: _selectedIndex,
                    onValueChanged: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Button Section
            _buildSection(
              title: '4. CNButton - Liquid Glass Button',
              child: Column(
                children: [
                  CNButton(
                    label: 'Press Me',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Button pressed!')),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  CNButton.icon(
                    icon: const CNSymbol('heart.fill'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Icon button pressed!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Icon Section
            _buildSection(
              title: '5. CNIcon - SF Symbols',
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                children: const [
                  CNIcon(symbol: CNSymbol('star')),
                  CNIcon(symbol: CNSymbol('heart.fill')),
                  CNIcon(symbol: CNSymbol('house.fill')),
                  CNIcon(symbol: CNSymbol('person.crop.circle')),
                  CNIcon(symbol: CNSymbol('gearshape.fill')),
                  CNIcon(
                    symbol: CNSymbol('paintpalette.fill'),
                    mode: CNSymbolRenderingMode.multicolor,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Popup Menu Button Section
            _buildSection(
              title: '6. CNPopupMenuButton - Liquid Glass Popup Menu',
              child: CNPopupMenuButton(
                buttonLabel: 'Actions',
                items: const [
                  CNPopupMenuItem(
                    label: 'New File',
                    icon: CNSymbol('doc', size: 18),
                  ),
                  CNPopupMenuItem(
                    label: 'New Folder',
                    icon: CNSymbol('folder', size: 18),
                  ),
                  CNPopupMenuDivider(),
                  CNPopupMenuItem(
                    label: 'Rename',
                    icon: CNSymbol('rectangle.and.pencil.and.ellipsis', size: 18),
                  ),
                  CNPopupMenuItem(
                    label: 'Delete',
                    icon: CNSymbol('trash', size: 18),
                  ),
                ],
                onSelected: (index) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected item at index: $index')),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Tab Bar Section
            _buildSection(
              title: '7. CNTabBar - Liquid Glass Tab Bar',
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CNTabBar(
                  items: const [
                    CNTabBarItem(
                      label: 'Home',
                      icon: CNSymbol('house.fill'),
                    ),
                    CNTabBarItem(
                      label: 'Profile',
                      icon: CNSymbol('person.crop.circle'),
                    ),
                    CNTabBarItem(
                      label: 'Settings',
                      icon: CNSymbol('gearshape.fill'),
                    ),
                    CNTabBarItem(
                      label: 'Search',
                      icon: CNSymbol('magnifyingglass'),
                    ),
                  ],
                  currentIndex: _tabIndex,
                  onTap: (index) {
                    setState(() {
                      _tabIndex = index;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tab $index selected')),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Platform Info
            _buildSection(
              title: 'Platform Information',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Platform: ${Theme.of(context).platform}'),
                  const Text('Note: On iOS/macOS, you\'ll see native Liquid Glass widgets.'),
                  const Text('On Android/Web, you\'ll see Flutter fallback widgets.'),
                ],
              ),
            ),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
