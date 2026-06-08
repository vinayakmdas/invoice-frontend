import 'package:flutter/material.dart';
import 'package:invoice/core/theme/admin_theme.dart';
import 'package:invoice/features/admin/domain/entity/admin_entity.dart';
import 'package:invoice/features/admin/presentation/provider/admin_provider.dart';
import 'package:invoice/features/admin/presentation/widget/sharedwidget.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<AuthProvider>();
      if (prov.state == LoadingState.idle) {
        prov.loadAdminProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              title: const Text(
                'Profile & Settings',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryDark, AppTheme.primary],
                  ),
                ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Consumer<AuthProvider>(
              builder: (_, prov, __) {
                if (prov.state == LoadingState.loading) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ── Profile Card ───────────────────────────────────────
                      _buildProfileCard(prov.admin),

                      const SizedBox(height: 20),

                      // ── Settings Sections ──────────────────────────────────
                      _buildSettingsSection(
                        title: 'General',
                        items: [
                          _SettingItem(
                            icon: Icons.dark_mode_rounded,
                            label: 'Dark Mode',
                            trailing: Switch(
                              value: _darkMode,
                              onChanged: (v) => setState(() => _darkMode = v),
                              activeColor: AppTheme.primary,
                            ),
                          ),
                          _SettingItem(
                            icon: Icons.notifications_outlined,
                            label: 'Push Notifications',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textHint,
                            ),
                            onTap: () {},
                          ),
                          _SettingItem(
                            icon: Icons.language_rounded,
                            label: 'Language',
                            value: 'English',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textHint,
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _buildSettingsSection(
                        title: 'Account',
                        items: [
                          _SettingItem(
                            icon: Icons.lock_outline_rounded,
                            label: 'Change Password',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textHint,
                            ),
                            onTap: () {},
                          ),
                          _SettingItem(
                            icon: Icons.security_rounded,
                            label: 'Two-Factor Auth',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textHint,
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _buildSettingsSection(
                        title: 'App Info',
                        items: [
                          // _SettingItem(
                          //   icon: Icons.info_outline_rounded,
                          //   label: 'App Version',
                          //   value: AppConstants.version,
                          // ),
                          _SettingItem(
                            icon: Icons.description_outlined,
                            label: 'Terms of Service',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textHint,
                            ),
                            onTap: () {},
                          ),
                          _SettingItem(
                            icon: Icons.privacy_tip_outlined,
                            label: 'Privacy Policy',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textHint,
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Logout Button ──────────────────────────────────────
                      _buildLogoutButton(context, prov),

                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(AdminEntity? admin) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryLight],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  admin != null ? _getInitials(admin.name) : 'A',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    admin?.name ?? 'Admin',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    admin?.email ?? 'admin@invoiceapp.com',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      admin?.role ?? 'Super Admin',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<_SettingItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              return Column(
                children: [
                  _buildSettingTile(item),
                  if (i < items.length - 1)
                    const Divider(
                      height: 1,
                      color: Color(0xFFF0F4FF),
                      indent: 52,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(_SettingItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 17, color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            if (item.value != null) ...[
              Text(
                item.value!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
            ],
            if (item.trailing != null) item.trailing!,
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider prov) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showConfirmDialog(
          context,
          title: 'Logout',
          message: 'Are you sure you want to logout from the admin panel?',
          confirmLabel: 'Logout',
          isDangerous: true,
        );
        if (confirm == true && context.mounted) {
          prov.logout(context);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.rejectedBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.rejected.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded, color: AppTheme.rejected, size: 18),
            SizedBox(width: 10),
            Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.rejected,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'A';
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
  });
}
