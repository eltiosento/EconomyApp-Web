import 'package:flutter/material.dart';
import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/widgets/widgets_home_screen/global_balance_widget.dart';
import 'package:economy_app/widgets/widgets_home_screen/user_widget.dart';

class HomeSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final dynamic userDto;

  const HomeSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.userDto,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Container(
                width: 300,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.65),
                  border: Border(
                    right: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 25),

                    // ⭐ USER AVATAR + NAME
                    UserWidget(userDto: userDto),

                    const SizedBox(height: 30),

                    // ⭐ GLOBAL BALANCE (saldo, ahorros, presupuesto)
                    GlobalBalanceWidget(),

                    const SizedBox(height: 30),

                    Divider(color: Colors.white.withValues(alpha: 0.3)),

                    const SizedBox(height: 20),

                    // ⭐ MENÚ VERTICAL
                    _SidebarItem(
                      icon: Icons.show_chart,
                      title: "Movimientos",
                      index: 0,
                      selectedIndex: selectedIndex,
                      onTap: onItemSelected,
                    ),
                    _SidebarItem(
                      icon: Icons.attach_money,
                      title: "Mis ingresos",
                      index: 1,
                      selectedIndex: selectedIndex,
                      onTap: onItemSelected,
                    ),
                    _SidebarItem(
                      icon: Icons.savings,
                      title: "Ahorros",
                      index: 2,
                      selectedIndex: selectedIndex,
                      onTap: onItemSelected,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = index == selectedIndex;

    return InkWell(
      onTap: () => onTap(index),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 60),
        decoration: BoxDecoration(
          color:
              active ? AppColors.primaryColor.withValues(alpha: 0.8) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? Colors.white : Colors.white70),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: active ? Colors.white : Colors.white70,
                fontSize: 16,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
