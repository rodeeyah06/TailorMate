import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tailormate/models/order.dart';
import 'package:tailormate/providers/client_provider.dart';
import 'package:tailormate/screens/client/add_client_screen.dart';
import 'package:tailormate/screens/client/client_profile_screen.dart';
import 'package:tailormate/screens/client/clients_screen.dart';
import 'package:tailormate/screens/client/whatsapp_parse_screen.dart';
import 'package:tailormate/screens/order/order_detail_screen.dart';
import 'package:tailormate/screens/order/orders_screen.dart';
import 'package:tailormate/screens/settings/settings_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<TailorOrder> _dueSoonOrders = [];
  List<TailorOrder> _allOrders = [];
  List<TailorOrder> _recentOrders = [];

  static const _pink = Color(0xFFD4537E);
  static const _black = Color(0xFF1A1015);
  static const _pinkSoft = Color(0xFFF4C0D1);
  static const _pinkBlush = Color(0xFFFBEAF0);
  static const _cream = Color(0xFFFDF8F2);

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<ClientProvider>().loadClients();
      await _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    final provider = context.read<ClientProvider>();
    final allOrders = await provider.getAllOrders();
    final now = DateTime.now();
    final soon = allOrders.where((o) {
      if (o.dueDate == null || o.status == 'done')
        return false;
      final due = DateTime.parse(o.dueDate!);
      return due.difference(now).inDays <= 7;
    }).toList();
    setState(() {
      _allOrders = allOrders;
      _dueSoonOrders = soon;
      _recentOrders = allOrders.take(5).toList();
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  int get _activeOrders =>
      _allOrders.where((o) => o.status != 'done').length;

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFED93B1);
      case 'in_progress': return const Color(0xFFEFD27B);
      case 'done': return const Color(0xFF7BC47F);
      default: return const Color(0xFFED93B1);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'in_progress': return 'In Progress';
      case 'done': return 'Done';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClientProvider>();

    return Scaffold(
      backgroundColor: _black,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: _pink,
        unselectedItemColor: const Color(0xFFC0A0B0),
        selectedLabelStyle: GoogleFonts.dmSans(fontSize: 10),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 10),
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ClientsScreen()),
            ).then((_) {
              setState(() => _currentIndex = 0);
              provider.loadClients();
            });
          } else if (index == 2) {
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => const OrdersScreen()),
            ).then((_) {
              setState(() => _currentIndex = 0);
              _loadOrders();
            });
          } else if (index == 3) {
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ).then((_) => setState(() => _currentIndex = 0));
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded), label: 'Clients'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AddClientScreen()),
        ).then((_) => provider.loadClients()),
        backgroundColor: _pink,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: RefreshIndicator(
        color: _pink,
        onRefresh: () async {
          await provider.loadClients();
          await _loadOrders();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [

              // ── CARD 1: HEADER ──
              Container(
                color: _black,
                width: double.infinity,
                padding: const EdgeInsets.only(
                    top: 52, left: 20, right: 20, bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text('${_greeting()} ✦',
                                style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: const Color(0xFF9A7F8A))),
                            const SizedBox(height: 2),
                            Text("Mummy's Studio 🎀",
                                style: GoogleFonts.playfairDisplay(
                                    fontSize: 24,
                                    color: Colors.white)),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const SettingsScreen()),
                          ),
                          child: Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C1F28),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFF4A2E40)),
                            ),
                            child: const Icon(Icons.settings_outlined,
                                color: Color(0xFFED93B1), size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _statCard('${provider.clients.length}',
                            'Clients',
                            Icons.people_outline_rounded,
                            const Color(0xFFED93B1)),
                        const SizedBox(width: 8),
                        _statCard('$_activeOrders',
                            'Active Orders',
                            Icons.receipt_long_outlined,
                            const Color(0xFF7BA7ED)),
                        const SizedBox(width: 8),
                        _statCard('${_dueSoonOrders.length}',
                            'Due Soon',
                            Icons.schedule_rounded,
                            _dueSoonOrders.isNotEmpty
                                ? Colors.red.shade300
                                : const Color(0xFF9A7F8A)),
                      ],
                    ),
                  ],
                ),
              ),

              // ── CARD 2: QUICK ACTIONS ──
              Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: _cream,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                      20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36, height: 4,
                          decoration: BoxDecoration(
                            color: _pinkSoft,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Quick Actions',
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 18, color: _black)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _quickAction(
                              '+ New Client',
                              'Add client',
                              Icons.person_add_outlined,
                              _pink,
                                  () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) => const AddClientScreen()),
                              ).then((_) => provider.loadClients()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _quickAction(
                              'WhatsApp',
                              'AI import',
                              Icons.chat_outlined,
                              const Color(0xFF25D366),
                                  () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) => const WhatsAppParseScreen()),
                              ).then((_) => provider.loadClients()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _quickAction(
                              'All Clients',
                              'Browse & search',
                              Icons.people_outline_rounded,
                              const Color(0xFF3C4589),
                                  () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) => const ClientsScreen()),
                              ).then((_) => provider.loadClients()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _quickAction(
                              'All Orders',
                              'Track statuses',
                              Icons.receipt_long_outlined,
                              const Color(0xFF085041),
                                  () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) => const OrdersScreen()),
                              ).then((_) => _loadOrders()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── CARD 3: DUE SOON ──
              if (_dueSoonOrders.isNotEmpty)
                Transform.translate(
                  offset: const Offset(0, -48),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: _black,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(
                        20, 24, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 36, height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A2E40),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.schedule_rounded,
                                color: Colors.red.shade300, size: 16),
                            const SizedBox(width: 6),
                            Text('Due This Week',
                                style: GoogleFonts.playfairDisplay(
                                    fontSize: 18,
                                    color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ..._dueSoonOrders.map((order) {
                          final dueDate =
                          DateTime.parse(order.dueDate!);
                          final daysLeft = dueDate
                              .difference(DateTime.now())
                              .inDays;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C1F28),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: daysLeft <= 2
                                    ? Colors.red.shade900
                                    : const Color(0xFF4A2E40),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    color: daysLeft <= 2
                                        ? Colors.red.withValues(alpha: .2)
                                        : const Color(0xFF3D1F2C),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text('$daysLeft',
                                            style: GoogleFonts.playfairDisplay(
                                              fontSize: 16,
                                              color: daysLeft <= 2
                                                  ? Colors.red.shade300
                                                  : const Color(0xFFED93B1),
                                            )),
                                        Text('days',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 8,
                                              color: const Color(0xFF9A7F8A),
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(order.outfitName,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.dmSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white)),
                                      Text(
                                          'Due ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                                          style: GoogleFonts.dmSans(
                                              fontSize: 10,
                                              color: const Color(0xFF9A7F8A))),
                                    ],
                                  ),
                                ),
                                if (order.price != null)
                                  Text(
                                      '₦${order.price!.toStringAsFixed(0)}',
                                      style: GoogleFonts.playfairDisplay(
                                          fontSize: 14,
                                          color: const Color(0xFFF4C0D1))),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

              // ── CARD 4: RECENT ORDERS ──
              Transform.translate(
                offset: Offset(0,
                    _dueSoonOrders.isNotEmpty ? -72 : -48),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: _pinkBlush,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                      20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36, height: 4,
                          decoration: BoxDecoration(
                            color: _pinkSoft,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recent Orders',
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 18, color: _black)),
                          GestureDetector(
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const OrdersScreen()),
                            ).then((_) => _loadOrders()),
                            child: Text('See all',
                                style: GoogleFonts.dmSans(
                                    fontSize: 11, color: _pink)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (_recentOrders.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Text('🧾',
                                    style: TextStyle(fontSize: 32)),
                                const SizedBox(height: 8),
                                Text('No orders yet',
                                    style: GoogleFonts.playfairDisplay(
                                        fontSize: 14,
                                        color: const Color(0xFFB090A0))),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._recentOrders.map((order) =>
                            GestureDetector(
                              onTap: () => Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (_) => OrderDetailScreen(
                                    order: order,
                                    clientName: 'Client',
                                  ),
                                ),
                              ).then((_) => _loadOrders()),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _pinkSoft),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(order.outfitName,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.dmSans(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: _black)),
                                          if (order.dueDate != null)
                                            Text(
                                                'Due ${order.dueDate!.substring(0, 10)}',
                                                style: GoogleFonts.dmSans(
                                                    fontSize: 10,
                                                    color: const Color(0xFFB090A0))),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        if (order.price != null)
                                          Text(
                                              '₦${order.price!.toStringAsFixed(0)}',
                                              style: GoogleFonts.playfairDisplay(
                                                  fontSize: 13,
                                                  color: _pink)),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: _statusColor(order.status)
                                                .withValues(alpha: .15),
                                            borderRadius:
                                            BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                              _statusLabel(order.status),
                                              style: GoogleFonts.dmSans(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w500,
                                                  color: _statusColor(
                                                      order.status))),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── CARD 5: RECENT CLIENTS ──
              Transform.translate(
                offset: Offset(0,
                    _dueSoonOrders.isNotEmpty ? -96 : -72),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                      20, 24, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36, height: 4,
                          decoration: BoxDecoration(
                            color: _pinkSoft,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recent Clients',
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 18, color: _black)),
                          GestureDetector(
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const ClientsScreen()),
                            ),
                            child: Text('See all',
                                style: GoogleFonts.dmSans(
                                    fontSize: 11, color: _pink)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (provider.clients.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Text('🧵',
                                    style: TextStyle(fontSize: 40)),
                                const SizedBox(height: 10),
                                Text('No clients yet',
                                    style: GoogleFonts.playfairDisplay(
                                        fontSize: 16,
                                        color: const Color(0xFFB090A0))),
                                const SizedBox(height: 4),
                                Text('Tap + to add your first client',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: const Color(0xFFC0A0B0))),
                              ],
                            ),
                          ),
                        )
                      else
                        ...provider.clients
                            .take(5)
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                          final index = entry.key;
                          final client = entry.value;
                          final avatarColors = const [
                            Color(0xFFFBEAF0),
                            Color(0xFFF1EFE8),
                            Color(0xFFEEF1FB),
                          ];
                          final textColors = const [
                            Color(0xFFD4537E),
                            Color(0xFF5F5E5A),
                            Color(0xFF3C4589),
                          ];
                          final colorIndex = index % 3;
                          return GestureDetector(
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                builder: (_) => ClientProfileScreen(
                                    client: client),
                              ),
                            ).then((_) => provider.loadClients()),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: _cream,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _pinkSoft),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '${(index + 1).toString().padLeft(2, '0')}',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        color: _pink,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 36, height: 36,
                                    decoration: BoxDecoration(
                                      color: avatarColors[colorIndex],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        client.name.isNotEmpty
                                            ? client.name[0].toUpperCase()
                                            : '?',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: textColors[colorIndex],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(client.name,
                                            style: GoogleFonts.dmSans(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: _black)),
                                        if (client.phone != null)
                                          Text(client.phone!,
                                              style: GoogleFonts.dmSans(
                                                  fontSize: 10,
                                                  color: const Color(
                                                      0xFFB090A0))),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded,
                                      color: Color(0xFFF4C0D1), size: 18),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String number, String label,
      IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: color.withValues(alpha: .25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(number,
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 18, color: color)),
                Text(label,
                    style: GoogleFonts.dmSans(
                        fontSize: 8,
                        color: const Color(0xFF9A7F8A))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(String title, String subtitle,
      IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: color.withValues(alpha: .25)),
        ),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _black)),
                  Text(subtitle,
                      style: GoogleFonts.dmSans(
                          fontSize: 9,
                          color: const Color(0xFFB090A0))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: color, size: 14),
          ],
        ),
      ),
    );
  }
}