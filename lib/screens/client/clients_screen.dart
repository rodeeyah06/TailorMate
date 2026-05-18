import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tailormate/providers/client_provider.dart';
import 'package:tailormate/screens/client/add_client_screen.dart';
import 'package:tailormate/screens/client/client_profile_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const _pink = Color(0xFFD4537E);
  static const _black = Color(0xFF1A1015);
  static const _pinkSoft = Color(0xFFF4C0D1);
  static const _cream = Color(0xFFFDF8F2);

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<ClientProvider>().loadClients());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClientProvider>();

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddClientScreen()),
                      ).then((_) =>
                          context.read<ClientProvider>().loadClients()),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _pink,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Clients',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 24, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  '${provider.clients.length} total clients',
                  style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: const Color(0xFF9A7F8A)),
                ),
                const SizedBox(height: 14),
                // search bar
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C1F28),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFF4A2E40)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) =>
                        provider.searchClients(val),
                    style: GoogleFonts.dmSans(
                        fontSize: 13, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search clients...',
                      hintStyle: GoogleFonts.dmSans(
                        color: const Color(0xFF6A4A55),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF6A4A55),
                        size: 18,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── CLIENT LIST ──
          Expanded(
            child: provider.isLoading
                ? const Center(
                child: CircularProgressIndicator(color: _pink))
                : provider.displayedClients.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🧵',
                      style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text('No clients yet',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          color: const Color(0xFFB090A0))),
                  const SizedBox(height: 4),
                  Text(
                    'Tap + to add your first client',
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFFC0A0B0)),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.displayedClients.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final client =
                provider.displayedClients[index];
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

                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClientProfileScreen(
                          client: client),
                    ),
                  ).then((_) => context
                      .read<ClientProvider>()
                      .loadClients()),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(14),
                      border: Border.all(color: _pinkSoft),
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
                        // avatar or photo
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: avatarColors[colorIndex],
                            borderRadius:
                            BorderRadius.circular(12),
                            image: client.photoPath != null
                                ? DecorationImage(
                              image: FileImage(File(
                                  client.photoPath!)),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: client.photoPath == null
                              ? Center(
                            child: Text(
                              client.name.isNotEmpty
                                  ? client.name[0]
                                  .toUpperCase()
                                  : '?',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w500,
                                color: textColors[
                                colorIndex],
                              ),
                            ),
                          )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        // info
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                client.name,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: _black,
                                ),
                              ),
                              if (client.phone != null)
                                Text(
                                  client.phone!,
                                  style: GoogleFonts.dmSans(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}