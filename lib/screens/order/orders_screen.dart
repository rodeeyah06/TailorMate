import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tailormate/models/order.dart';
import 'package:tailormate/providers/client_provider.dart';
import 'package:tailormate/screens/order/order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<TailorOrder> _orders = [];
  String _selectedStatus = 'all';
  bool _loading = true;

  static const _pink = Color(0xFFD4537E);
  static const _black = Color(0xFF1A1015);
  static const _pinkSoft = Color(0xFFF4C0D1);
  static const _cream = Color(0xFFFDF8F2);

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    final provider = context.read<ClientProvider>();
    final orders = _selectedStatus == 'all'
        ? await provider.getAllOrders()
        : await provider.getOrdersByStatus(_selectedStatus);
    setState(() {
      _orders = orders;
      _loading = false;
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'No due date';
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month}/${date.year}';
  }

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
    return Scaffold(
      backgroundColor: _cream,
      body: Column(
        children: [
          // ── HEADER ──
          Container(
            color: _black,
            padding: const EdgeInsets.only(
                top: 52, left: 20, right: 20, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // back button
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C1F28),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFF4A2E40)),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFFED93B1),
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Orders',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 24, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  '${_orders.length} total orders',
                  style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: const Color(0xFF9A7F8A)),
                ),
                const SizedBox(height: 14),
                // filter tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterTab('all', 'All'),
                      const SizedBox(width: 8),
                      _filterTab('pending', 'Pending'),
                      const SizedBox(width: 8),
                      _filterTab('in_progress', 'In Progress'),
                      const SizedBox(width: 8),
                      _filterTab('done', 'Done'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── ORDERS LIST ──
          Expanded(
            child: _loading
                ? const Center(
                child: CircularProgressIndicator(color: _pink))
                : _orders.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🧾',
                      style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text('No orders yet',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          color: const Color(0xFFB090A0))),
                  const SizedBox(height: 4),
                  Text(
                    'Add orders from a client profile',
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFFC0A0B0)),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final order = _orders[index];
                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(
                        order: order,
                        clientName: 'Client',
                      ),
                    ),
                  ).then((_) => _loadOrders()),
                  borderRadius: BorderRadius.circular(14),
                  child: _orderCard(order),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterTab(String status, String label) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedStatus = status);
        _loadOrders();
      },
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _pink : const Color(0xFF2C1F28),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _pink : const Color(0xFF4A2E40),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : const Color(0xFF9A7F8A),
          ),
        ),
      ),
    );
  }

  Widget _orderCard(TailorOrder order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _pinkSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order.outfitName,
                  style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _black),
                ),
              ),
              if (order.price != null)
                Text(
                  '₦${order.price!.toStringAsFixed(0)}',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 16, color: _pink),
                ),
            ],
          ),
          if (order.fabric != null) ...[
            const SizedBox(height: 4),
            Text(order.fabric!,
                style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: const Color(0xFF9A7F8A),
                    fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 11, color: Color(0xFFB090A0)),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(order.dueDate),
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: const Color(0xFFB090A0)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor(order.status)
                      .withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel(order.status),
                  style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _statusColor(order.status)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}