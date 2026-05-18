import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tailormate/models/order.dart';
import 'package:tailormate/providers/client_provider.dart';
import 'package:tailormate/screens/client/add_client_screen.dart';
import 'package:tailormate/screens/client/client_profile_screen.dart';
import 'package:tailormate/screens/client/clients_screen.dart';
import 'package:tailormate/screens/client/whatsapp_parse_screen.dart';
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
  bool _loadingOrders = true;

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
      await _loadDueSoonOrders();
    });
  }

  Future<void> _loadDueSoonOrders() async {
    final provider = context.read<ClientProvider>();
    final allOrders = await provider.getAllOrders();
    final now = DateTime.now();
    final soon = allOrders.where((o) {
      if (o.dueDate == null || o.status == 'done') return false;
      final due = DateTime.parse(o.dueDate!);
      return due.difference(now).inDays <= 7;
    }).toList();
    setState(() {
      _dueSoonOrders = soon;
      _loadingOrders = false;
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClientProvider>();

    return Scaffold(
      backgroundColor: _cream,
      body: RefreshIndicator(
        color: _pink,
        onRefresh: () async {
          await provider.loadClients();
          await _loadDueSoonOrders();
        },
        child: CustomScrollView(
          slivers: [
            // ── HEADER ──
            SliverToBoxAdapter(
              child: Container(
                color: _black,
                padding: const EdgeInsets.only(
                    top: 52, left: 20, right: 20, bottom: 20),
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
                            Text(
                              '${_greeting()} ✦',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: const Color(0xFF9A7F8A),
                                letterSpacing: .06,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Mummy's Studio",
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        // whatsapp import button
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                const WhatsAppParseScreen()),
                          ).then((_) => provider.loadClients()),
                          child: Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C1F28),
                              borderRadius:
                              BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFF4A2E40)),
                            ),
                            child: const Icon(
                              Icons.chat_outlined,
                              color: Color(0xFFED93B1),
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // stats strip
                    Row(
                      children: [
                        _statCard(
                          '${provider.clients.length}',
                          'Clients',
                          Icons.people_outline_rounded,
                        ),
                        const SizedBox(width: 8),
                        _statCard(
                          '${_dueSoonOrders.length}',
                          'Due soon',
                          Icons.schedule_rounded,
                          urgent: _dueSoonOrders.isNotEmpty,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── QUICK ACTIONS ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick actions',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 16, color: _black)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _quickAction(
                            '+ New Client',
                            Icons.person_add_outlined,
                            _pink,
                                () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                  const AddClientScreen()),
                            ).then((_) => provider.loadClients()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _quickAction(
                            'All Clients',
                            Icons.people_outline_rounded,
                            const Color(0xFF3C4589),
                                () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                  const ClientsScreen()),
                            ).then((_) => provider.loadClients()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _quickAction(
                            'All Orders',
                            Icons.receipt_long_outlined,
                            const Color(0xFF085041),
                                () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                  const OrdersScreen()),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── DUE SOON ──
            if (_dueSoonOrders.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded,
                              color: _pink, size: 16),
                          const SizedBox(width: 6),
                          Text('Due this week',
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 16, color: _black)),
                        ],
                      ),
                      const SizedBox(height: 10),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: daysLeft <= 2
                                  ? Colors.red.shade200
                                  : _pinkSoft,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: daysLeft <= 2
                                      ? Colors.red.shade50
                                      : _pinkBlush,
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    '$daysLeft\nd',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: daysLeft <= 2
                                          ? Colors.red
                                          : _pink,
                                      height: 1.1,
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
                                    Text(
                                      order.outfitName,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: _black,
                                      ),
                                    ),
                                    Text(
                                      'Due ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        color: const Color(
                                            0xFFB090A0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (order.price != null)
                                Text(
                                  '₦${order.price!.toStringAsFixed(0)}',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 14,
                                    color: _pink,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

            // ── RECENT CLIENTS ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent clients',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 16, color: _black)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ClientsScreen()),
                      ),
                      child: Text('See all',
                          style: GoogleFonts.dmSans(
                              fontSize: 11, color: _pink)),
                    ),
                  ],
                ),
              ),
            ),

            provider.clients.isEmpty
                ? SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _pinkSoft),
                  ),
                  child: Column(
                    children: [
                      const Text('🧵',
                          style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 10),
                      Text('No clients yet',
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              color:
                              const Color(0xFFB090A0))),
                      const SizedBox(height: 4),
                      Text('Tap + New Client to get started',
                          style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: const Color(
                                  0xFFC0A0B0))),
                    ],
                  ),
                ),
              ),
            )
                : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  // show only last 5 clients
                  final recentClients =
                  provider.clients.take(5).toList();
                  if (index >= recentClients.length)
                    return const SizedBox(height: 80);
                  final client = recentClients[index];
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

                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                        16,
                        index == 0 ? 10 : 4,
                        16,
                        4),
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ClientProfileScreen(
                                  client: client),
                        ),
                      ).then((_) => provider.loadClients()),
                      borderRadius:
                      BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(14),
                          border: Border.all(
                              color: _pinkSoft),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${(index + 1).toString().padLeft(2, '0')}',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: _pink,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color:
                                avatarColors[colorIndex],
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  client.name.isNotEmpty
                                      ? client.name[0]
                                      .toUpperCase()
                                      : '?',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight:
                                    FontWeight.w500,
                                    color:
                                    textColors[colorIndex],
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
                                  Text(
                                    client.name,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight:
                                      FontWeight.w500,
                                      color: _black,
                                    ),
                                  ),
                                  if (client.phone != null)
                                    Text(
                                      client.phone!,
                                      style:
                                      GoogleFonts.dmSans(
                                        fontSize: 10,
                                        color: const Color(
                                            0xFFB090A0),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFFF4C0D1),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: provider.clients.take(5).length + 1,
              ),
            ),
          ],
        ),
      ),

      // ── FAB ──
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const AddClientScreen()),
        ).then((_) => provider.loadClients()),
        backgroundColor: _pink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),

      // ── BOTTOM NAV ──
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
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ClientsScreen()),
            ).then((_) => setState(() => _currentIndex = 0));
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const OrdersScreen()),
            ).then((_) => setState(() => _currentIndex = 0));
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SettingsScreen()),
            ).then((_) => setState(() => _currentIndex = 0));
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline_rounded),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _statCard(String number, String label, IconData icon,
      {bool urgent = false}) {
    return Expanded(
      child: Container(
        padding:
        const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: urgent
              ? Colors.red.shade900.withValues(alpha: .5)
              : const Color(0xFF2C1F28),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: urgent
                ? Colors.red.shade300
                : const Color(0xFF4A2E40),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: urgent
                    ? Colors.red.shade300
                    : const Color(0xFFED93B1),
                size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    color: urgent
                        ? Colors.red.shade300
                        : const Color(0xFFF4C0D1),
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: const Color(0xFF9A7F8A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(String label, IconData icon, Color color,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(12),
          border:
          Border.all(color: color.withValues(alpha: .3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}